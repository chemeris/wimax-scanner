% Copyright (C) 2011  Alexey Ostapenko
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
% 
% Decode systematic bits of  the CTC
% does work with encoded data block size equal 96(8 slots) or 48(4 slots) bytes (table 502)
% other block's size not supported now!


function decoded_bits = decode_DL_MAP_CTC(x)

% CTC encoded block size in bytes, see in the table 502 (   QPSK 1/2  only)
encoded_bytes = [ 12
                  24
                  36
                  48
                  60
                  72
                  96
                  108
                  120]; 

payload_bytes = [6, 
                 12,
                 18,
                 24,
                 30,
                 36,
                 48,
                 54,
                 60]; 

num_in_bits = length(x)*2; 
tmp_ind = find(encoded_bytes*8 <= num_in_bits); 
select_mode = tmp_ind(end); 
N = encoded_bytes(select_mode)*8/4;                             % only 1/2 code rate!
bits = reshape([real(x(1:N*2))<0; imag(x(1:N*2))<0; ], N*4, 1).'; % only 1/2 code rate!

A = bits(1:N); 
B = bits(N+1:N*2); 

if N==192
    m = 6; J = 3; 
else
    if N==96
        m=5; J=3; 
    end
end
%% generate PRBS see 8.4.9.1 Randomization
sr = [0 1 1 0 1 1 1 0 0 0 1 0 1 0 1]; 

prbs = zeros(1, 2*N); 
for i=1:2*N
    rnd = bitxor(sr(14), sr(15)); 
    sr(2:15) = sr(1:14); 
    sr(1) = rnd; 
    prbs(i) = rnd; 
end

%% build the deinterleaving table
tmp = subblock_interleaver((0:N-1), N, m, J); 
[tmp, deintr_tab] =sort(tmp); 

%% deinterleave
decoded_bits = zeros(1, 2*N); 
decoded_bits(1:2:end) = A(deintr_tab); 
decoded_bits(2:2:end) = B(deintr_tab); 
decoded_bits = bitxor(prbs, decoded_bits); 
%% -













             


