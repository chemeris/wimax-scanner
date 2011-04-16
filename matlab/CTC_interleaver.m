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
% 8.4.9.2.3.2 CTC interleaver


function y = CTC_interleaver(x, P)
%function y = CTC_interleaver(x, P)
% x - row vector of input data,  
%P = [P0,P1,P2,P3] from table 502

%% step 1
% P = [13, 24, 0, 24]; 
% x = (0:95)
x0 = x; 
N = length(x)/2; 

t = reshape(x.', 2, N); 
x = t; 
t = [t(2,:); t(1,:)]; 

x(:, 2:2:end,:) = t(:, 2:2:end);

x = reshape(x, N*2, 1).'; 

%% step 2
ps = zeros(1, N); % the permutation sequence for pairs
for j = 0:N-1
    switch (mod(j, 4))
        case 0,  ps(1+j) =  mod(P(1)*j + 1, N);             
        case 1,  ps(1+j) =  mod(P(1)*j + 1 +N/2+P(2), N);             
        case 2,  ps(1+j) =  mod(P(1)*j + 1 + P(3), N);             
        case 3,  ps(1+j) =  mod(P(1)*j + 1 +N/2+P(4), N);             
    end    
end

ps2 = zeros(1, N*2); % the permutation sequence for bits
ps2(1:2:end) = ps*2+1; % +1 for matlab indexing 
ps2(2:2:end) = ps*2+1+1; 

x = x(ps2);  


%% swap   even numbered pairs. Is this really needed ?
t = reshape(x.', 2, N); 
x = t; 
t = [t(2,:); t(1,:)]; 

x(:, 1:2:end,:) = t(:, 1:2:end);

x = reshape(x, N*2, 1).'; 











