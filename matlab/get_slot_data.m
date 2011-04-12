function [symbols] = get_slot_data(ofdm_syms, segment_start, num_repetitions, ...
                                   num_ofdm_symbols, params)
% Get modulated slot data from 802.16e OFDM symbols.
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

% Refer to "8.4.6.1.2.1 Symbol structure for PUSC" of IEEE 802.16-2009 for
% details. Though it's written in so unclear language that I recommend
% you to read some textbook on the topic to understand this. I personally
% used Byeong Gi Lee, Sunghyun Choi "Broadband Wireless Access and Local
% Networks - Mobile WiMAX and WiFi".

% Slot is repeated num_repetitions times.
% This damn standard doesn't tell us how subcarriers are numbered
% across symbols. But this method seems to work - data from different
% symbols is just concatenated in the same order as symbols.
symbols = zeros(num_repetitions, 2*params.N_sc_per_subchannel);
for j=1:num_repetitions
    for s=0:num_ofdm_symbols-1
        % Rows enumerate physical carrier indexes (starting with 0)
        carriers = get_DL_PUSC_subcarriers_PN(segment_start+j-1, params.id_cell, true, s, params);
        % Add left guard
        carriers = carriers + params.N_left_guard_sc;
        % Add DC
        carriers = carriers + (carriers>511);
        % We add 1 to convert to Matlab indexing (starting from 1)
        symbols(j,params.N_sc_per_subchannel*s+1:params.N_sc_per_subchannel*(s+1)) = ...
                ofdm_syms(s+1,carriers+1);
    end
end
if 0
    % Plot I/Q data - all repetitions
    colors = ['r', 'g', 'b', 'k', 'c', 'y'];
    figure ; subplot(2,1,1) ; hold on
    for j=1:num_repetitions
        plot(real(symbols(j,:)), 'Color', colors(j), 'Marker', '.');
    end
    hold off
    ylim([-1 1]) ; grid on ; title('FCH I values (all repetitions)');
    subplot(2,1,2) ; hold on
    for j=1:num_repetitions
        plot(imag(symbols(j,:)), 'Color', colors(j), 'Marker', '.');
    end
    hold off
    ylim([-1 1]) ; grid on ; title('FCH Q values (all repetitions)');
end

%scatterplot(symbols(1,:)) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(symbols(2,:)) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(symbols(3,:)) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(symbols(4,:)) ; xlim([-1 1]); ylim([-1 1])
