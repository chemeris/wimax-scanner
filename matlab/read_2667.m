N_fft = 1024;
F = 10e6;
Fs = F*28/25;

F_file = 16e6;

fid = fopen('wimax_2667_16Msps_8.dat', 'rb');
in = fread(fid, inf, 'int16');
fclose(fid);

%rcvdDL_16k = j.*in(1001:2:end) + in(1002:2:end); 
rcvdDL_16k = in(1001:2:end) + j.*in(1002:2:end); 
clear in;

rcvdDL = resample(rcvdDL_16k, Fs, F_file);
clear rcvdDL_16k;

frame = rcvdDL(49893:83e3);
%preamble = frame(1:1500);

figure ; spectrogram(frame, N_fft, 750, N_fft, Fs)
figure ; plot(abs(frame))
figure ; pwelch(frame, N_fft, 750, N_fft, Fs)
