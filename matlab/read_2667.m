% Read sample capture #2667.
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

% Note: Sample file is not provided because of unclear legality of this.

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
