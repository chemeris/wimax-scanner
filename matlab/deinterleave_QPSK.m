function [deinterleaved] = deinterleave_QPSK(input, d)
% De-interleave QPSK modulated signal for 802.16e.
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

% Refer to "8.4.9.3 Interleaving" of IEEE 802.16-2009 for details.

% The number of coded bits per subcarrier (for QPSK)
Ncpc = 2;
% Helping variable
s = Ncpc/2;
% The encoded block size
Ncbps = length(input);
% The modulo used for the permutation (fixed by the standard)
%d = 16;

% j is the index of a received bit before the first permutation
j = 0:Ncbps-1;

% mj is the index of the received bit after the first and before
% the second permutation
%mj = s*floor(j/s) + mod((j + floor(d * j / Ncbps)), s);
% For QPSK, where s = 1 this permutation degenerates:
mj = j;

% kj is the index of the received bit after the second permutation
kj = d*mj - (Ncbps - 1)*floor(d * mj / Ncbps);

% Get j(kj) from kj(j)
[~, idx] = sort(kj);
deinterleaved = input(idx);
