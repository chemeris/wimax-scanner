% Test pseudorandom values generation for 802.16e subcarrier randomization.
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

% Test vector from the Standard section 8.4.9.4.1 
pn = [ 1 0 1 0 1 0 1 0 1 0 1 ];

% Note that it starts repeating after 2^11-1 iterations
n_iter = 50;
pn_out = zeros(n_iter,1);
for i = 1:n_iter
    [pn_bit pn] = wimax_prbs(pn);
    pn_out(i) = pn_bit;
end
