% main script of testbench OFDM system 
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
figure(7); 
hold off; 
plot(0,0, 'x'); 
q= []; 


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
fprintf(' SNRpilots = %2.1f dB, FCH error bits: %d', SNR_pilots, FCH_errors);
clear recode FCH_errors;

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

%% Extracted and averaged QPSK characters that contain DL MAP
dl_map_qpsk = zeros(1, 48*DL_Map_Length/DL_Map_Repetition);     
k = 1; 
count_slots = 4; % first 4 slots for FCH
j = count_slots + 10*params.segment; % Index of first slot DL-MAP (first slot after FCH)
t = zeros(DL_Map_Repetition, 48); 
t_index = 1; 
first_sym = 1; 
while k<=DL_Map_Length/DL_Map_Repetition
    % Collect DL_Map_Repetition of slots
    t(t_index, :) = get_slot_data(syms_fft_eq(first_sym:first_sym+1,:), j, 1, 2, params);
    if t_index==DL_Map_Repetition
         t_index = 1; 
         if DL_Map_Repetition ~= 1
             % Average all repetitions
             dl_map_qpsk(1+(k-1)*48: k*48) = sum(t);
         else
             % Save the only repetition
             dl_map_qpsk(1+(k-1)*48: k*48) = t; 
         end
         k = k+1;              
    else
        t_index = t_index+1; 
    end
    if j==29 % The magic value "29" is index of the last slot
      % The last slot of ofdm symbols pair 
      j = 0; 
    else
      % Ajust number of the slot
      j = j+1; 
    end
    
    if  count_slots == 29     
        count_slots = 0; 
        first_sym = first_sym+2;         
    else
        count_slots = count_slots+1;
    end
          
end

figure(11); 
plot(dl_map_qpsk, 'o'), title('averaged repetitions of DL_MAP'); 
 
    
%% Decode DL-MAP burst to bits

%     if(DL_Map_Length==28)        
%         % The  DL-MAP is located in the seven slots.
%         % Process first 4 slots.
%         [info1, parity] = decode_DL_MAP_CTC(dl_map_qpsk( 1:48*4), 'QPSK_1/2', CTC_params ); 
%         info_encoded = CTC_Encoder(info1, 'QPSK_1/2', CTC_params); 
%         parity_enc = info_encoded(end/2+1:end); 
%         parity_difference4 =  sum(abs(parity - parity_enc))         
%         % Process last 3 slots.
%         [info2, parity] = decode_DL_MAP_CTC(dl_map_qpsk( 48*4+1: end), 'QPSK_1/2', CTC_params ); 
%         info_encoded = CTC_Encoder(info2, 'QPSK_1/2', CTC_params); 
%         parity_enc = info_encoded(end/2+1:end); 
%         parity_difference3 =  sum(abs(parity - parity_enc))         
%         info = [info1, info2]; 
%         
%     else
%         [info, parity] = decode_DL_MAP_CTC(dl_map_qpsk, 'QPSK_1/2', CTC_params ); 
%         info_encoded = CTC_Encoder(info,  'QPSK_1/2', CTC_params ); 
%         parity_enc = info_encoded(end/2+1:end); 
%         parity_difference8 =  sum(abs(parity - parity_enc))         
%     end

% True CTC turbo decoder
    [info, number_of_errors_in_DL_MAP] = CTC_Decode_Blocks(dl_map_qpsk, 'QPSK_1/2', CTC_params );    
    fprintf(' DL-MAP error bits = %d',  number_of_errors_in_DL_MAP); 

    fid = fopen('bit.txt', 'a'); 
    fprintf(fid, '%d DL-MAP %02d ', i, DL_Map_Length); 
    fprintf(fid, '%d', info); 
    fprintf(fid, '\n'); 
    fclose(fid); 

    %% Done with this frame
    fprintf('\n');

    pause(0.2); 
end
