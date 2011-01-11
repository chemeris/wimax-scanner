function [out_bit new_pn] = wimax_prbs(pn)
%Bit length of the shiftRegister
pn_length = 11;

% Pull the output of the register (the last bit)
out_bit = pn(pn_length);

% Feedback (modulo 2)
c = xor(pn(pn_length),pn(pn_length-2));

% Insert that value in the beginning and shift the rest to the right
new_pn = [c pn(1:pn_length-1)];
