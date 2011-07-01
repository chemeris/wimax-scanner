% Copyright (C) 2011  Alexey Ostapenko
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
% 
%
% The goal of this script is 
% convert frame into frequency domain,
% determine  of the preamble index, 
% compensate  effects of the timing offset,
% estimate the channel responce, 
% equalization the OFDM symbols. 
% The script is controlled structure "dem_params".

% Set the parameters for channel estimator
fd_sm_length = 51;
td_sm_factor = 0.2;
QPSK_mode = true; 

p = dem_params.current_packet_start_pos; 
current_packet_cfo = dem_params.current_packet_cfo;  
num_ofdm_syms = dem_params.num_ofdm_syms; 


syms_fft_eq = zeros( num_ofdm_syms, params.Tb_samples);  
%get samples(time domain)
frame_td =  rcvdDL(p: p + params.Tb_samples-1);
%TODO compensation of carrier offset shall be here

% convert to frequency domain
frame_fd = fft(frame_td); 
frame_fd_for_CFO = fftshift(frame_fd); 
        
%% compensation of  the systematic timing offset 
% this needed, since FFT window lie at the centre of the OFDM symbol
frame_fd = frame_fd_for_CFO.*exp(1j*2*pi/1024*(params.Tg_samples)/2*(1:1024)).'; 

%% find preamble index 
if dem_params.preamble_idx < 0
    [preamble_idx, id_cell, segment] = detect_preamble_fd(frame_fd, preamble_freq); 

    params.preamble_idx =  preamble_idx; 
    params.id_cell  = id_cell; 
    params.segment  = segment; 
end  
%% Estimate CFO
   cfo =  CFO_Estimator(frame_fd_for_CFO, segment, CFO_Estimator_params);  
%  cfo = cfo*1.25;  

% Compensate the CFO for preamble
   frame_fd = fftshift( fft(frame_td .* exp(-1j * cfo * (0:1023)).'));
   % Compensation of  the systematic timing offset 
   frame_fd = frame_fd .* exp(1j*2*pi/1024*(params.Tg_samples)/2*(1:1024)).'; 
   carrier_phase = 0;

%% take current preamble 
    ref = fftshift(preamble_freq(params.preamble_idx+1,:).'); 
    nonzero_idx = find(ref~=0);         
    
%% precise timing correction
% The general idea is to make the phase of the OFDM  symbol more  smooth.
channel_fd = frame_fd .* conj(ref); 
tmp1 = channel_fd(nonzero_idx); 
phase_trend = angle( tmp1(1:end-1)' * tmp1(2:end) )/3;   
frame_fd = frame_fd.*exp(-1j*phase_trend*(1:params.Tb_samples)).'; 
channel_fd = frame_fd .* conj(ref); 

% estimate channel and equalizer responces in the frequency domain
[f_eq, f_ch] = channel_estimator([], frame_fd, ref, nonzero_idx, ...
                    fd_sm_length, td_sm_factor, QPSK_mode); 
 
% the timing_offset in samples for information only
timing_offset = phase_trend/(2*pi/1024); 
p = p + params.Ts_samples; 

sym_fft = zeros(dem_params.num_ofdm_syms, 1024);    

%% generate scrambled pilot sequences
pilots = zeros(num_ofdm_syms, params.Tb_samples); 

pilots(1:2:num_ofdm_syms, params.pilot_shifted(2, :) ) = 1; 
pilots(2:2:num_ofdm_syms, params.pilot_shifted(1, :) ) = 1; 
% pilots(3, params.pilot_shifted(2, :) ) = 1; 
% pilots(4, params.pilot_shifted(1, :) ) = 1; 

pilots = DL0_derand(fftshift(pilots,2), num_ofdm_syms, params);

descrambled_pilots = []; 

%% Process data
for j=1:num_ofdm_syms            
    frame_td =  rcvdDL(p: p + params.Tb_samples-1);
    %% Compensation of carrier offset     
    carrier_phase = carrier_phase + params.Ts_samples*cfo;
    frame_td = frame_td .* exp(-1j * (carrier_phase + cfo * (0:1023))).'; 
    
    %% -- convert a current frame to frequency domain     
    frame_fd = fft(frame_td); 
    frame_fd = fftshift(frame_fd); 
    figure(13),     plot(500:520, abs(frame_fd(500:520))), hold on
    
    %% -- correct timing offset
    frame_fd = frame_fd.*exp(1j*2*pi/1024*(params.Tg_samples)/2*(1:1024)).';         
    frame_fd = frame_fd.*exp(-1j*phase_trend*(1:params.Tb_samples)).'; 
    %% -- update the estimation of channel 
    if(mod(j, 2)==1)
        current_pilots_ind = 2; 
    else
        current_pilots_ind = 1;         
    end
    [f_eq, f_ch] = channel_estimator(f_ch, frame_fd, ...
        pilots(j, :).', params.pilot_shifted(current_pilots_ind,:).',...
        fd_sm_length, td_sm_factor, QPSK_mode);         
    %% --plot channel responce    
    figure(3), plot(1:1024, abs(frame_fd), '-b', 1:1024, abs(f_ch),'-r'); 
    title('Estimated channel responce'); 

    %% -- apply equalizer    
    sym_equalized = frame_fd .* f_eq; %./abs(f_eq); %!!!
    syms_fft_eq(j,:) = fftshift(sym_equalized); 

    %% -- save pilots for further analysis
    t = pilots(j, :).' .* sym_equalized;
    t = t(params.pilot_shifted(current_pilots_ind,:));
    descrambled_pilots = [descrambled_pilots; t; ];
    
    %% -- plot constellations of all subcarriers    
    figure(8);
    subplot(1,2,1);    
    plot( sym_equalized(params.sc_first:params.sc_last), '+');
    m = max(abs(sym_equalized(params.sc_first:params.sc_last))); 
    title('All subcarriers');
    axis([-m m -m m])
    axis('square')
    %% -- plot pilots
    subplot(1,2,2); 
    plot(descrambled_pilots, '+'); title('Descrambled pilots');     
    axis([-m m -m m])
    axis('square')     

    %% -- move to the next OFDM symbol
    p = p + params.Ts_samples; 
%    carrier_phase = carrier_phase + frame_carrier_offset(i) * params.Ts_samples;  
end    

% figure(13), hold off
%% calculate SNR for pilots
var_pilots = var(descrambled_pilots); 
mean_pilots = mean(descrambled_pilots); 
SNR_pilots = 10*log10(mean_pilots^2/var_pilots); 

 