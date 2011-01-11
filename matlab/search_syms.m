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
