function [bits] = FCH_demod(FCH_bits_interleaved_0, FCH_bits_interleaved_1, ...
                            FCH_bits_interleaved_2,FCH_bits_interleaved_3)
% Demodulate FCH into soft bits (unquantized real, negative for 1, positive for 0).
% To increase decoding quality we choose the most confident values among
% all 4 repetitions as resulting soft bit values.
%
% Refer to "8.4.9.4 Modulation" and "8.4.9.5 Repetition"

% Number of bits in demodulated FCH
FCH_demod_bits_bits_n = length(FCH_bits_interleaved_0)*2;

% Perform demodulation
FCH_demod_bits = zeros(4, FCH_demod_bits_bits_n);
FCH_demod_bits(1,:) = demodulate_QPSK(FCH_bits_interleaved_0);
FCH_demod_bits(2,:) = demodulate_QPSK(FCH_bits_interleaved_1);
FCH_demod_bits(3,:) = demodulate_QPSK(FCH_bits_interleaved_2);
FCH_demod_bits(4,:) = demodulate_QPSK(FCH_bits_interleaved_3);

clear h ;

[~, max_idx] = max(abs(FCH_demod_bits));
FCH_demod_bits_best = zeros(1, FCH_demod_bits_bits_n);
for j=1:FCH_demod_bits_bits_n
    FCH_demod_bits_best(j) = FCH_demod_bits(max_idx(j), j);
end
clear max_val max_idx j ;

%FCH_demod_bits_best_hard = double(FCH_demod_bits_best<0);
%FCH_demod_bits_best_hard = FCH_demod_bits_best_hard(end:-1:1);

bits = FCH_demod_bits_best;

% Plot
if 1
figure ; hold on ; 
plot(FCH_demod_bits(1,:), 'r.-');
plot(FCH_demod_bits(2,:), 'g.-');
plot(FCH_demod_bits(3,:), 'b.-');
plot(FCH_demod_bits(4,:), 'c.-');
plot(FCH_demod_bits_best, 'ko-', 'LineWidth',2);
hold off ; grid on ; title('FCH soft symbols (4 repetitions and the best curve)');
end
