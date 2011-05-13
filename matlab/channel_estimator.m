function [eq, updated_ch ] = channel_estimator( ch, r, pilots, pilots_pos, fd_sm_length, td_sm_factor, isQPSK_mode )
% Produce and update the  channel responce
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
% [eq, updated_ch ] = channel_estimator( ch, r, pilots, pilots_pos)
% Function inputs:
%   ch - previous channel responce (frequency domain)
%   r  - received symbol, frequency domain
%   pilots - set of pilot
%   pilots_pos - position of pilots
% Outputs:
%   updated_ch - updated channel responce
%   eq = equalizer responce
%   fd_sm_length - length of the smoothing window (in frequency direction)   
%   td_sm_factor - smoothing factor(in time directiond), range 0..1
%   isQPSK_mode  - select equalizer mode (true, false), default true

    if nargin<7
        isQPSK_mode = true; 
    end
    new_ch = zeros(size(r)); 
    new_ch(pilots_pos) = r(pilots_pos)./pilots(pilots_pos); 
% Fill tails 
%     new_ch(pilots_pos(1):-3:1)    = new_ch(pilots_pos(1)); 
%     new_ch(pilots_pos(end):3:end) = new_ch(pilots_pos(end)); 
    left = pilots_pos(1)-14;
    right = pilots_pos(end)+1;
    for i=1:1+fix(fd_sm_length/14)
      new_ch(left:left+13)= new_ch(pilots_pos(1):pilots_pos(1)+13); 
      new_ch(right:right+13) = new_ch(pilots_pos(end)-13:pilots_pos(end)); 
      left = left-14; 
      right = right+14;
    end
    
  %  new_ch = fftshift(new_ch); 
 

    if( mod( fd_sm_length,2) ~= 1)
        error('fd_sm_length must be odd'); 
    end
    w = hamming( fd_sm_length ); 
    w = w/sum(w); 
    
    if(isempty(ch))      
       w = sqrt(2)*w; 
        % -- Add virtual pilot near DC for avoid dip in the channel estimation       
       tmp =  find(pilots_pos>512);    
       first_after_DC = pilots_pos(tmp(1)); 
       new_ch(first_after_DC - 3) = 0.5 * (new_ch(first_after_DC)+new_ch(first_after_DC-6));       
    else
        w=w*7; 
    end
    
    new_ch = conv(w, new_ch); 
    t = fix( fd_sm_length/2 ); 
    new_ch = new_ch( t+1:end-t); 
    
    
    if(isempty(ch))
        updated_ch = new_ch; 
    else
        updated_ch = ch + (new_ch - ch)*td_sm_factor; 
    end

if isQPSK_mode==false
    % -- QAM mode 
    % max equalizer gain clipped to 40 dB
    a = mean(abs(updated_ch)) * 0.01; 
    eq = 1./( updated_ch + a ); 
else
    % QPSK mode - amplitudes of subcarriers not corrected!    
    eq = 1/(abs(mean(updated_ch))^2)*conj(updated_ch); 
end
    

end

