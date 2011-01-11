function [subcarrier_PUSC_permutation] = gen_PUSC_permutation(DL_PermBase, params)
% Nsubchannels = 6 (for even-numbered major groups) or 4 (for odd-numbered
% major groups)
Nsubch = 6;
Nsc = params.N_sc_per_subchannel;

% index number of a subchannel
s = 0:Nsubch-1;
% subcarrier-in-subchannel index
k = 0:Nsc-1;

% nk(k, s)
nk = zeros(numel(k), numel(s));
for j=1:Nsc % iterate over k
    nk(j,:) = mod((j-1 + 13 * s), Nsc);
end
clear j;

% "ps[j] is the series obtained by rotating basic permutation sequence
%  cyclically to the left s times."
% So, basically it is ps(s+j), where ps is:
ps = [params.PermutationBase6 params.PermutationBase6];

% subcarrier(k, s)
subcarrier_PUSC_permutation = zeros(numel(k), numel(s));
for j=1:Nsubch % iterate over s
    subcarrier_PUSC_permutation(:,j) = Nsubch * nk(:,j)' + ...
        mod( ps(j+mod(nk(:,j), Nsubch)) + DL_PermBase, Nsubch);
end
