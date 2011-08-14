function [preamble_idx, est_offset] = detect_preamble_fd(sig_in_freq_shifted, preamble_freq, max_offset)
% Determine 802.16e preamble index, IDcell, segment, integer CFO.
% Refer to "8.4.6.1.1 Preamble" of IEEE 802.16-2009 for details.
% Same as detect_preamble but input is shifted result of FFT 
%
%[preamble_idx, id_cell, segment, est_offset] =
%        detect_preamble_fd(sig_in_freq_shifted, preamble_freq, max_offset)
% INPUTS:
% sig_in_freq_shifted - input frame in frequency domain, shifted
% preamble_freq - collection of all possibles preambles in freq. domain
% max_offset  - abs of maximum expected carrier offset (fft bins), 
% default zero
% OUTPUTS:
% ...
% est_offset  - estimated integer offset of carrier

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

if nargin < 3
   max_offset = 0;  
end

num_preambles = size(preamble_freq, 1);
pr_corr = zeros(num_preambles*(max_offset*2+1), 1);

%% Detect preamble by correlation in frequency space.
% Frequency space correlation gives us much better fidelity then
% time space correlation.
% TODO:: This could be greatly optimized knowing preambles structure.
%
% We iterate through all possible integer offsets to find the one with
% the highest correlation.
for n = -max_offset:max_offset
    for j = 1:num_preambles
        tmp  = fftshift(preamble_freq(j, :)); 
        t = tmp(32:end-32-1)'.*sig_in_freq_shifted(32+n:end-32-1+n);  
        t = reshape(t, 32, length(t)/32); 
        t = sum(t); 
        pr_corr(j+(max_offset+n)*num_preambles) = sum( abs(t) );     
    end
end

%figure(13), plot(1:1024, 5E4*abs(fftshift(preamble_freq(1,:))'), 1:1024, abs(sig_in_freq_shifted)); 
clear i sig_in_freq;

% Different ways to get from complex values to real values.
% We want the one which has decent performance and at the same time
% minimal complexity.
%pr_corr = abs(pr_corr);
%pr_corr = real(pr_corr).*real(pr_corr) + imag(pr_corr).*imag(pr_corr);
%pr_corr = abs(real(pr_corr)) + abs(imag(pr_corr));

%% Find preamble index

[pr_corr_max pr_corr_max_index] = max(pr_corr);
est_offset = fix( (pr_corr_max_index-1)/ num_preambles)-max_offset; 
PN_index = 1+mod(pr_corr_max_index-1, num_preambles); 
preamble_idx = PN_index-1;

%% Optionally plot correlations for all preambles
if 1
figure(2); hold on
ylim([0, pr_corr_max*1.2])
for n = 1:2*max_offset
    plot([num_preambles*n;num_preambles*n], [0, pr_corr_max*1.2],'--', 'color',[0.5 0.5 0.5])
end
plot(pr_corr, 'g')
plot(pr_corr_max_index, pr_corr_max, 'ro')
hold off
end
