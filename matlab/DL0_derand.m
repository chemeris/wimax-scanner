% De-randomize subcarriers data before de-modulation (802.16e).
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

% Refer to "8.4.9.4.1 Subcarrier randomization" of IEEE 802.16-2009 for
% details.

sym_derand = zeros(2, params.N_fft);
for sym_n = 1:2
    sym_pilots = mod(sym_n,2)+1;

    sig_in = sym_fft_eq(sym_n,:);
    sig_in = fftshift(sig_in);
    sym_derand(sym_n,params.sc_first:params.sc_last) = ...
        sig_in(params.sc_first:params.sc_last) .* subcarrier_rand_seq_mod(sym_n,:);
    % Plot pilots before de-randomization (blue) and after (red).
    % After de-randomization all pilots should be positive.
%    figure ; hold on
%      plot(real(sig_in(pilot_shifted(sym_pilots,:))), 'b') ;
%      plot(real(sym_derand(sym_n,pilot_shifted(sym_pilots,:))), 'r') ; hold off
end
clear sym_pilots sym_n sig_in;
