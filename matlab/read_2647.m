% Read sample capture #2647.
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

if 0
    F_file = 16e6;

    fid = fopen('wimax_2647_16Msps_8.dat', 'rb');
    in = fread(fid, inf, 'int16');
    fclose(fid);

    %rcvdDL_16k = 1i.*in(1001:2:end) + in(1002:2:end); 
    rcvdDL_16k = in(1001:2:end) + 1i.*in(1002:2:end); 
    clear in fid;
    rcvdDL = resample(rcvdDL_16k, params.Fs, F_file);
    clear F_file rcvdDL_16k;
else
    %fid = fopen('wimax_2647_11.2Msps_16.dat', 'rb'); % high SNR    
    %fid = fopen('wimax_2667_11.2Msps_16.dat', 'rb'); % low SNR !
    %fid = fopen('wimax-11.2M-2580-g30.cfile', 'rb'); 
    fid = fopen('wimax-11.2M-2580-g30-crop.cfile', 'rb'); 
    
    
    %fid = fopen('2647-2.pcm', 'rb');  
    %fid = fopen('2667_11 (2).pcm', 'rb'); 
    
    in = fread(fid, 2e6, 'int16');
    fclose(fid);

    rcvdDL = in(1:2:end) + 1i.*in(2:2:end); 
    clear in fid;
end

if 0
    frame = rcvdDL(42705:77e3);
    figure ; spectrogram(frame, params.N_fft, 750, params.N_fft, params.Fs)
    figure ; plot(abs(frame))
    figure ; pwelch(frame, params.N_fft, 750, params.N_fft, params.Fs)
end
