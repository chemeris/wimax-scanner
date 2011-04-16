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

function y = subblock_interleaver(x, N, m, J)
%function y = subblock_interleaver(x, N, m, J)
% x - input LLRs, y - output
% N, m, J     - from table 505
% reference    8.4.9.2.3.4.2 Subblock interleaving

% N = 96
% x = (0:N-1); 
% m = 5;
% J = 3; 

br_tab = bitrevorder(0:2^m-1); 

y = x; 
y(1:end) = -1; 
i=0; k=0; 
while i<N
    Tk = 2^m * mod(k, J) + br_tab( 1 + floor(k/J) );  %! matlab indexing in br_tab()
    if( Tk<N )
        y(i+1) = x(Tk+1); %! matlab indexing
        i = i + 1;     
    end
    k = k+1; 
end

%[dummy, tab] = sort(y); 

%x1 = y(tab)

