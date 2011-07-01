function cfo = CFO_Estimator(frame_shifted_fd, segment, params); 
% cfo = CFO_Estimate(frame_shifted_fd, segment, params); 
% This function makes the estimation of CFO (Carrier Frequency Offset). 
% Inputs:
%   frame_shifted_fd - OFDM frame that contains the preamble, in frequency
%    domain;
%   segment - segment number; 
%   params -  parameters and tables of CFO Estimator, this struct returns by 
%   function  CFO_Estimator_Init. 
% Output:
%   cfo  - Measured CFO in rad/sample.

% Copyright (C) 2011  Alexey Ostapenko
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
%

[shift_fir_len, num_knots] = size(params.grid); 

tmp = fix(shift_fir_len/2); 
m = zeros(1, num_knots); 

carrier_start = params.first_carrier_for_segment0 + segment; 
carrier_end = carrier_start + 3*params.num_carriers_in_preamble; 

% Uses the fact that only one third of non-zero subcarrier
for k=1:num_knots
    
% Frequency shift in the frequency domain is convolution    
    frame_tmp2 = conv(frame_shifted_fd, params.shift_Mtx(:,k));
    frame_tmp2 = frame_tmp2(1+tmp: 1024+tmp);
        
    m(k) =      sum(abs(frame_tmp2(carrier_start  :3:carrier_end)).^2)...
              - sum(abs(frame_tmp2(carrier_start+1:3:carrier_end)).^2)...            
              - sum(abs(frame_tmp2(carrier_start+2:3:carrier_end)).^2);
end   

[v, i] = max(m);     

x0 = params.grid(i); 
y0 = m(i); 

if i==1
    x1 = params.grid(i+1); 
    y1 =  m(i+1); 
    x2 = params.grid(i+2); 
    y2 =  m(i+2);                 
elseif i==num_knots
    x1 = params.grid(i-1); 
    y1 =  m(i-1); 
    x2 = params.grid(i-2); 
    y2 =  m(i-2);                 
else
    x1 = params.grid(i-1); 
    y1 =  m(i-1); 
    x2 = params.grid(i+1); 
    y2 = m(i+1);         
end

% The parabolic interpolation on three points
k = (y0-y1)/(y0-y2); 
cfo = -0.5*(k*(x0^2 - x2^2) - (x0^2 - x1^2))/ ((x0-x1)-k*(x0-x2)); 
if 0
figure(11), plot(m);
end

