function [sym_start_diff max_corr corr] = get_symbol_start(sig_in, params)
% Search for OFDM symbol first sample.
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

% Refer to "8.4.2 OFDMA symbol description, symbol parameters and
% transmitted signal" of IEEE 802.16-2009 for details about Cyclic Prefix.

% Searching for CP correlating with a symbol end.
% This way we search for a frame start
len = length(sig_in) - params.Ts_samples;
corr = zeros(len,1);
for i=1:len
    sig1 = sig_in(i:i+params.Tg_samples-1);
    sig2 = sig_in(i+params.Tb_samples:i+params.Tb_samples+params.Tg_samples-1);
	corr(i) = sum( sig1 .* conj(sig2) );
    % This is a simplified version with 2 multiplications instead of
    % 5 in the version above. Absolute value is almost the same, but this
    % calculations does not give us angle shift and thus can't be used
    % for simple CFO correction.
%	corr(i) = sum( (real(sig1).*real(sig2)) + (imag(sig1).*imag(sig2)));
%	corr(i) = sum( abs(real(sig1)+real(sig2)) + abs(imag(sig1)+imag(sig2)));
end
clear i len;


% Timing and Fractioinal CFO
[max_corr sym_start_diff] = max((corr));
