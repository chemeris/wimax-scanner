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
% Preamble finder,  return positions of first sample of preamble and
% measured carrier frequency offset.
% Uses the fact that the preamble is a sequence repeated three times (time
% domain).


function [frame_start_pos, frame_carrier_offset, norm_acf] = find_preamble(params, s)
%function [frame_start_pos, frame_carrier_offset] = find_preamble(params,
%s)
% 
frame_start_pos = []; 
frame_carrier_offset = []; 
norm_acf = []; 

d = round(1024/3); 

threshold = 0.7; 
%threshold = 0.65; 
%threshold = 0.5; 
NN = length(s) - params.Ts_samples ; 
detector_delay = d; 


del_left_centre = zeros(1, d); 
del_centre_right = zeros(1, d); 
del_en_left = zeros(1, d); 
en_centre = zeros(1, d); 
en_right = zeros(1, d); 
del_r = zeros(1, d); 
del_en =zeros(1, d);  

R_ref = zeros(1, NN); 
R = zeros(1,length(s)); 
R(1) = 0; 


%sliding window implementation of this 
k = 1; 
total_energy = 0; 
total_r      =0;  
r=0; 
en=0; 
while k < length(s)-4*d 
 %   k
    left   = s(k     :k+d-1   ).';     
    centre = s(k+d   :k+2*d-1 ).'; 
    right =  s(k+2*d :k+3*d-1 ).';     
    
    left_centre  = conj( left) .* centre; 
    centre_right = conj( centre ) .* right;      
    en_left   = left  .* conj(left); 
    en_centre = centre .* conj(centre); 
    en_right  = right .* conj(right); 
    
    tmp_r = 2*(left_centre + centre_right); 
    tmp_en = en_left + 2*en_centre + en_right; 
    
    for i=1:d
        r  =  r  + tmp_r(i)  -del_r(i); 
        en =  en + tmp_en(i)-del_en(i); 
        R(k) = r/en; 
        k = k + 1; 
    end
    del_r = tmp_r; 
    del_en = tmp_en; 
end
R = conv( 1/params.Tg_samples * ones(1,params.Tg_samples), R); 
R(1:params.Tg_samples/2+detector_delay) = []; 

count = -1; 
maxR = -1; 
for i=1:length(R)
    tmp = abs(R(i)); 
    if ((tmp > threshold) && (tmp>maxR))
        maxR = tmp;
        count = 0;     
%        fprintf('\n%d: %f', i, maxR); 
    else
        if count == d-1  
            frame_start_pos(end+1) = i-d; 
            norm_acf(end+1) = maxR; 
            maxR = -1;
            count = -1;
        else
            if count >= 0
                count = count + 1;
            end
        end
    end
end
if 0
figure(1); 
plot(abs(R)); 
hold on 
plot(frame_start_pos, abs(R(frame_start_pos)), 'rx'); 

hold off
end
%frame_start_pos
frame_carrier_offset = angle( R(frame_start_pos) )/d;  

% for n = 1:200000 %NN
%     left   = s(n     :n+d-1   ).';     
%     centre = s(n+d   :n+2*d-1 ).'; 
%     right =  s(n+2*d :n+3*d-1 ).';     
%     R_ref(n) = 2*(centre * left' +  right  * centre') /(2*centre*centre' + left*left' + right*right');         
% end
% R_ref = conv( 1/params.Tg_samples * ones(1,params.Tg_samples), R_ref); 
% R_ref(1:params.Tg_samples/2) = []; 
% figure(1); 
% plot( 1:200000, abs(R_ref(1:200000)), 1:length(R), abs(R) ); 
% 


