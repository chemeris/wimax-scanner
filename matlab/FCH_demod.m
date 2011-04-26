function [bits_best] = FCH_demod(num_repetitions, symbols_in)
% Demodulate FCH into soft bits (unquantized real, negative for 1, positive for 0).
% Copyright (C) 2011  Alexander Chemeris
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
% USA

% To increase decoding quality we choose the most confident values among
% all 4 repetitions as resulting soft bit values.
%
% Refer to "8.4.9.4 Modulation" and "8.4.9.5 Repetition" for details.

% Number of bits in demodulated QPSK signal
bits_n = length(symbols_in(1,:))*2;

% Perform demodulation
bits = zeros(num_repetitions, bits_n);
for j=1:num_repetitions
    bits(j,:) = demodulate_QPSK(symbols_in(j,:));
end
clear h ;

[~, max_idx] = max(abs(bits));
bits_best = zeros(1, bits_n);
for j=1:bits_n
    bits_best(j) = bits(max_idx(j), j);
end
clear max_val max_idx j ;

% Plot
if 1
figure ; hold on ; 
colors = ['r', 'g', 'b', 'c'];
for j=1:num_repetitions
    plot(bits(j,:), 'Color', colors(j), 'Marker', '.');
end
plot(bits_best, 'ko-', 'LineWidth',2);
hold off ; grid on ; title('Soft symbols (repetitions and the best curve)');
end
