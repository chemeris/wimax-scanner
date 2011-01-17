% Extract FCH modulated data from OFDM symbols 0 and 1 of 802.16e
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

segment_start = params.segment*10;

% Rows enumerate physical carrier indexes (starting with 0)
% of sub-channels 0-3
% FCH_carriers_sym0 is for symbol 0, FCH_carriers_sym1 is for symbol 1
FCH_carriers_sym0 = [ get_DL_PUSC_subcarriers_PN(segment_start+0, params.id_cell, true, 0, params) ;
                      get_DL_PUSC_subcarriers_PN(segment_start+1, params.id_cell, true, 0, params) ;
                      get_DL_PUSC_subcarriers_PN(segment_start+2, params.id_cell, true, 0, params) ;
                      get_DL_PUSC_subcarriers_PN(segment_start+3, params.id_cell, true, 0, params) ];
FCH_carriers_sym1 = [ get_DL_PUSC_subcarriers_PN(segment_start+0, params.id_cell, true, 1, params) ;
                      get_DL_PUSC_subcarriers_PN(segment_start+1, params.id_cell, true, 1, params) ;
                      get_DL_PUSC_subcarriers_PN(segment_start+2, params.id_cell, true, 1, params) ;
                      get_DL_PUSC_subcarriers_PN(segment_start+3, params.id_cell, true, 1, params) ];
% Count left guard
FCH_carriers_sym0 = FCH_carriers_sym0 + params.N_left_guard_sc;
FCH_carriers_sym1 = FCH_carriers_sym1 + params.N_left_guard_sc;
% Count DC
FCH_carriers_sym0 = FCH_carriers_sym0 + (FCH_carriers_sym0>511);
FCH_carriers_sym1 = FCH_carriers_sym1 + (FCH_carriers_sym0>511);
                  
% FCH is repeated 4 times -> we save it to 4 arrays
% PS we add 1 to convert to Matlab indexing (starting from 1)
% TODO:: This damn standard doesn't tell us how subcarriers are numbered
% across symbols. So just do what seems more logical.
if 1
FCH_bits_interleaved_0 = [ sym_derand(1,FCH_carriers_sym0(1,:)+1) sym_derand(2,FCH_carriers_sym1(1,:)+1) ];
FCH_bits_interleaved_1 = [ sym_derand(1,FCH_carriers_sym0(2,:)+1) sym_derand(2,FCH_carriers_sym1(2,:)+1) ];
FCH_bits_interleaved_2 = [ sym_derand(1,FCH_carriers_sym0(3,:)+1) sym_derand(2,FCH_carriers_sym1(3,:)+1) ];
FCH_bits_interleaved_3 = [ sym_derand(1,FCH_carriers_sym0(4,:)+1) sym_derand(2,FCH_carriers_sym1(4,:)+1) ];
else
FCH_bits_interleaved_0(1:2:48) = sym_derand(1,FCH_carriers_sym0(1,:)+1);
FCH_bits_interleaved_0(2:2:48) = sym_derand(2,FCH_carriers_sym1(1,:)+1);
FCH_bits_interleaved_1(1:2:48) = sym_derand(1,FCH_carriers_sym0(2,:)+1);
FCH_bits_interleaved_1(2:2:48) = sym_derand(2,FCH_carriers_sym1(2,:)+1);
FCH_bits_interleaved_2(1:2:48) = sym_derand(1,FCH_carriers_sym0(3,:)+1);
FCH_bits_interleaved_2(2:2:48) = sym_derand(2,FCH_carriers_sym1(3,:)+1);
FCH_bits_interleaved_3(1:2:48) = sym_derand(1,FCH_carriers_sym0(4,:)+1);
FCH_bits_interleaved_3(2:2:48) = sym_derand(2,FCH_carriers_sym1(4,:)+1);
end

% Plot FCH I/Q data - all 4 repetitions
figure ; subplot(2,1,1) ; hold on
plot( real(FCH_bits_interleaved_0) ,'r.-')
plot( real(FCH_bits_interleaved_1) ,'g.-')
plot( real(FCH_bits_interleaved_2) ,'b.-')
plot( real(FCH_bits_interleaved_3) ,'k.-')
hold off
ylim([-1 1]) ; grid on ; title('FCH I values (4 repetitions)');
subplot(2,1,2) ; hold on
plot( imag(FCH_bits_interleaved_0) ,'r.-')
plot( imag(FCH_bits_interleaved_1) ,'g.-')
plot( imag(FCH_bits_interleaved_2) ,'b.-')
plot( imag(FCH_bits_interleaved_3) ,'k.-')
hold off
ylim([-1 1]) ; grid on ; title('FCH Q values (4 repetitions)');

%scatterplot(FCH_bits_interleaved_0) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(FCH_bits_interleaved_1) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(FCH_bits_interleaved_2) ; xlim([-1 1]); ylim([-1 1])
%scatterplot(FCH_bits_interleaved_3) ; xlim([-1 1]); ylim([-1 1])
