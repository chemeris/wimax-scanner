function CFO_Estimator_params = CFO_Estimator_Init(start_search, ...
                                                   end_search,...
                                                   num_knots,... 
                                                   shift_fir_order);                                                
% CFO_Estimator_params = Init_CFO_Estimator( 
%       start_search, 
%       end_search, 
%       num_knots, 
%       shift_fir_order)
% This function creates struct for CF0_Estimator.
% Input
%   start_search - first point of the search grid (least possible CFO)
%   end_search   - end point of the search grid (biggest possible CFO)
%   num_knots - number points in the search grid.
%   shift_fir_order - order of frequency shift FIR, must be odd, must be
%   >=5

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


if(mod(shift_fir_order, 2)~=1)
    error('error_shift_fir_order must be odd!'); 
end
        
step  = (end_search-start_search)/(num_knots-1); 
srch_grid = zeros(1, num_knots); 
srch_grid(1) = start_search; 
for i=2:num_knots
    srch_grid(i) = srch_grid(i-1)+step; 
end

N = 1024; 

S = zeros(N, num_knots); 
for k=1:num_knots
    S(:, k) = exp(-1j*srch_grid(k)*(0:N-1)).'; 
end      

S_fd = fft(S); 
S_fd = fftshift(S_fd, 1);
t = fix(shift_fir_order/2); 

CFO_Estimator_params.grid = srch_grid;     
CFO_Estimator_params.shift_Mtx= 1/N * S_fd((N/2+1-t:N/2+1+t),:); 

CFO_Estimator_params.first_carrier_for_segment0 = 87; 
CFO_Estimator_params.num_carriers_in_preamble   = 284; 

