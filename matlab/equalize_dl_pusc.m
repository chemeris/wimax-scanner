function [sym_eq] = equalize_dl_pusc(sym_0, sym_1, params, err_vec_preamble)
% Equalize two symbols of DL-PUSC.
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

%% Extract received pilots
sp_rx_even = sym_0(params.pilot_shifted(2,:)); % Even
sp_rx_odd  = sym_1(params.pilot_shifted(1,:)); % Odd
 
%% Calculate erorror over pilot signals
sp_err_even = 0.5 ./ sp_rx_even;
sp_err_odd  = 0.5 ./ sp_rx_odd;
 
%% Interpolate error voctor over all sub-carriers
method = 'spline';
%method = 'linear';
err_vec_even = interp1(params.pilot_shifted(2,:), sp_err_even, 1:length(sym_0), method); 
err_vec_odd  = interp1(params.pilot_shifted(1,:), sp_err_odd,  1:length(sym_1), method); 
err_vec_comb = interp1([params.pilot_shifted(1,:) params.pilot_shifted(2,:)],...
                       [sp_err_odd sp_err_even],  1:length(sym_1), method); 
err_vec_comb2 = (err_vec_comb + err_vec_preamble)/2;


%% Equalize signal
if 1
sym_eq(1,:) = sym_0 .* err_vec_even;
sym_eq(2,:) = sym_1 .* err_vec_odd;
elseif 0
sym_eq(1,:) = sym_0 .* err_vec_comb;
sym_eq(2,:) = sym_1 .* err_vec_comb;
elseif 0
sym_eq(1,:) = sym_0 .* err_vec_comb2;
sym_eq(2,:) = sym_1 .* err_vec_comb2;
else
sym_eq(1,:) = sym_0 .* err_vec_preamble;
sym_eq(2,:) = sym_1 .* err_vec_preamble;
end
 
%% Do plots
%figure; hold on ; plot(abs(fftshift(sig_in))); plot(abs(fftshift(1./err_vec)), 'r'); hold off
%figure; plot(abs(fftshift(rx_sym)));
%scatterplot(rx_sym);
figure ; h1 = subplot(2,1,1,'YScale','log'); hold on ;
  plot(abs((1./err_vec_even)), 'g-');
  plot(abs((1./err_vec_odd)), 'b-');
  plot(abs((1./err_vec_comb)), 'k-');
  plot(abs(1./err_vec_preamble), 'r');
hold off
xlim([0 numel(sym_0)])
ylim([1e2 1e6])
title('Amplitude of the channel estimation');
 
h2 = subplot(2,1,2); hold on ;
  plot(angle((1./err_vec_even)), 'g-');
  plot(angle((1./err_vec_odd)), 'b-');
  plot(angle((1./err_vec_comb)), 'k-');
  plot(angle(1./err_vec_preamble), 'r');
hold off
xlim([0 numel(sym_0)])
ylim([-pi pi])
title('Phase of the channel estimation');


figure ; subplot(2,1,1) ; plot(abs(sp_rx_even), '.')
title ('Symbol pilots before equalization')
subplot(2,1,2) ; plot(angle(sp_rx_even), '.')

