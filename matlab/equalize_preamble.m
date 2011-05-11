% Simple channel equalization using preamble carriers.
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

%% Get ideal signal
sp_ref = preamble_freq_shifted(params.preamble_idx+1,:); % Ideal pilot signal
X = find(sp_ref ~= 0); % индексы поднесущих пилот-сигнала
sp_ref = sp_ref(sp_ref ~= 0); 

%% Get received signal
sig_in = fftshift(fft(rcvdDL(theta:theta+params.Tb_samples-1))'); % Received pilot signal
sp_rx = sig_in(X); % Received pilot signal
 
%% Calculate erorror over pilot signals
sp_err = sp_ref ./ sp_rx; 
 
%% Interpolate error voctor over all sub-carriers
err_vec_preamble = interp1(X, sp_err, 1:length(sig_in), 'spline'); 
 
%% Correct signal
rx_sym = sig_in .* err_vec_preamble;
 
%% Do plots
%figure; hold on ; plot(abs(sig_in)); plot(abs(1./err_vec_preamble), 'r'); hold off

%t = sig_in; t(X) = 0;
%figure; axes('YScale','log'); hold on ; plot(abs(t)); plot(abs(1./err_vec_preamble), 'r'); hold off
%ylim([1e3 1e6]);
%title('Noise (blue) and channel profile (red)');
%clear t;

%figure; semilogy(abs(err_vec_preamble)) ; grid on ;
%scatterplot(rx_sym);

%% Calculate SNR
t = rx_sym; t(X)=0; t = t(86:1024-86);
%figure; plot(abs(rx_sym(86:1024-86)));
%figure; plot(abs(t));
snr = mean(t);
fprintf('SNR in preamble = %.1f dB\n', db(snr));
clear t;

%% Clear workspace
clear X sp_ref sp_ref sp_rx sp_err sig_in rx_sym;
