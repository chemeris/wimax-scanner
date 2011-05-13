function [PDU_qpsk] = PDU_extract(PDU_repetition, ...
                                  PDU_skip_subch, PDU_length_subch, ...
                                  PDU_start_sym, PDU_start_subch, ...
                                  PDU_size_sym, PDU_size_subch, ...
                                  syms_fft_eq, params)
% Extract QPSK characters
%
% function [PDU_qpsk] = PDU_extract(PDU_repetition, ...
%                                   PDU_skip_subch, PDU_length_subch, ...
%                                   PDU_start_sym, PDU_start_subch, ...
%                                   PDU_size_sym, PDU_size_subch, ...
%                                   syms_fft_eq, params)
%
% PDU_repetition - repetition coding used (1, 2, 4 or 6)
% PDU_skip_subch - number of subchannels to skip at the begining of the
%                  block
% PDU_length_subch - block length in subchannels, set to inf if full block
%                    is used
% PDU_start_sym   - block offset in OFDM symbols (time axis)
% PDU_start_subch - block offset in subchannels (frequency axis)
% PDU_size_sym    - block size in OFDM symbols (time axis)
% PDU_size_subch  - block size in subchannels (frequency axis)
% syms_fft_eq - equalized OFDM symbols in frequency domain
% params - global parameters

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

%% Prepare constants
if isinf(PDU_length_subch) || PDU_length_subch <= 0
    % PDU_length_subch is not set - assume full block
    PDU_length_subch = (PDU_size_sym/2)*PDU_size_subch-PDU_skip_subch;
end
PDU_qpsk = zeros(PDU_repetition, 48*PDU_length_subch/PDU_repetition);
i = 1; 
count_slots = PDU_skip_subch;
j = PDU_skip_subch + PDU_start_subch + 10*params.segment; % Index of first slot
t = zeros(PDU_repetition, 48); 
t_index = 1; 
first_sym = PDU_start_sym; 
while i <= PDU_length_subch/PDU_repetition
    %% Collect PDU_repetition of slots
    t(t_index, :) = get_slot_data(syms_fft_eq(first_sym:first_sym+1,:), j, 1, 2, params);
    if t_index==PDU_repetition
        t_index = 1; 
        if PDU_repetition ~= 1
            % Save all repetitions
            PDU_qpsk(:,1+(i-1)*48: i*48) = t;
        else
            % Save the only repetition
            PDU_qpsk(1+(i-1)*48: i*48) = t; 
        end
        i = i+1;              
    else
        t_index = t_index+1; 
    end

    %% Adjust physical subchannel index
    j = j+1; 
    if j == params.N_subchannels
        % Wrap to the first subchannel
        j = 0;
    end
    
    %% Adjust logical subchannel index
    count_slots = count_slots+1;
    if count_slots == PDU_size_subch
        % Move to the next OFDM symbol
        count_slots = 0;
        j = PDU_start_subch + 10*params.segment;
        first_sym = first_sym+2;
    end
          
end
