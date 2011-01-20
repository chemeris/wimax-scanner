function [demoded] = demodulate_QPSK(constellation)
% Demodulate 802.16e QPSK.
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

% Refer to "8.4.9.4.2 Data modulation" of IEEE 802.16-2009 for details.

%DecisionType = 'approximate llr';
DecisionType = 'llr';
%DecisionType = 'hard decision';
h = modem.pskdemod('M', 4, 'PhaseOffset', pi/4, ...
                   'SymbolOrder', 'user-defined', ...
                   'SymbolMapping', [0 2 3 1], ...
                   'OutputType', 'Bit', ...
                   'DecisionType', DecisionType);
% Optionally display constellation
if 0
    % Create a scatter plot
    scatterPlot = commscope.ScatterPlot('SamplesPerSymbol',1,...
                                        'Constellation',h.Constellation);
    % Show constellation
    scatterPlot.PlotSettings.Constellation = 'on';
    scatterPlot.PlotSettings.ConstellationStyle = 'rd';
    % Add symbol labels
    hold on;
    k=log2(h.M);
    for jj=1:h.M
            text(real(h.Constellation(jj))-0.15,imag(h.Constellation(jj))+0.15,...
            dec2base(h.SymbolMapping(jj),2,k));
    end
    hold off;
end

% Demodulate
% Note: I'm not sure why do we need conj() here, but that's the only way
%       it works.
demoded = demodulate(h, conj(constellation));
% Parallel to serial conversion
demoded = reshape(demoded, 1, length(constellation)*2);
