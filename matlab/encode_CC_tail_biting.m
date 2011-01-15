function [encoded] = encode_CC_tail_biting(data)
% Encode 802.16e Convolutional Coding 1/2 rate with tail-biting.
% Copyright (C) 2011  Alexander Chemeris
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

% Refer to "8.4.9.2.1 Convolutional coding (CC)" of IEEE 802.16-2009 for
% details.

% The octal representation of the polynomials are
G1 = 171;       % 1+D+D^2+D^3+D^6
G2 = 133;       % 1+D^2+D^3+D^5+D^6
constLen = 7;   % Constraint length
rateInv = 2;    % Inverse of code rate

% Create the trellis that represents the convolutional code
convCode = poly2trellis(constLen, [G1 G2]);

% First append last 6 bits to the beginning.
c = [data(end-(constLen-2):end); data];
% Encode the appended block with a regular convolutional encoder
C = convenc(c, convCode);
% Discard the encoded bits resulting from the first 6 appended bits
encoded = C((constLen-1)*rateInv+1:end);
