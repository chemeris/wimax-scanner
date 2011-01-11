id_cell_bin = double(dec2bin(params.id_cell, 5))-48;
segment_bin = double(dec2bin(params.segment+1, 2))-48;

% 8.4.9.4.1 Subcarrier randomization
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
