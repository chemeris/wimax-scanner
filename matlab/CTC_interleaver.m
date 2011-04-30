% CTC interleaver. This is a part of 802.16e CTC encoder. 
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
% Refer to "8.4.9.2.3.2 CTC interleaver" of IEEE 802.16-2009 for details. 


function y = CTC_interleaver(x, P)
% function y = CTC_interleaver(x, P)
% x - row vector of input data,  
% P = [P0,P1,P2,P3], the parameters of the interleaver, 
% refer to the table 502 for more details 

%% Step 1: Switch alternate couples.
N = length(x)/2; 

t = reshape(x.', 2, N); % make row vector of pairs
x = t;  
t = [t(2,:); t(1,:)];   % swap elements of pairs
x(:, 2:2:end,:) = t(:, 2:2:end); % replace odd numbered pairs (counting from 0)

x = reshape(x, N*2, 1).'; 

%% Step 2. Build the sequence permutation  for pairs
ps = zeros(1, N); % the permutation sequence for pairs
for j = 0:N-1
    switch (mod(j, 4))
        case 0,  ps(1+j) =  mod(P(1)*j + 1, N);             
        case 1,  ps(1+j) =  mod(P(1)*j + 1 +N/2+P(2), N);             
        case 2,  ps(1+j) =  mod(P(1)*j + 1 + P(3), N);             
        case 3,  ps(1+j) =  mod(P(1)*j + 1 +N/2+P(4), N);             
    end    
end

ps2 = zeros(1, N*2);    % the permutation sequence for bits
ps2(1:2:end) = ps*2+1;  % +1 for matlab indexing 
ps2(2:2:end) = ps*2+1+1; 

x = x(ps2);  


%% Swap elements of the even numbered pairs. This is like to step 1.
% It is not clear whether it is in fact. Some mismatch observed between
% definition of a sequence "u1" and sample of resulting sequence 
% "u2 = [(BP(0), AP(0)), (AP(1), BP(1)), (BP(2), AP(2))..".
% Refer to "8.4.9.2.3.2 CTC interleaver" of IEEE 802.16-2009
% t = reshape(x.', 2, N); 
% x = t; 
% t = [t(2,:); t(1,:)]; 
% x(:, 1:2:end,:) = t(:, 1:2:end);
% y = reshape(x, N*2, 1).'; 
% 

y = x;









