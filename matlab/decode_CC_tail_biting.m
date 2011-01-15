function [decoded] = decode_CC_tail_biting(data, type)

% The octal representation of the polynomials are
G1 = 171;       % 1+D+D^2+D^3+D^6
G2 = 133;       % 1+D^2+D^3+D^5+D^6
constLen = 7;   % Constraint length
rateInv = 2;    % Inverse of code rate

% Create the trellis that represents the convolutional code
convCode = poly2trellis(constLen, [G1 G2]);

% Run the traceback over the whole block
tbLen = length(data)/rateInv;
% Decode two copies of the received block consecutively and select the
% outputs from the second copy
decoded = vitdec([data' ; data'], convCode, tbLen, 'trunc', type);
%decoded = vitdec([data' ; data'], convCode, tbLen, 'trunc', 'unquant');
%decoded = vitdec([data' ; data'], convCode, tbLen, 'trunc', 'soft', 1);
%decoded = vitdec([data' ; data'], convCode, tbLen, 'trunc', 'hard');
decoded = decoded(tbLen+1:end, 1);

figure ; hold on
plot(decoded(1:24), 'bo-');
plot(decoded(25:48), 'r.-');
hold off

