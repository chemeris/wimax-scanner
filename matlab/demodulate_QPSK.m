function [demoded] = demodulate_QPSK(constellation)
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

% Perform demodulation
demoded = demodulate(h, constellation);
demoded = reshape(demoded, 1, length(constellation)*2);
