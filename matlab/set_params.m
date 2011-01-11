% Primitive parameters
params.N_fft = 1024;
params.BW = 10e6; % Bandwidth
params.n = 28/25; % Oversampling
params.G = 1/8; % Guard interval

% WiMAX specific primitive parameters
params.N_sym = 48; % Number of data symbols in a frame.
params.N_pilot_sc = 120; % Number of pilot sub-carriers
params.N_data_sc = 720; % Number of data sub-carriers
% Number of all meaningful sub-carriers plus DC
params.N_total_sc = params.N_data_sc+params.N_pilot_sc+1;
params.N_left_guard_sc = 92; % Number of Guard Subcarriers, Left
params.N_right_guard_sc = 91; % Number of Guard Subcarriers, Right
params.sc_first = params.N_left_guard_sc+1; % First meaningful sub-carrier (after fftshift)
params.sc_last = params.N_fft-params.N_right_guard_sc; % Last meaningful sub-carrier (after fftshift)
params.PUSC_cluster_carriers = 14; % Number of carriers per cluster
params.PUSC_N_clusters = 60; % Number of clusters (per OFDM symbol)
% Renumbering sequence - used to renumber clusters before allocation to subchannels.
params.PUSC_renumbering = [6, 48, 37, 21, 31, 40, 42, 56, 32, 47, 30, 33, 54, 18, ...
                           10, 15, 50, 51, 58, 46, 23, 45, 16, 57, 39, 35, 7, 55, ...
                           25, 59, 53, 11, 22, 38, 28, 19, 17, 3, 27, 12, 29, 26, ...
                           5, 41, 49, 44, 9, 8, 1, 13, 36, 14, 43, 2, 20, 24, 52, ...
                           4, 34, 0];
% Number of subchannels
params.N_subchannels = 30;
% Number of data subcarriers in each symbol per subchannel
params.N_sc_per_subchannel = 24;
% PermutationBase6 (for 6 subchannels)
params.PermutationBase6 = [3,2,0,4,5,1];
% PermutationBase4 (for 4 subchannels)
params.PermutationBase4 = [3,0,2,1];

% Derived parameters
params.Fs = round(params.BW*params.n);    % Sampling frequency
%params.Fs = params.Fs*1152/1153
%params.Fs = 11265000;    % Sampling frequency
params.deltaF = params.Fs / params.N_fft; % Subcarrier spacing
params.Tb = 1/params.deltaF;       % useful symbol time, seconds
params.Tg = params.Tb*params.G;    % cyclic prefix length, seconds
params.Ts = params.Tb + params.Tg; % full OFDMA symbol time, seconds

% Derived parameters (second order)
params.Tb_samples = round(params.Tb*params.Fs); % useful symbol time, samples
params.Tg_samples = round(params.Tg*params.Fs); % cyclic prefix length, samples
params.Ts_samples = round(params.Ts*params.Fs); % full OFDMA symbol time, samples
