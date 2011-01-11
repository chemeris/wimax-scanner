% Implemented as in "Research In Initial Downlink Synchronization For TDD
% Operation Of IEEE 802.16E OFDMA", 2006, Guo-Wei Ji, David W. Lin, and
% Kun-Chien Hung
%
% And then improved :)

max_length = 100 * params.Ts_samples ; % Maximum frame time
sig_in = rcvdDL(1:max_length);

% Theta is a index of the first sample of the frame
% max_corr is a value of correlation at the index "theta" (just for debug)
% corr is an array of correlation (just for debug)
[theta max_corr corr] = get_symbol_start(sig_in, params);
% Plot timing
figure; hold on ;
plot(abs(corr)); % Plot abs(lambda) to find its maximum
plot(theta, max_corr, 'ro');
hold off;

% Skip Cyclic Prefix
% Initially Theta points to the Cyclic Prefix start
theta = theta + params.Tg_samples;

% ==== Completely untested part start =====
% Calculate fractional part of the Carrier Frequency Offset
cfo_fraq = -angle(corr(theta))/2/pi;
% Compensate CFO
rcvdDL = rcvdDL * exp(-1i*(2*pi*cfo_fraq));
% ==== Completely untested part end =====

clear max_length sig_in max_corr;
