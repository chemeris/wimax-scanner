function [eq, updated_ch, channel_estimator_state_new ] = channel_estimator( channel_estimator_state, r, pilots, pilots_pos, fd_sm_length, td_sm_factor, isQPSK_mode )
% Produce and update the  channel responce
% [eq, updated_ch ] = channel_estimator( channel_estimator_state.ch, r, pilots, pilots_pos, fd_sm_length, td_sm_factor, isQPSK_mode )
% Function inputs:
%   channel_estimator_state.ch - previous channel responce (frequency domain)
%   r  - received symbol, frequency domain
%   pilots - set of pilots
%   pilots_pos - position of pilots
%   fd_sm_length - length of the smoothing window (in frequency direction)
%   td_sm_factor - smoothing factor(in time directiond), range 0..1
%   isQPSK_mode  - select equalizer mode, see description below.
%                  Set true for QPSK mode, false for QAM mode.
% Outputs:
%   updated_ch - updated channel responce
%   eq = equalizer responce
%
% Since channel suffers from frequency-selective fading, all subcarriers have
% different amplitudes. At the same time the noise level is approximately
% equal for all frequencies. Consequently subcarriers with large amplitude
% have larger SNR and are more reliabile. This situation should be taken into
% account when averaging repetitions and during calculation of soft metrics
% for CTC decoding.
%
% The simplest (and perhaps the best) way to do it for QPSK is to equalize
% only phase of subcarriers, leaving amplitude unchanged. In his case
% subchannels with less fading have more weight during repetitions averaging
% and FEC decoding.
%
% This method can't be applied to QAM mode. To improve FEC decoding
% we should use the abs of estimation of channel response (channel_estimator_state.ch) as a factor
% of reliability of a subcarrier. It should be combined with calculation of
% soft metrics.

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

    if nargin<7
        isQPSK_mode = true; 
    end
    new_ch = zeros(size(r)); 
    new_ch(pilots_pos) = r(pilots_pos)./pilots(pilots_pos); 
% Fill tails 
    left = pilots_pos(1)-14;
    right = pilots_pos(end)+1;
    for i=1:1+fix(fd_sm_length/14)
      new_ch(left:left+13)= new_ch(pilots_pos(1):pilots_pos(1)+13); 
      new_ch(right:right+13) = new_ch(pilots_pos(end)-13:pilots_pos(end)); 
      left = left-14; 
      right = right+14;
    end
    
    if( mod( fd_sm_length,2) ~= 1)
        error('fd_sm_length must be odd'); 
    end
    w = hamming( fd_sm_length ); 
    w = w/sum(w); 
    
    if(isempty(channel_estimator_state.ch))      
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
    
    channel_estimator_state_new.phase_shift = 0;     
    if ~isempty( channel_estimator_state.inst_ch )
        channel_estimator_state_new.phase_shift = angle(channel_estimator_state.inst_ch' * new_ch); 
    end
    channel_estimator_state_new.inst_ch = new_ch; 
    
    if(isempty(channel_estimator_state.ch))
        updated_ch = new_ch; 
    else
        updated_ch = channel_estimator_state.ch + (new_ch - channel_estimator_state.ch)*td_sm_factor; 
    end
    
    channel_estimator_state_new.ch = updated_ch; 
    
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

