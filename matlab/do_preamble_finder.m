% main script of testbench OFDM system 
clear all
set_params
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
%% setup params of OFDM demodulator
% set frame start position  
    dem_params.current_packet_start_pos =  frame_start_pos(i); 
% set estimated carrier offset    
    dem_params.current_packet_cfo = frame_carrier_offset(i);  
% set number of OFDM symbols for processing     
    dem_params.num_ofdm_syms = 2;
% tell demodulator try  to detect the preamble
% if case dem_params.preamble_idx > 1 then detection of the preamble will
% not be made
    dem_params.preamble_idx = -1; 
%  detect preamble, demodulate, equalizate
%  produce syms_fft_eq 
    demodulate_OFDM

%% 
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

%% Decode FCH using CC-1/2 with tail biting
FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved, 'unquant');
% We can also use hard decision this way:
%FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved<0, 'hard');

fprintf('preamble_idx = %d TO = %2.1f ', params.preamble_idx, timing_offset); 
%% Check FCH correctness, estimate BER, print FCH and exit.
% FCH is repeated twice for FFT sizes >128, so we can check that
% we decoded it correctly:
if ~all(FCH_decoded(1:24) == FCH_decoded(25:48))
   fprintf('FCH decoding failed!');
end




% Estimate the number of incorrectly received bits by encoding FCH again
% and counting the number of different bits.
recode = encode_CC_tail_biting(FCH_decoded);
FCH_errors = sum(xor(FCH_deinterleaved<0, recode'));
fprintf(' SNRpilots = %f dB, Number of error bits in FCH: %d\n', SNR_pilots, FCH_errors);
clear recode FCH_errors;
    
%% DL-MAP work
DL_Map_Length     = bin2dec(sprintf('%d', FCH_decoded(13:20).'));
DL_Map_Repetition = 2*bin2dec(sprintf('%d', FCH_decoded(8:9).'))

if 1%DL_Map_Length==28
    dl_map_qpsk = zeros(1, 48*DL_Map_Length/DL_Map_Repetition); 
 %   PartA_Len = DL_Map_Length/4/4; % code rate 1/2, 4 repetitions
%    PartA_qpsk = zeros(PartA_Len, 24*2); 
%    PartB_qpsk = PartA_qpsk; 
    
    
    j = 4; % index of first slot DL-MAP first slot after FCH
    
    for i = 1: DL_Map_Length/DL_Map_Repetition; 
        t = get_slot_data(syms_fft_eq, j, DL_Map_Repetition, 2, params);
        dl_map_qpsk(1+(i-1)*48: i*48) = sum(t); 
       % PartA_qpsk(i,:) = sum(t); 
       
        j = j + DL_Map_Repetition;         
        if( (j+DL_Map_Repetition-1) > 29 )
            break; 
        end
    end
    figure(11); 
    plot(dl_map_qpsk, 'o'); 
%     
%     j = 4; 
%     for i=1:PartA_Len
%         t = get_slot_data(syms_fft_eq, j, 4, 2, params);
%         PartA_qpsk(i,:) = sum(t); 
%         j = j+4;         
%     end
%     
%     
%     for i=1:PartA_Len
%         t = get_slot_data(syms_fft_eq, j, 4, 2, params);
%         PartB_qpsk(i,:) = sum(t); 
%         j = j+4;         
%     end
% % !!!!!!!!!!!! do not forget about conj !!!!!!!!        
% %     figure(11); 
% %     plot([reshape(PartA_qpsk,PartA_Len*48,1);  reshape(PartB_qpsk,PartA_Len*48,1)], '+'); 
%     
%     t = reshape( PartA_qpsk.', PartA_Len*48, 1).'; 
%     PartA_bits = reshape([real(t)<0; imag(t)<0], PartA_Len*48*2, 1).';  
% 
%     t = reshape( PartB_qpsk.', PartA_Len*48, 1).'; 
%     PartB_bits = reshape([real(t)<0; imag(t)<0], PartA_Len*48*2, 1).';  
%     
%     
%     N = 192; m=6; J = 3; 
%     tmp = subblock_interleaver((0:N-1), N, m, J); 
%     [tmp, deintr_tab] =sort(tmp); 
%     
%     PartA_deintr = PartA_bits(deintr_tab); 
%     PartB_deintr = PartB_bits(deintr_tab); 
%     
%     PartAB = zeros(1, PartA_Len*48*2*2); 
%     
%     PartAB(1:2:end) = PartA_deintr; 
%     PartAB(2:2:end) = PartB_deintr; 
%     
%    dl_map_qpsk = conj(dl_map_qpsk); %!!!!!!!!!!! 
    if(DL_Map_Length==28)        
        % process first 4 slots
        info = decode_DL_MAP_CTC(dl_map_qpsk( 1:48*4) ); 
    else
        info = decode_DL_MAP_CTC(dl_map_qpsk ); 
    end
    
    fid = fopen('bit.txt', 'a'); 
    fprintf(fid, '\n %02d: ',DL_Map_Length); 
    fprintf(fid, '%d', info); 
    fclose(fid); 
    
end

pause(0.5); 

end
%frame_carrier_offset
%q