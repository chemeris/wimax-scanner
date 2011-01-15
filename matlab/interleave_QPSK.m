function [interleaved] = interleave_QPSK(input, d)
% Interleaving as per "8.4.9.3 Interleaving"

Ncbps = length(input);
Ncpc = 2;
k = 0 : Ncbps - 1;
mk = (Ncbps/d) * mod(k,d) + floor(k/d);

% In case of QPSK jk equals to mk
%s = ceil(Ncpc/2);
%jk = s * floor(mk/s) + mod(mk + Ncbps - floor(d * mk/Ncbps), s);
jk = mk;

[~,int_idx]=sort(jk);
interleaved = input(int_idx);
