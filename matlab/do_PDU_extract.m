% Extract broadcast blocks from a set of frames.
%
% This script relies on data produced by the main script and on an array of
% broadcast block positions from 'diuc_list.txt' file.

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

%% Load DIUC coding parameters
% Note: Modify this to reflect your base station settings.
diuc_coding = { ...
    'QPSK_1/2'   ... DIUC 0
    'QPSK_3/4'   ... DIUC 1
    '16-QAM_1/2' ... DIUC 2
    '16-QAM_3/4' ... DIUC 3
    '64-QAM_1/2' ... DIUC 4
    '64-QAM_2/3' ... DIUC 5
    '64-QAM_3/4' ... DIUC 6
    '64-QAM_5/6' ... DIUC 7
    };

%% Load positions of broadcast segments
diuc_list = load('diuc_list.txt','-ascii');

%% Cycle trough all the data
frames_total = length(diuc_list(:,1));
for k = 1:frames_total
    %% Get segment information
    frame_num = diuc_list(k,1);
    PDU_diuc = diuc_list(k,2);
    PDU_start_sym = diuc_list(k,3);
    PDU_start_subch = diuc_list(k,4);
    PDU_width_sym = diuc_list(k,5);
    PDU_width_subch = diuc_list(k,6);
    PDU_repetition = diuc_list(k,7);

    %% Higher order modulation is not implemented yet
    if PDU_diuc > 1
        continue;
    end
    
    %% Initial information output
    fprintf('#%d DIUC %d | Start: %d sym, %d subch | Size: %d sym x %d subch | Repetition: %d ', ...
            frame_num, PDU_diuc, PDU_start_sym, PDU_start_subch, ...
            PDU_width_sym, PDU_width_subch, PDU_repetition);


    %% Demodulate enough OFDM symbols
    % set frame start position
    dem_params.current_packet_start_pos =  frame_start_pos(frame_num);
    % set estimated carrier offset
    dem_params.current_packet_cfo = frame_carrier_offset(frame_num);
    % set number of OFDM symbols for processing
    dem_params.num_ofdm_syms = PDU_start_sym+PDU_width_sym-1;
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

    if PDU_repetition>1
    % Average all repetitions.
       PDU_qpsk = sum(PDU_qpsk);
    end
    %% Decode
    [info, ~, number_of_errors_in_PDU] = CTC_Decode_Blocks(PDU_qpsk, diuc_coding(PDU_diuc+1), CTC_params );
    fprintf(' PDU error bits = %d of %d (%.0f%%)\n', ...
            number_of_errors_in_PDU, length(info), 100*number_of_errors_in_PDU/length(info));

    %% Output to a file
    % Output all data - it will be checed with CRC later anyway.
    if 1
        fid = fopen('bit.txt', 'a');
        fprintf(fid, '%d PDU %02d ', frame_num, PDU_width_sym*PDU_width_subch/2);
        fprintf(fid, '%d', info);
        fprintf(fid, '\n');
        fclose(fid);
    end
    
    %% Pause to allow user see figures
    %pause(5);
end

