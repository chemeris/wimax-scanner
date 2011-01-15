function [subcarrier_PUSC_permutation] = gen_PUSC_permutation(DL_PermBase, params)
% Generate PUSC permutation tables for 802.16e (needs testing!).
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

% Refer to "8.4.6.1.2.1 Symbol structure for PUSC" of IEEE 802.16-2009 for
% details. Though it's written in so unclear language that I recommend
% you to read some textbook on the topic to understand this. I personally
% used Byeong Gi Lee, Sunghyun Choi "Broadband Wireless Access and Local
% Networks - Mobile WiMAX and WiFi".

% TODO:: Test and fix calculations if needed.
%        Look into PUSC-permutation.xls for correct calculations.

% Nsubchannels = 6 (for even-numbered major groups) or 4 (for odd-numbered
% major groups)
Nsubch = 6;
Nsc = params.N_sc_per_subchannel;

% index number of a subchannel
s = 0:Nsubch-1;
% subcarrier-in-subchannel index
k = 0:Nsc-1;

% nk(k, s)
nk = zeros(numel(k), numel(s));
for j=1:Nsc % iterate over k
    nk(j,:) = mod((j-1 + 13 * s), Nsc);
end
clear j;

% "ps[j] is the series obtained by rotating basic permutation sequence
%  cyclically to the left s times."
% So, basically it is ps(s+j), where ps is:
ps = [params.PermutationBase6 params.PermutationBase6];

% subcarrier(k, s)
subcarrier_PUSC_permutation = zeros(numel(k), numel(s));
for j=1:Nsubch % iterate over s
    subcarrier_PUSC_permutation(:,j) = Nsubch * nk(:,j)' + ...
        mod( ps(j+mod(nk(:,j), Nsubch)) + DL_PermBase, Nsubch);
end
