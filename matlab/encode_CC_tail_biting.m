function [encoded] = encode_CC_tail_biting(data)

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
