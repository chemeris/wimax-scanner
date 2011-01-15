% Search for OFDM symbols start in a 802.16e frame.
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

% Refer to "8.4.2 OFDMA symbol description, symbol parameters and
% transmitted signal" of IEEE 802.16-2009 for details.

% Loop through symbols in the frame
sym_dt = 10; % Maximum symbol start error in samples
sym_start_next = theta; % Start from preamble symbol
sym_num = params.N_sym;
sym_start = zeros(sym_num, 1);
sym_data = zeros(sym_num, params.Tb_samples);
sym_fft = zeros(sym_num, params.Tb_samples);
sym_fft_eq = zeros(sym_num, params.Tb_samples);
for k=1:sym_num
    % Move sym_start to the next symbol
    if 1
        % For now we use fixed symbol length. This leads to phase drift
        % on decoding. We should be smarter.
        sym_start_next = sym_start_next + params.Ts_samples;
    else
        sym_start_next = sym_start_next + params.Tb_samples - sym_dt;
        sig_in = rcvdDL(sym_start_next:sym_start_next+2*sym_dt+params.Ts_samples);
        sym_start_diff = get_symbol_start(sig_in, params);
        % Set actual frame start and skip CP
        sym_start_next = sym_start_next + sym_start_diff + params.Tg_samples;
        sym_start_next = sym_start_next + params.Tg_samples + sym_dt;
        clear sym_start_diff sig_in;
    end

    % Save symbol
    sym_start(k) = sym_start_next;
    sym_data(k,:) = rcvdDL(sym_start_next:sym_start_next+params.Tb_samples-1);
    sym_fft(k,:) = fft(sym_data(k,:))';
    % Equalize symbol
    sym_fft_eq(k,:) = sym_fft(k,:) .* err_vec;
end
clear sym_start_next k sym_dt sym_num;
