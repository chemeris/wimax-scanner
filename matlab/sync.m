GI_SIZE = 1024;  % длина Защитного Интервала (GI)

%max_length = 100 * sym_samples ; % Максимальная длина символа
%sig_in = rcvdDL(1:max_length);
sig_in = rcvdDL(42085:77e3);

%
    LEN = length(sig_in);
    corr = zeros(LEN,1);
    for i=1:LEN-params.N_fft
        corr(i) = conj(sig_in(i)) * sig_in(i+params.N_fft);
    end
 
% Moving Summation
    sum_corr = zeros(LEN,1);
    for i=1:LEN-GI_SIZE
        sum_corr(i) = abs(sum(corr(i:i+GI_SIZE-1)));
    end
    figure;plot(sum_corr); % debug

clear max_length GI_SIZE corr sig_in;

