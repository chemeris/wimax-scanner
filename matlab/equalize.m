%PN_index = 11; %  Preamble Index
sp_ref = preamble_freq(PN_index,:); % Ideal pilot signal
X = find(sp_ref ~= 0); % индексы поднесущих пилот-сигнала
sp_ref = sp_ref(sp_ref ~= 0); 

%% Get received signal
sig_in = fft(rcvdDL(theta:theta+params.Tb_samples-1))'; % Received pilot signal
sp_rx = sig_in(X); % Received pilot signal
 
%% Calculate erorror over pilot signals
sp_err = sp_ref ./ sp_rx; 
 
%% Interpolate error voctor over all sub-carriers
err_vec = interp1(X, sp_err, 1:length(sig_in), 'spline'); 
 
%% Correct signal
rx_sym = sig_in .* err_vec;
 
%% Do plots
figure; hold on ; plot(abs(fftshift(sig_in))); plot(abs(fftshift(1./err_vec)), 'r'); hold off
figure; plot(abs(fftshift(rx_sym)));
%scatterplot(rx_sym);
