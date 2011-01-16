function [preamble_idx, id_cell, segment] = detect_preamble(sig_in, preamble_freq)
% Determine 802.16e preamble index, IDcell and segment.
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

% Refer to "8.4.6.1.1 Preamble" of IEEE 802.16-2009 for details.

%% Detect preamble by correlation in frequency space.
% Frequency space correlation gives us much better fidelity then
% time space correlation.
% TODO:: This could be greatly optimized knowing preambles structure.
num_preambles = size(preamble_freq, 1);
pr_corr = zeros(num_preambles, 1);
sig_in_freq = fft(sig_in);
for j = 1:num_preambles
    pr_corr(j) = abs(sum(preamble_freq(j,:)'.*sig_in_freq));
end
clear i sig_in_freq;

%% Find preamble index
[pr_corr_max PN_index] = max(pr_corr);
preamble_idx = PN_index-1;
%% Find IDcell and segment
if preamble_idx < 96
    id_cell = mod(preamble_idx, 32);
    segment = floor(preamble_idx/32);
else
    id_cell = preamble_idx-96;
    segment = mod(preamble_idx-96, 3);
end

%% Optionally plot correlations for all preambles
if 1
figure; hold on
plot(pr_corr, 'g')
plot(PN_index, pr_corr_max, 'ro')
hold off
end
