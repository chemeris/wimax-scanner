sig_in = rcvdDL(theta:theta+params.Tb_samples-1);
%sig_in = sig_in * exp(-1i*(2*pi*cfo_fraq));

pr_corr = zeros(size(preamble_time, 1), 1);
pr_corr_freq = zeros(size(preamble_time, 1), 1);
sig_in_freq = fft(sig_in);
for j = 1:size(preamble_time, 1)
    pr_corr(j) = sum(abs(preamble_time(j,:)'.*sig_in));
    pr_corr_freq(j) = abs(sum(preamble_freq(j,:)'.*sig_in_freq));
end
clear i sig_in_freq;

% Find preamble index
[pr_corr_max PN_index] = max(pr_corr_freq);
params.preamble_idx = PN_index-1;
% Find IDcell and segment
if params.preamble_idx > 95
    params.id_cell = mod(params.preamble_idx, 32);
    params.segment = floor(params.preamble_idx/32);
else
    params.id_cell = params.preamble_idx-96;
    params.segment = mod(params.preamble_idx-96, 3);
end

% Plot pr_corr and pr_corr_freq
figure;
hold on
corr_scale = max(pr_corr-mean(pr_corr));
plot((pr_corr-mean(pr_corr))/corr_scale, 'b-')
plot((pr_corr_freq-mean(pr_corr_freq))/max(pr_corr_freq-mean(pr_corr_freq)), 'g')
plot(PN_index, (pr_corr_max-mean(pr_corr))/corr_scale, 'ro')
hold off
clear pr_corr_max corr_scale PN_index ;
