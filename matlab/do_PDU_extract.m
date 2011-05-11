% Extract broadcast blocks from a set of frames.
%
% This script relies on data produced by the main script and on an array of
% broadcast block positions from 'diuc_o.txt' file.

% Copyright (C) 2011  Alexander Chemeris
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
% USA

%% Load positions of broadcast segments
diuc_0 = load('diuc_0.txt','-ascii');

%% Cycle trough all the data
frames_total = length(diuc_0(:,1));
for k = 62%:frames_total
    %% Get segment information
    frame_num = diuc_0(k,1);
    PDU_start_sym = diuc_0(k,2);
    PDU_start_subch = diuc_0(k,3);
    PDU_width_sym = diuc_0(k,4);
    PDU_width_subch = diuc_0(k,5);
    PDU_repetition = diuc_0(k,6);

    fprintf('%d | Start: %d sym, %d subch | Size: %d sym x %d subch | Repetition: %d ', ...
            frame_num, PDU_start_sym, PDU_start_subch, PDU_length_sym, PDU_length_subch, ...
            PDU_repetition);

    
    %% Demodulate enough OFDM symbols
    % set frame start position  
    dem_params.current_packet_start_pos =  frame_start_pos(frame_num); 
    % set estimated carrier offset    
    dem_params.current_packet_cfo = frame_carrier_offset(frame_num);  
    % set number of OFDM symbols for processing     
    dem_params.num_ofdm_syms = PDU_start_sym+PDU_length_sym-1;
    % tell demodulator try  to detect the preamble
    % if case dem_params.preamble_idx > 1 then detection of the preamble will
    % not be made
    dem_params.preamble_idx = params.preamble_idx; 
    %  detect preamble, demodulate, equalizate
    %  produce syms_fft_eq 
    %
    % TODO: We need to decode only our symbols
    demodulate_OFDM

    %% Derandomize subcarriers
    syms_fft_eq = DL0_derand(syms_fft_eq, num_ofdm_syms, params);

    %% Extract PDU data
    PDU_qpsk = PDU_extract(PDU_repetition, 0, inf, ...
                           PDU_start_sym, PDU_start_subch, ...
                           PDU_width_sym, PDU_width_subch, ...
                           syms_fft_eq, params);
    %% Decode
    [info, number_of_errors_in_PDU] = CTC_Decode_Blocks(PDU_qpsk, 'QPSK_1/2', CTC_params );
    fprintf(' PDU error bits = %d\n',  number_of_errors_in_PDU); 

    %% Output to a file
    % Output only if we have reasonable amount of errors.
    if number_of_errors_in_PDU < 50
        fid = fopen('bit.txt', 'a'); 
        fprintf(fid, '%d PDU %02d ', frame_num, PDU_width_sym*PDU_width_subch/2); 
        fprintf(fid, '%d', info); 
        fprintf(fid, '\n'); 
        fclose(fid); 
    end
end
