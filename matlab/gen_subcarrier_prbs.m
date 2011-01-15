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

id_cell_bin = double(dec2bin(params.id_cell, 5))-48;
segment_bin = double(dec2bin(params.segment+1, 2))-48;

% This coding is for the first DL zone
pn = [ id_cell_bin(1) id_cell_bin(2) ... % b0..b1
       id_cell_bin(3) id_cell_bin(4) id_cell_bin(5) ... % b2..b4
       segment_bin(1) segment_bin(2) ... % b5..b6
       1 1 1 1 ]; % b7..b10
   
%   "The PRBS generator shall be clocked no more then 31 times before
%    being applied to symbol."
% So we could generate it once for all.

% Generate enough bits
n_iter = params.N_total_sc + 31;
subcarrier_prbs = zeros(n_iter,1);
for n = 1:n_iter
    [pn_bit pn] = wimax_prbs(pn);
    subcarrier_prbs(n) = pn_bit;
end
clear id_cell_bin segment_bin pn n_iter pn_bit n;

% Splice into 32 arrays
subcarrier_rand_seq = zeros(32, params.N_total_sc);
for n = 1:32
    subcarrier_rand_seq(n,:) = subcarrier_prbs(n:n+params.N_total_sc-1);
end
clear n;

% Modulate bits for subchannel randomization
subcarrier_rand_seq_mod = 2*(0.5-subcarrier_rand_seq);
