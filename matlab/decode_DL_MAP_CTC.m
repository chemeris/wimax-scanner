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
% does work with encoded data block size equal 8, 4, 3 slots
% other block's size not tested now!


function [decoded_bits, parity] = decode_DL_MAP_CTC(x, Modulation_CodeRate, CTC_params)
% function [decoded_bits, parity] =
% decode_DL_MAP_CTC(x,Modulation_CodeRate, CTC_params)
%
% Valid  values for Modulation_CodeRate is 
% 'QPSK_1/2', 'QPSK_3/4', '16-QAM_1/2'.....
 
%% Find parameter N
    num_in_bits = length(x)*2;      % only QPSK,  fix it later!
    num_encoded_bytes = num_in_bits/8; 
   [NumModes, NumParams] = size(CTC_params.CTC_channel_coding_per_modulation); 
   N = -1; 
   for i = 2:NumModes
       if isequal( CTC_params.CTC_channel_coding_per_modulation{i,1}, Modulation_CodeRate) &&...
           (CTC_params.CTC_channel_coding_per_modulation{i,3} == num_encoded_bytes)
            N = CTC_params.CTC_channel_coding_per_modulation{i, 4}; 
            break; 
       end       
   end 
   
   if N==-1
       error('decode_DL_MAP_CTC:: invalid input vector size or invalid Modulation_CodeRate'); 
   end
%% Find parameters of interleaver m, J   
  [NumModes, NumParams] = size(CTC_params.Parameters_for_the_subblock_interleavers);
  m = -1; 
  for i=2:NumModes
    if CTC_params.Parameters_for_the_subblock_interleavers{i,2}==N
        m = CTC_params.Parameters_for_the_subblock_interleavers{i, 3}; 
        J = CTC_params.Parameters_for_the_subblock_interleavers{i, 4}; 
        break;
    end
  end

%% Convert the complex samples into hard bits
bits = reshape([real(x(1:N*2))<0; imag(x(1:N*2))<0; ], N*4, 1).'; % only 1/2 code rate!

A = bits(1:N); 
B = bits(N+1:N*2); 

parity = bits(N*2+1:end); 

%% Generate PRBS see 8.4.9.1 Randomization
sr = [0 1 1 0 1 1 1 0 0 0 1 0 1 0 1]; 

prbs = zeros(1, 2*N); 
for i=1:2*N
    rnd = bitxor(sr(14), sr(15)); 
    sr(2:15) = sr(1:14); 
    sr(1) = rnd; 
    prbs(i) = rnd; 
end

%% Build the deinterleaving table
tmp = subblock_interleaver((0:N-1), N, m, J); 
[tmp, deintr_tab] =sort(tmp); 

%% Deinterleave
decoded_bits = zeros(1, 2*N); 
decoded_bits(1:2:end) = A(deintr_tab); 
decoded_bits(2:2:end) = B(deintr_tab); 
decoded_bits = bitxor(prbs, decoded_bits); 
%% -













             


