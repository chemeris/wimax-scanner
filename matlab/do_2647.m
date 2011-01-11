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
params.id_cell = 10;
params.segment = 0;
gen_subcarrier_prbs
subcarrier_PUSC_permutation = gen_PUSC_permutation(params.id_cell, params);


%% Find frame symbols
search_syms
for k=1:6%length(sym_start)
%    scatterplot(sym_fft(k,:))
%    figure ; hold on ; plot(abs(fftshift(sym_fft(k,:)))); plot(abs(fftshift(1./err_vec)), 'r'); hold off
    scatterplot(sym_fft_eq(k,:))
%    figure ; plot(abs(fftshift(sym_fft_eq(k,:))))
end
% k=1 - pilot(2) (even)
% k=2 - pilot(1) (odd)

%% De-randomize and demod the first DL frame
DL0_derand
DL0_demod

%% And now we need to decode it. Ugh.
