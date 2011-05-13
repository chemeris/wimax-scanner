% The main script of WiMAX receiver
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

%% Prepare a bench
clear all
set_params
CTC_set_params
preambles
pilots
%test_carriers_permuter

%% Get data
read_2647
%% hard distortions in the channel 
% h = zeros(127,1); 
% h(1) = 1; 
% h(60)=1; 
% rcvdDL = conv(h, rcvdDL); 
%% add noise to signal 
% v = 1/sqrt(2)*std(rcvdDL); 
% v = v * sqrt(4); 
% rcvdDL = rcvdDL + v * (randn(length(rcvdDL),1) + 1j*randn(length(rcvdDL),1) ); 
%% find frame start position and frame carrier offset
%.*exp(1j*0.0064*(1:300000)).'

%rcvdDL(1:300000) = rcvdDL(1:300000).*exp(1j*2*pi/1024*(6.5/3)*(1:300000)).';
[frame_start_pos, frame_carrier_offset] = find_preamble(params, rcvdDL) ;



figure(2);
hold off; 
plot(0,0, 'x'); 


offset_timing_pos = 0; 
for i = 1: length(frame_start_pos)
    figure(1); hold on 
    plot(frame_start_pos(i), 0, 'go'); 
    hold off

%% setup params of OFDM demodulator
% set frame start position  
    dem_params.current_packet_start_pos =  frame_start_pos(i); 
% set estimated carrier offset    
    dem_params.current_packet_cfo = frame_carrier_offset(i);  
% set number of OFDM symbols for processing     
    dem_params.num_ofdm_syms = 4;
% tell demodulator try  to detect the preamble
% if case dem_params.preamble_idx > 1 then detection of the preamble will
% not be made
    dem_params.preamble_idx = -1; 
%  detect preamble, demodulate, equalizate
%  produce syms_fft_eq 

    demodulate_OFDM
    

%% Derandomization of the OFDM carriers

syms_fft_eq = DL0_derand(syms_fft_eq, num_ofdm_syms, params);


%% Extract FCH from OFDM symbols 0 and 1
FCH_qpsk_symbols = get_slot_data(syms_fft_eq, params.segment*10, ...
                                 params.FCH_repetitions, 2, params);

FCH_qpsk_symbols = conj(FCH_qpsk_symbols);  
if 1
% try average all 4 repetitions
    avr_QPSK = mean(FCH_qpsk_symbols); 
    avr_QPSK = avr_QPSK/mean(abs(avr_QPSK)); 
   
% adding noise for decoder test    
%     std_sig = std( avr_QPSK ); 
%     noise = 0.6*std_sig*(randn(1, length(avr_QPSK)) + 1j * randn(1, length(avr_QPSK)));    
%     SNR = 10*log10(var(avr_QPSK)/var(noise))     
%     avr_QPSK = avr_QPSK +noise; 
    FCH_demod_bits_best = demodulate_QPSK( avr_QPSK );
else
%% Demodulate 4 repetitions of FCH into an array of (soft) bits
    FCH_qpsk_symbols = FCH_qpsk_symbols/mean(mean(abs(FCH_qpsk_symbols))); 
    FCH_demod_bits_best = FCH_demod(params.FCH_repetitions, FCH_qpsk_symbols);   
end


%% De-interleave FCH (soft) bits
FCH_deinterleaved = deinterleave_QPSK(FCH_demod_bits_best, 16);
% Replace NaN's with 0s - Matlab Viterbi decoder can't handle NaN's.
FCH_deinterleaved(isnan(FCH_deinterleaved)) = 0;

%% Decode FCH using CC-1/2 with tail biting
FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved, 'unquant');
% We can also use hard decision this way:
%FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved<0, 'hard');

fprintf('preamble_idx = %d TO = %2.1f ', params.preamble_idx, timing_offset); 
%% Check FCH correctness and estimate BER
% FCH is repeated twice for FFT sizes >128, so we can check that
% we decoded it correctly:
if ~all(FCH_decoded(1:24) == FCH_decoded(25:48))
   fprintf('FCH decoding failed!\n');
   continue;
end

% Estimate the number of incorrectly received bits by encoding FCH again
% and counting the number of different bits.
recode = encode_CC_tail_biting(FCH_decoded);
FCH_errors = sum(xor(FCH_deinterleaved<0, recode'));
%fprintf(' SNRpilots = %2.1f dB, FCH error bits: %d', SNR_pilots, FCH_errors);
clear recode% FCH_errors;

%% Print FCH bits
fid = fopen('bit.txt', 'a'); 
fprintf(fid, '%d FCH 4 ', i); % FCH occupies 4 subchannels 
fprintf(fid, '%d', FCH_decoded(1:24)); 
fprintf(fid, '\n'); 
fclose(fid); 

%% DL-MAP work
DL_Map_Length     = bin2dec(sprintf('%d', FCH_decoded(13:20).'));
DL_Map_Repetition = bin2dec(sprintf('%d', FCH_decoded(8:9).'));
% Repetition is coded as 00b => 1, 01b => 2, 10b => 4, 11b => 6
if DL_Map_Repetition == 0
    DL_Map_Repetition = 1;
else
    DL_Map_Repetition = 2*DL_Map_Repetition;
end
DL_MAP_length_sym = ceil(DL_Map_Length/params.N_subchannels);

%% Extract DL-MAP 
% DL-MAP is the first slot after FCH, so we should skip 4 subchannels
% of FCH
dl_map_not_averaged = PDU_extract(DL_Map_Repetition, 4, DL_Map_Length, ...
                                  1, 0, ... start: OFDM symbol 1, subchanel 0
                                  DL_MAP_length_sym, params.N_subchannels, ...
                                  syms_fft_eq, params);

if DL_Map_Repetition > 1    
    % Average all DL-MAP repititions
    dl_map_qpsk = sum(dl_map_not_averaged); 
else
    dl_map_qpsk = dl_map_not_averaged; 
end

if 0    
    figure(11); 
    plot(dl_map_qpsk, 'o'), title('averaged repetitions of DL_MAP'); 
end
 
    
%% Decode DL-MAP burst to bits
% True CTC turbo decoder
[info, recoded_info, number_of_errors_in_DL_MAP] = ...
                CTC_Decode_Blocks(dl_map_qpsk, 'QPSK_1/2', CTC_params );    

    
%% Estimate SNR         
    % Convert bits to QPSK symbols   
    recoded_DL_MAP = sqrt(1/2)*((1-2*recoded_info(1:2:end)) + 1j*(1-2*recoded_info(2:2:end))); 
if 0
    figure(11),  plot(dl_map_not_averaged.', 'o'), title('not averaged DL_MAP');   
end    
    e = dl_map_not_averaged * recoded_DL_MAP';   
    e = sum(e)/(DL_Map_Repetition*length(recoded_DL_MAP)); 
    
    % Adjust phase and amplitude of reference sequence
    recoded_DL_MAP = e * recoded_DL_MAP; 
    % Substract recoded DL MAP
    for i=1:DL_Map_Repetition
         dl_map_not_averaged(i,:)  = dl_map_not_averaged(i,:) - recoded_DL_MAP;          
    end    
    dl_map_not_averaged = reshape( dl_map_not_averaged.', DL_Map_Repetition*length(recoded_DL_MAP), 1); 
    DL_MAP_SNR = -20*log10(std(dl_map_not_averaged)/(DL_Map_Repetition*std(recoded_DL_MAP)));     
%% Print status   
    fprintf('Errors in FCH: %d  Errors in DL-MAP = %d DL_MAP_SNR=%2.1f dB G=%1.2E Phi=%2.1f degrees', FCH_errors, number_of_errors_in_DL_MAP,  DL_MAP_SNR, abs(e), angle(e)/pi*180);     

    fid = fopen('bit.txt', 'a'); 
    fprintf(fid, '%d DL-MAP %02d ', i, DL_Map_Length); 
    fprintf(fid, '%d', info); 
    fprintf(fid, '\n'); 
    fclose(fid); 

    %% Done with this frame
    fprintf('\n');

    pause(0.2); 
end
