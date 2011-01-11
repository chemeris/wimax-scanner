n_left = -2;
n_right = 3;

% Correlation in time space
pr_corr = zeros(params.Tb_samples*(n_left+n_right)+1, 2047);
% Correlation in frequency space
%pr_corr_freq = zeros(params.Tb_samples*(n_left+n_right)+1, 1);
for n=-params.Tb_samples*n_left:params.Tb_samples*n_right

    sig_in = rcvdDL(theta+n:theta+n+params.Tb_samples-1);

    pr_corr(n+params.Tb_samples*n_left+1, :) = ...
       abs(xcorr(rcvdDL(theta:theta+params.Tb_samples-1)));
    %pr_corr_freq(n+params.Tb_samples*n_left+1) = sum(abs(preamble_freq(10,:)'.*fft(sig_in)));
end
clear n;
figure;
%hold on
%plot(-params.Tb_samples*n_left:params.Tb_samples*n_right,pr_corr/max(pr_corr), 'b')
%plot(-params.Tb_samples*n_left:params.Tb_samples*n_right,pr_corr_freq/max(pr_corr_freq), 'r')
%hold off
%plot(pr_corr');
