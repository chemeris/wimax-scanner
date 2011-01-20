function [interleaved] = interleave_QPSK(input, d)
% Interleave QPSK modulated signal for 802.16e.
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

Ncbps = length(input);
Ncpc = 2;
k = 0 : Ncbps - 1;
mk = (Ncbps/d) * mod(k,d) + floor(k/d);

% In case of QPSK jk equals to mk
%s = ceil(Ncpc/2);
%jk = s * floor(mk/s) + mod(mk + Ncbps - floor(d * mk/Ncbps), s);
jk = mk;

[~,int_idx]=sort(jk);
interleaved = input(int_idx);
