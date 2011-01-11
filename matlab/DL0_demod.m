sym_demod = zeros(4, params.N_data_sc);
for sym_n = 1:2
    sig_in = sym_derand(sym_n,:);
    sym_pilots = mod(sym_n,2)+1;
%    sig_in(pilot(sym_pilots,:)) = 0;
    sig_in = fftshift(sig_in);
    
    % Remove guards and pilots from carrier set
    data_sc = setdiff(params.sc_first:params.sc_last, pilot_shifted(sym_pilots,:));
    % Remove DC from carrier set
    data_sc = setdiff(data_sc, 513);
    % Save data carriers to sig_in variable
    sig_in = sig_in(data_sc);
    
%    sig_demod = qamdemod(sig_in, 4);
    % TODO:: Check SymbolMapping!
    h = modem.pskdemod('M', 4, 'PhaseOffset', pi/4, ...
        'SymbolOrder', 'Gray', 'OutputType', 'Bit');
    sym_demod(2*sym_n-1:2*sym_n,:) = demodulate(h, sig_in);
end
clear sym_n sig_in data_sc h sym_pilots ;