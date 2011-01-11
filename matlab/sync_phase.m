% После того как примерно определено начало символа, определяем позицию
% FFT-окна и считаем FFT.
sig_start = 42000;
sig_length = 10000;
rx_corr_real = zeros(sig_length,1);
rx_corr_imag = zeros(sig_length,1);
for i=sig_start:1:sig_start+sig_length
  sig = rcvdDL(i:i+N_fft);

  fft_out = fft(sig,N_fft);
  rx_sym = fftshift(fft_out);
  rx_sym = rx_sym(86:end-87);
  rx_pn = rx_sym(1:3:end);
  rx_corr_real(i-sig_start+1) = real(rx_pn)' * PN';
  rx_corr_imag(i-sig_start+1) = imag(rx_pn)' * PN';
%  figure ; hold on ; plot(abs(rx_pn)/mean(abs(rx_pn))) ; plot(angle(rx_pn), 'r') ; hold off
%  figure ; hold on ; plot(real(rx_pn), 'r') ; plot(imag(rx_pn),'b') ; hold off
%  scatterplot(rx_pn); % plot
end
hold on ; plot(rx_corr_real, 'b') ; plot(rx_corr_imag, 'g') ; hold off

clear sig sig_in_start i;

 i = sig_start+150;
 
  sig = rcvdDL(i:i+N_fft);

  fft_out = fft(sig,N_fft);
  rx_sym = fftshift(fft_out);
  rx_sym = rx_sym(86:end-87);
  rx_pn = rx_sym(1:3:end);
  rx_corr_real(i-sig_start+1) = real(rx_pn)' * PN';
  rx_corr_imag(i-sig_start+1) = imag(rx_pn)' * PN';
%  figure ; hold on ; plot(abs(rx_pn)/mean(abs(rx_pn))) ; plot(angle(rx_pn), 'r') ; hold off
%  figure ; hold on ; plot(real(rx_pn), 'r') ; plot(imag(rx_pn),'b') ; hold off
  scatterplot(rx_pn); % plot
