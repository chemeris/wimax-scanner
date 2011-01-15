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
detect_preamble
equalize
gen_subcarrier_prbs
subcarrier_PUSC_permutation = gen_PUSC_permutation(params.id_cell, params);


%% Find frame symbols
search_syms
for k=1:6%length(sym_start)
%    scatterplot(sym_fft(k,:))
%    figure ; hold on ; plot(abs(fftshift(sym_fft(k,:)))); plot(abs(fftshift(1./err_vec)), 'r'); hold off
    scatterplot(sym_fft_eq(k,:)) ; xlim([-1 1]); ylim([-1 1])
%    figure ; plot(abs(fftshift(sym_fft_eq(k,:))))
end
% k=1 - pilot(2) (even)
% k=2 - pilot(1) (odd)

%% Do pre demodulation subcarrier de-randomization of OFDM symbols 0 and 1
DL0_derand

%% Extract FCH from OFDM symbols 0 and 1
DL0_extract_FCH
%% Demodulate 4 repetitions of FCH into an array of (soft) bits
FCH_demod_bits_best = FCH_demod(FCH_bits_interleaved_0, FCH_bits_interleaved_1, ...
                                FCH_bits_interleaved_2,FCH_bits_interleaved_3);
%% De-interleave FCH (soft) bits
FCH_deinterleaved = deinterleave_QPSK(FCH_demod_bits_best, 16);
%FCH_deinterleaved = (1-2*encode_CC_tail_biting(rand(96,1)>0.5))'*0.7;
%FCH_deinterleaved = (1-2*(rand(96,1)>0.5))'*0.7;

%% Decode FCH using CC-1/2 with tail biting
%FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved, 'unquant');
FCH_decoded = decode_CC_tail_biting(FCH_deinterleaved<0, 'hard');
t_hard = decode_CC_tail_biting(FCH_deinterleaved<0, 'hard');
all(FCH_decoded == t_hard)
figure ; hold on
plot(FCH_decoded, 'bo-');
plot(t_hard, 'r.-');
hold off; title('FCH_{decoded} and t_{hard}');
%spy([ t_hard' ; FCH_decoded' ; xor(t_hard, FCH_decoded)' ])

recode = encode_CC_tail_biting(t_hard);
figure ; hold on
plot(FCH_deinterleaved<0, 'bo-');
plot(recode, 'r.-');
hold off; title('FCH_{deinterleaved} - original and recoded');

%recode2 = encode_CC_tail_biting(decode_CC_tail_biting(recode', 'hard'));


