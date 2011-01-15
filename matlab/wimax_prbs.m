function [out_bit new_pn] = wimax_prbs(pn)
% Generate pseudorandom values for 802.16e subcarrier randomization.
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

% Bit length of the shiftRegister
pn_length = 11;

% Pull the output of the register (the last bit)
out_bit = pn(pn_length);

% Feedback (modulo 2)
c = xor(pn(pn_length),pn(pn_length-2));

% Insert that value in the beginning and shift the rest to the right
new_pn = [c pn(1:pn_length-1)];
