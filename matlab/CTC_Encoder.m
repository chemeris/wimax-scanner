% CTC Encoder. 
%
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
%
% Refer to "8.4.9.2.3.1 CTC encoder" of IEEE 802.16-2009 for details.  


function [encoded_AB]  = CTC_Encoder(AB, Modulation_CodeRate, CTC_params )
%function [encoded]  = CTC_Encoder()
% Refer to table 504.
% Note! Range of Nmod7 is 1 to 6. 
%       Range of Circulation Scate (S) is 0 to 7 
 Sc_lookup_table = [0 6 4 2 7 1 3 5
                    0 3 7 4 5 6 2 1
                    0 5 3 6 2 7 1 4
                    0 4 1 5 6 2 7 3
                    0 2 5 7 1 3 4 6
                    0 7 6 1 3 4 5 2 ]; 

%N = length(AB)/2;       
%% Find encoder parameters
   num_in_bytes = fix(length(AB)/8); 
   [NumModes, NumParams] = size(CTC_params.CTC_channel_coding_per_modulation); 
   N = -1; 
   for i = 2:NumModes
       if isequal( CTC_params.CTC_channel_coding_per_modulation{i,1}, Modulation_CodeRate) &&...
           (CTC_params.CTC_channel_coding_per_modulation{i,2} == num_in_bytes)
            num_out_bytes = CTC_params.CTC_channel_coding_per_modulation{i, 3}; 
            N = CTC_params.CTC_channel_coding_per_modulation{i, 4}; 
            P = CTC_params.CTC_channel_coding_per_modulation{i, 5}; 
            break; 
       end       
   end 
   
   if N==-1
       error('CTC_Encoder:: invalid input vector size or invalid Modulation_CodeRate'); 
   end
   
  [NumModes, NumParams] = size(CTC_params.Parameters_for_the_subblock_interleavers);
  m = -1; 
  for i=2:NumModes
    if CTC_params.Parameters_for_the_subblock_interleavers{i,2}==N
        m = CTC_params.Parameters_for_the_subblock_interleavers{i, 3}; 
        J = CTC_params.Parameters_for_the_subblock_interleavers{i, 4}; 
        break;
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

AB = bitxor(AB, prbs); 

AB_interleaved =  CTC_interleaver(AB, P); 
Nmod7 = mod(N, 7); 

[~, ~, S0N_1] = CTC_ConstituentEncoder(AB, 0);
S = Sc_lookup_table(Nmod7, S0N_1+1); 

[Y1, W1, Slast1] = CTC_ConstituentEncoder(AB, S);
%Sdiff1 = S - Slast1 

[~, ~, S0N_1] = CTC_ConstituentEncoder(AB_interleaved, 0);
S = Sc_lookup_table(Nmod7, S0N_1+1);

[Y2, W2, Slast2] = CTC_ConstituentEncoder(AB_interleaved, S);

%Sdiff2 = S - Slast2 

%   if N==96
%         m=5; J=3; 
%   end

Y1 = subblock_interleaver(Y1, N, m, J); 
Y2 = subblock_interleaver(Y2, N, m, J); 

parity_bits = zeros(1, N*2); 
parity_bits(1:2:end) = Y1; 
parity_bits(2:2:end) = Y2; 

%% Return only as many parity bits as we need to achieve requested coding speed 
num_parity_bits = (num_out_bytes - num_in_bytes)*8;
parity_bits = parity_bits (1:num_parity_bits);

encoded_AB = [subblock_interleaver(AB(1:2:end), N, m, J), subblock_interleaver(AB(2:2:end), N, m, J),  parity_bits];


