
function [decoded_info, quality] = CTC_Decoder(codeword, NumIter,Modulation_CodeRate, CTC_params)
% This implementation the turbo decoder of the CTC.
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
%[decoded_info, quality] = CTC_Decoder(codeword, NumIter, Modulation_CodeRate, CTC_params)
% Function parameters:
%   codeword - input row vector of metrics;
%   NumIter - number of iterations;
%   Modulation_CodeRate - valid valies is 'QPSK_1/2','QPSK_3/4',
%                                       '16-QAM_1/2','16-QAM_3/4','64-QAM_1/2',
%                                       '64-QAM_2/3','64-QAM_3/4','64-QAM_3/4',
%                                       '64-QAM_5/6','64-QAM_5/6'; 
%   CTC_params  - various tables fot CTC encoder(decoder). 
%
% Refer to "Turbo Coding, Turbo Equalisation and Space-Time Coding"
% by L. Hanzo, T.H. Liew, B.L. Yeap
% 
     
%% Find parameters N,P.
    num_in_bits = length(codeword);      
    num_encoded_bytes = num_in_bits/8; 
   [NumModes, NumParams] = size(CTC_params.CTC_channel_coding_per_modulation); 
   N = -1; 
   for i = 2:NumModes
       if isequal( CTC_params.CTC_channel_coding_per_modulation{i,1}, Modulation_CodeRate) &&...
           (CTC_params.CTC_channel_coding_per_modulation{i,3} == num_encoded_bytes)
            N = CTC_params.CTC_channel_coding_per_modulation{i, 4}; 
            P = CTC_params.CTC_channel_coding_per_modulation{i, 5}; 
            break; 
       end       
   end 
   
   if N==-1
       error('decode_DL_MAP_CTC:: invalid input vector size or invalid Modulation_CodeRate'); 
   end
%% Find parameters of interleaver m, J.   
  [NumModes, NumParams] = size(CTC_params.Parameters_for_the_subblock_interleavers);
  m = -1; 
  for i=2:NumModes
    if CTC_params.Parameters_for_the_subblock_interleavers{i,2}==N
        m = CTC_params.Parameters_for_the_subblock_interleavers{i, 3}; 
        J = CTC_params.Parameters_for_the_subblock_interleavers{i, 4}; 
        break;
    end
  end
  
  
%% Build the deinterleaving table.
tmp = subblock_interleaver((0:N-1), N, m, J); 
[tmp, deintr_tab] =sort(tmp); 


%% Prepare to deinterleaving.
tmp = zeros(1, N*6); 
% "offset"  depends on the parameter SPIDk
% In case DL-MAP offset(SPIDk) alway zero. 
% Refer to "8.4.9.2.3.4.4 Bit selection" eq. 117.
offset = 0;
tmp(1+offset: length(codeword)+offset) = codeword; 

A = tmp(1:N); 
B = tmp(N+1:2*N); 
Y1 = tmp(2*N+1:2:4*N); 
Y2 = tmp(2*N+2:2:4*N); 


%  In case SPIDk not equal zero, not tested yet.     
W1 = tmp(4*N+1:2:6*N); 
W2 = tmp(4*N+2:2:6*N);     
tmp = CTC_interleaver(1:2*N, P); 
[tmp, ctc_deintr_tab] = sort(tmp); 

%% Perform deinterleaving

 A = A(deintr_tab); 
 B = B(deintr_tab); 
 Y1 = Y1(deintr_tab); 
 Y2 = Y2(deintr_tab); 
 W1 = W1(deintr_tab); 
 W2 = W2(deintr_tab); 

 
 extrinsic_A =zeros(1,N); 
 extrinsic_B =zeros(1,N); 
 
%  test = zeros(1,2*N); 
%  test(1:2:2*N) = A; 
%  test(2:2:2*N) = B; 
 
 TailLength = 10; 
 
 for i=1:NumIter
     %% Decode component 1
     % Add extrincsic information from other decoder stage
     A1 = A + 0.5*extrinsic_A; 
     B1 = B + 0.5*extrinsic_B; 
     % Build branches, apply MAX LOG MAP
     branches = [A1; B1; Y1; W1].'; 
     branches = [branches(end-TailLength+1:end,:); branches; branches(1:TailLength,:) ];      
     AB_llr1 = CTC_max_log_map( branches ); 
     AB_llr1 = AB_llr1(TailLength*2+1: TailLength*2+2*N); 
%      figure(1); 
%      plot(1:2*N, AB_llr1, 1:2*N, test); 

     extrinsic_A = (AB_llr1(1:2:end).'-A1); 
     extrinsic_B = (AB_llr1(2:2:end).'-B1); 

     %% Decode component 2.
     % Add extrincsic information from other decoder stage.     
     A2 = 0.5*extrinsic_A + A; 
     B2 = 0.5*extrinsic_B + B; 

     % Interleaving for second stage decoder
     tmp(1:2:end) = A2; 
     tmp(2:2:end) = B2;
     tmp = CTC_interleaver( tmp(1:2*N) ,P); 
     % Build branches, apply MAX LOG MAP     
     branches = [tmp(1:2:end); tmp(2:2:end); Y2; W2].'; 
     branches = [branches(end-TailLength+1:end,:); branches; branches(1:TailLength,:) ];   
     tmp = CTC_max_log_map( branches ); 
     tmp = tmp(TailLength*2+1: TailLength*2+2*N); 
     
     % Deinterleaving output llrs to normal order
     AB_llr2 = tmp(ctc_deintr_tab); 
     
%      figure(i); 
%      plot(1:2*N, AB_llr2, 1:2*N, test); 

     extrinsic_A = (AB_llr2(1:2:end).'-A2); 
     extrinsic_B = (AB_llr2(2:2:end).'-B2); 
 end
 
 quality = 0;  
 decoded_info = (AB_llr2.'>0); 
 
 %% Generate PRBS see 8.4.9.1 Randomization.
sr = [0 1 1 0 1 1 1 0 0 0 1 0 1 0 1]; 

prbs = zeros(1, 2*N); 
for i=1:2*N
    rnd = bitxor(sr(14), sr(15)); 
    sr(2:15) = sr(1:14); 
    sr(1) = rnd; 
    prbs(i) = rnd; 
end

% test
% decoded_info = zeros(1, 2*N); 
% decoded_info(1:2:2*N) = A; 
% decoded_info(2:2:2*N) = B; 
% decoded_info = decoded_info > 0; 

% DeRandomization
decoded_info = bitxor(decoded_info, prbs); 
 
 
 
 
 
 
 
 
 
 
 
 




  