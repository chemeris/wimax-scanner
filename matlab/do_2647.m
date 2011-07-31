% WiMAX decoding with Matlab
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



%% Initialize - load preambles data, etc
set_params
preambles
pilots

%% Get data
read_2647

%% Search for a frame start and process preamble
search_preamble_corr
[params.preamble_idx params.id_cell params.segment ] = ...
    detect_preamble(rcvdDL(theta:theta+params.Tb_samples-1), preamble_freq);
fprintf('Detected preamble %d (IDcell %d, segment %d)\n', params.preamble_idx, params.id_cell, params.segment);

%% Find frame symbols
search_syms

%% Do pre demodulation subcarrier de-randomization of OFDM symbols 0 and 1
sym_derand = DL0_derand(sym_fft, 10, params);

%% Equalize OFDM symbols 0 and 1
equalize_preamble
sym_fft_eq = equalize_dl_pusc(sym_derand(1,:), sym_derand(2,:), params, err_vec_preamble);
for k=1:2%length(sym_start)
%    scatterplot(sym_fft(k,:))
%    figure ; hold on ; plot(abs(fftshift(sym_fft(k,:)))); plot(abs(fftshift(1./err_vec)), 'r'); hold off
    scatterplot(sym_fft_eq(k,:)) ; xlim([-1 1]); ylim([-1 1])
%    figure ; plot(abs(fftshift(sym_fft_eq(k,:))))
end
% k=1 - pilot(2) (even)
% k=2 - pilot(1) (odd)

%% Extract FCH from OFDM symbols 0 and 1
FCH_qpsk_symbols = get_slot_data(sym_fft_eq, params.segment*10, ...
                                 params.FCH_repetitions, 2, params);
%% Demodulate 4 repetitions of FCH into an array of (soft) bits
FCH_demod_bits_best = FCH_demod(params.FCH_repetitions, FCH_qpsk_symbols);
%% De-interleave FCH (soft) bits
FCH_deinterleaved = deinterleave_QPSK(FCH_demod_bits_best, 16);

%% Decode FCH using CC-1/2 with tail biting
FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved, 'unquant');
% We can also use hard decision this way:
%FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved<0, 'hard');

%% Check FCH correctness, estimate BER, print FCH and exit.
% FCH is repeated twice for FFT sizes >128, so we can check that
% we decoded it correctly:
if ~all(FCH_decoded(1:24) == FCH_decoded(25:48))
    error('FCH decoding failed!');
end

% Estimate the number of incorrectly received bits by encoding FCH again
% and counting the number of different bits.
recode = encode_CC_tail_biting(FCH_decoded);
FCH_errors = sum(xor(FCH_deinterleaved<0, recode'));
fprintf('Number of error bits in FCH: %d\n', FCH_errors);
if 0
    figure ; hold on
    plot(FCH_deinterleaved<0, 'bo-');
    plot(recode, 'r.-');
    hold off; title('FCH_{deinterleaved} - original and recoded');
end
clear recode FCH_errors;

% Output FCH
fprintf('FCH: '); fprintf('%1d', FCH_decoded(1:24)); fprintf('\n');

% We're done with FCH, really.
