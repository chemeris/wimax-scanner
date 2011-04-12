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
% Produce and update the  channel responce



function [eq, updated_ch ] = channel_estimator( ch, r, pilots, pilots_pos, fd_sm_length, td_sm_factor )
% function [eq, updated_ch ] = channel_estimator( ch, r, pilots,
% pilots_pos)
% ch - prev channel responce (frequency domain)
% r  - received symbol, frequency domain
% pilots - set of pilot
% pilots_pos - position of pilots
% return 
% updated_ch - updated channel responce
% eq = equalizer responce
    new_ch = zeros(size(r)); 
    new_ch(pilots_pos) = r(pilots_pos)./pilots(pilots_pos); 
% fill tiles     
    new_ch(pilots_pos(1):-3:1)     = new_ch(pilots_pos(1)); 
    new_ch(pilots_pos(end):3:end) = new_ch(pilots_pos(end)); 
  %  new_ch = fftshift(new_ch); 

    if( mod( fd_sm_length,2) ~= 1)
        error('fd_sm_length must be odd'); 
    end
    w = hamming( fd_sm_length ); 
    w = w/sum(w); 
    new_ch = conv(w, new_ch); 
    t = fix( fd_sm_length/2 ); 
    new_ch = new_ch( t+1:end-t); 
    
    if(isempty(ch))
        updated_ch = new_ch; 
    else
        updated_ch = ch + (new_ch - ch)*td_sm_factor; 
    end

%    updated_ch = fftshift(updated_ch);
    
    % max equalizer gain clipped to 40 dB
    a = mean(abs(updated_ch)) * 0.01; 
    eq = 1./( updated_ch + a ); 
    

end

