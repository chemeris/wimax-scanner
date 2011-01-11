sym_derand = zeros(2, params.N_fft);
for sym_n = 1:2
    sym_pilots = mod(sym_n,2)+1;

    sig_in = sym_fft_eq(sym_n,:);
    sig_in = fftshift(sig_in);
    sym_derand(sym_n,params.sc_first:params.sc_last) = ...
        sig_in(params.sc_first:params.sc_last) .* subcarrier_rand_seq_mod(sym_n,:);
    % Plot pilots before de-randomization (blue) and after (red).
    % After de-randomization all pilots should be positive.
%    figure ; hold on
%      plot(real(sig_in(pilot_shifted(sym_pilots,:))), 'b') ;
%      plot(real(sym_derand(sym_n,pilot_shifted(sym_pilots,:))), 'r') ; hold off
end
clear sym_pilots sym_n sig_in;
