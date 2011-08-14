function [id_cell, segment] = decode_preamble_idx(preamble_idx)
% Finds IDcell and segment
% Refer to "8.4.6.1.1 Preamble" of IEEE 802.16-2009 for details.
%
%[id_cell, segment] = decode_preamble_idx(preamble_idx)
%
% INPUTS:
%
% OUTPUTS:
% id_cell - cell ID
% segment - segment number

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

if preamble_idx < 96
    id_cell = mod(preamble_idx, 32);
    segment = floor(preamble_idx/32);
else
    id_cell = preamble_idx-96;
    segment = mod(preamble_idx-96, 3);
end
