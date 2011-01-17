function [subcarriers] = get_DL_PUSC_subcarriers_PN(subchannel, DL_PermBase, ...
                                                    is_DL0, OFDM_symbol_num, ...
                                                    params)
% Returns an array of subcarriers Physical Numbers for 802.16e DL-PUSC.
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

% Accepted parameters:
%   subchannel      - from 0 to 29
%   DL_PermBase     - equals to IDcell for the first DL zone
%   is_DL0          - "1" for the first DL zone or ALLSC=0, "0" otherwise
%   OFDM_symbol_num - number of OFDM symbol (counting form 0 without preamble)
%   params          - global params and constants
% 
% Note: Return indicies are relative to the first data subcarrier, i.e.
%       does not include subcarriers of the guard band.

% Refer to "8.4.6.1.2.1 Symbol structure for PUSC" of IEEE 802.16-2009 for
% details. Though it's written in so unclear language that I recommend
% you to read some textbook on the topic to understand this. I personally
% used Byeong Gi Lee, Sunghyun Choi "Broadband Wireless Access and Local
% Networks - Mobile WiMAX and WiFi".

%% Calculate parameters
N_subcarriers = params.N_sc_per_subchannel;
N_clusters = params.PUSC_N_clusters;

% Major Group number
major_group = 2*floor(subchannel/10) + floor(mod(subchannel, 10)/6);
% Number of subchannels in this major group
if mod(major_group,2)==0 , N_subch_MG = 6; else N_subch_MG = 4 ; end
% Permutation sequence
if N_subch_MG==4, p_s = params.PermutationBase4; else p_s = params.PermutationBase6 ; end

% Prepare renumbering
renumbering_LN = params.PUSC_renumbering;
if ~is_DL0
    renumbering_LN = renumbering_LN(1+mod((0:N_clusters-1) + 13*DL_PermBase, N_clusters));
end
[~, renumbering_PN] = sort(renumbering_LN);
renumbering_PN = renumbering_PN-1;

% We generate subchannel PNs for all 24 subcarriers.
subcarrier_LN = 0:N_subcarriers-1;

%% Subcarrier permuation.
% Refer to "8.4.6.1.2.2.2 Partitioning of data subcarriers into subchannels
% in DL FUSC"
% n_k = (k + 13 * s) mod Nsubcarriers
n_k = mod(subcarrier_LN+13*subchannel, N_subcarriers);
% Subcarrier LN in major group (after permutation), in the range 0..143
subcarrier_LN_permuted = N_subch_MG*n_k + mod(p_s(1+mod(n_k+subchannel, N_subch_MG)) + DL_PermBase, N_subch_MG);

%% Find cluster
% Cluster Logical Number (within major group)
cluster_LN_in_MG = floor(subcarrier_LN_permuted/12);
% Cluster absolute Logical Number
cluster_LN = floor(major_group/2)*20 + mod(major_group,2)*12 + cluster_LN_in_MG;
% Cluster Physical Number
cluster_PN = renumbering_PN(cluster_LN+1);

%% Find subcarrier
% Subcarrier index within cluster (not counting pilots)
subcarrier_in_cluster = mod(subcarrier_LN_permuted, 12);
% Physical subcarrier index (not counting pilots)
subcarrier_PN = cluster_PN*12 + subcarrier_in_cluster;
% Subcarrier index within cluster (counting pilots)
if mod(OFDM_symbol_num, 2)==0
    % Even symbols
    subcarrier_in_cluster_full = subcarrier_in_cluster + ...
                                 floor((subcarrier_in_cluster+8)/12) + ...
                                 floor((subcarrier_in_cluster+5)/12);
else
    % Odd symbols
    subcarrier_in_cluster_full = subcarrier_in_cluster + ...
                                 1 + ...
                                 floor((subcarrier_in_cluster+1)/12);
end
% Physical subcarrier index (counting pilots)
subcarrier_PN_full = cluster_PN*14 + subcarrier_in_cluster_full;
% Physical subcarrier index (counting pilots and DC)
subcarrier_PN_full_DC = subcarrier_PN_full+(subcarrier_PN_full>512-params.N_left_guard_sc);

%subcarriers = subcarrier_PN;
subcarriers = subcarrier_PN_full;
%subcarriers = subcarrier_PN_full_DC;
