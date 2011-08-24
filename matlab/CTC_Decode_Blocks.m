function [info, recoded_info, num_errors] = CTC_Decode_Blocks(x,  Modulation_CodeRate, CTC_params) 
% Divide the input into blocks, compute the metric bits, 
% perform the turbo decoding.
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
% [info, recoded_info, num_errors] = CTC_Decode_Blocks(x,  Modulation_CodeRate, CTC_params)
% Function parameters:
%   x - input row vector of complex samples,
%   Modulation_CodeRate - valid valies is 'QPSK_1/2','QPSK_3/4',
%                                       '16-QAM_1/2','16-QAM_3/4','64-QAM_1/2',
%                                       '64-QAM_2/3','64-QAM_3/4','64-QAM_3/4',
%                                       '64-QAM_5/6','64-QAM_5/6'; 
%   CTC_params  - various tables for CTC encoder(decoder). 
% Function outputs:
%   info - decoded and descrambled bits of information
%   recoded_info - scrambled and encoded info



n = fix(length(x)/48); % number of slots
if n*48~=length(x)
    error('Length x must be divisible by 48'); 
end

% Refer to "Table 501 Encoding slot concatenation for different rates in CTC"    
if (isequal(Modulation_CodeRate, 'QPSK_1/2'))
    j = 10;         
elseif (isequal(Modulation_CodeRate, 'QPSK_3/4'))
    j = 6;         
else    
    error([Modulation_CodeRate, ' not implemented yet']); 
end
blks_size = []; % blocks size (in slots)


%%  Find number and sizes of the blocks
%Refer to Table 500 Slots concatenation rule for CTC.
k = floor(n/j); 
m = mod(n,j); 
if n==7
    blks_size = [4,3]; 
else
    if n<=j
        blks_size = n; 
    else
        if( m==0)
            blks_size =j*ones(1, k); 
        else
            Lb1 = ceil((m+j)/2);
            Lb2 = floor((m+j)/2);
            if (Lb1 == 7) || (Lb2 == 7)
                Lb1 = Lb1 + 1; Lb2 = Lb2 - 1; 
            end
             blks_size = [j*ones(1,k-1), Lb1, Lb2];            
        end            
    end
end

%% Decode all blocks
pos = 1; 
info = []; 
recoded_info = []; 
num_errors = 0; 
for i =1: length(blks_size)
    tmp = x(pos:pos-1+blks_size(i)*48); 
    pos = pos + blks_size(i)*48; 
    bits_metrics = reshape([-real(tmp); -imag(tmp); ], length(tmp)*2, 1).'; % only for QPSK!
    [decoded_block, quality] = CTC_Decoder(bits_metrics, 4, Modulation_CodeRate, CTC_params); 
    recoded_block = CTC_Encoder(decoded_block, Modulation_CodeRate,  CTC_params);    
    recoded_info = [recoded_info, recoded_block]; 
    hard_bits = reshape([real(tmp)<0; imag(tmp)<0; ], length(tmp)*2, 1).'; %  only for QPSK!
    num_errors =  num_errors + sum(abs(recoded_block-hard_bits)); 
    
    info = [info, decoded_block]; 
end




