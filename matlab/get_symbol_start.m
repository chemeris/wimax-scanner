function [sym_start_diff max_corr corr] = get_symbol_start(sig_in, params)
% Searching for CP correlating with a symbol end.
% This way we search for a frame start
len = length(sig_in) - params.Ts_samples;
corr = zeros(len,1);
for i=1:len
	corr(i) = sum( sig_in(i:i+params.Tg_samples) .* ...
                   conj(sig_in(i+params.Tb_samples:i+params.Tb_samples+params.Tg_samples)) );
end
clear i len;

% Timing and Fractioinal CFO
[max_corr sym_start_diff] = max(abs(corr));
