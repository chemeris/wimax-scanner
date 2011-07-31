% CTC Constituent Encoder. This is a part of 802.16e CTC encoder. 
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
function [ Y, W, end_state ] = CTC_ConstituentEncoder( AB, start_state )
% function [ Y, W, state ] = CTC_ConstituentEncoder( AB, start_state )
% start_state is decimal value range 0..7
 
% convert decimal to binary vector

if (start_state < 0) || (start_state>7)
    error('start_state is out of range'); 
end

S = (dec2bin(start_state,3)=='1'); 
Snew = S; %next state of encoder
Y = zeros(1, length(AB)/2); 
W = zeros(1, length(AB)/2); 
N = length(AB)/2 ; 
for i=0:N-1 
    a = AB(i*2+1); 
    b = AB(i*2+2); 
% Refer to "Figure 289—CTC encoder".
% calculate next state of encoder
    Snew(1) = bitxor(bitxor( a, b), bitxor(S(1), S(3))); 
    Snew(2) = bitxor(S(1), b); 
    Snew(3) = bitxor(S(2), b); 
% calculate parity bits        
    Y(i+1) = bitxor( bitxor(Snew(1), S(2)), S(3)); 
    W(i+1) = bitxor( Snew(1), S(3) ); 
% update encoder state    
    S = Snew;  
end

end_state =  S(1)*4 + S(2)*2 + S(3); 




end

