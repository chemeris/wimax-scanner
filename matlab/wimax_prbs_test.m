
% Test vector from the Standard section 8.4.9.4.1 
pn = [ 1 0 1 0 1 0 1 0 1 0 1 ];

% Note that it starts repeating after 2^11-1 iterations
n_iter = 50;
pn_out = zeros(n_iter,1);
for i = 1:n_iter
    [pn_bit pn] = wimax_prbs(pn);
    pn_out(i) = pn_bit;
end
