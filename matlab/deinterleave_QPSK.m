function [deinterleaved] = deinterleave_QPSK(input, d)
% De-interleaving as per "8.4.9.3 Interleaving"

% The number of coded bits per subcarrier (for QPSK)
Ncpc = 2;
% Helping variable
s = Ncpc/2;
% The encoded block size
Ncbps = length(input);
% The modulo used for the permutation (fixed by the standard)
%d = 16;

% j is the index of a received bit before the first permutation
j = 0:Ncbps-1;

% mj is the index of the received bit after the first and before
% the second permutation
%mj = s*floor(j/s) + mod((j + floor(d * j / Ncbps)), s);
% For QPSK, where s = 1 this permutation degenerates:
mj = j;

% kj is the index of the received bit after the second permutation
kj = d*mj - (Ncbps - 1)*floor(d * mj / Ncbps);

% Get j(kj) from kj(j)
[~, idx] = sort(kj);
deinterleaved = input(idx);
