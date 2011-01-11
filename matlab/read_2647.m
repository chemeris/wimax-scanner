F_file = 16e6;

fid = fopen('wimax_2647_16Msps_8.dat', 'rb');
in = fread(fid, inf, 'int16');
fclose(fid);

%rcvdDL_16k = 1i.*in(1001:2:end) + in(1002:2:end); 
rcvdDL_16k = in(1001:2:end) + 1i.*in(1002:2:end); 
rcvdDL = resample(rcvdDL_16k, params.Fs, F_file);
clear in F_file fid;
clear rcvdDL_16k;

frame = rcvdDL(42705:77e3);
%preamble = frame(1:1500);

figure ; spectrogram(frame, params.N_fft, 750, params.N_fft, params.Fs)
figure ; plot(abs(frame))
figure ; pwelch(frame, params.N_fft, 750, params.N_fft, params.Fs)
