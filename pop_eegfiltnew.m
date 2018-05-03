function [EEG, b] = pop_eegfiltnew(EEG, locutoff, hicutoff, filtorder, revfilt, usefft, plotfreqz)
% EEG =             pop_eegfiltnew(EEG, 1,         30,        [],        0,       [],      0);

if isempty(EEG)
    error('Cannot filter empty dataset.');
end
EEG1.srate=128;
% Constants
TRANSWIDTHRATIO = 0.25;
fNyquist = EEG1.srate / 2;
minphase=0;
edgeArray = sort([locutoff hicutoff]);

if isempty(edgeArray)
    error('Not enough input arguments.');
end
if any(edgeArray < 0 | edgeArray >= fNyquist)
    error('Cutoff frequency out of range');
end

if ~isempty(filtorder) && (filtorder < 2 || mod(filtorder, 2) ~= 0)
    error('Filter order must be a real, even, positive integer.')
end

% Max stop-band width
maxTBWArray = edgeArray; % Band-/highpass
if revfilt == 0 % Band-/lowpass
    maxTBWArray(end) = fNyquist - edgeArray(end);
elseif length(edgeArray) == 2 % Bandstop
    maxTBWArray = diff(edgeArray) / 2;
end
maxDf = min(maxTBWArray);

% Transition band width and filter order
if isempty(filtorder)

    % Default filter order heuristic
    if revfilt == 1 % Highpass and bandstop
        df = min([max([maxDf * TRANSWIDTHRATIO 2]) maxDf]);
    else % Lowpass and bandpass
        df = min([max([edgeArray(1) * TRANSWIDTHRATIO 2]) maxDf]);
    end

    filtorder = 3.3 / (df / EEG1.srate); % Hamming window
    filtorder = ceil(filtorder / 2) * 2; % Filter order must be even.
    
else

    df = 3.3 / filtorder * EEG1.srate; % Hamming window
    filtorderMin = ceil(3.3 ./ ((maxDf * 2) / EEG1.srate) / 2) * 2;
    filtorderOpt = ceil(3.3 ./ (maxDf / EEG1.srate) / 2) * 2;
    if filtorder < filtorderMin
        error('Filter order too low. Minimum required filter order is %d. For better results a minimum filter order of %d is recommended.', filtorderMin, filtorderOpt)
    elseif filtorder < filtorderOpt
        warning('firfilt:filterOrderLow', 'Transition band is wider than maximum stop-band width. For better results a minimum filter order of %d is recommended. Reported might deviate from effective -6dB cutoff frequency.', filtorderOpt)
    end

end

filterTypeArray = {'lowpass', 'bandpass'; 'highpass', 'bandstop (notch)'};
fprintf('pop_eegfiltnew() - performing %d point %s filtering.\n', filtorder + 1, filterTypeArray{revfilt + 1, length(edgeArray)})
fprintf('pop_eegfiltnew() - transition band width: %.4g Hz\n', df)
fprintf('pop_eegfiltnew() - passband edge(s): %s Hz\n', mat2str(edgeArray))

% Passband edge to cutoff (transition band center; -6 dB)
dfArray = {df, [-df, df]; -df, [df, -df]};
cutoffArray = edgeArray + dfArray{revfilt + 1, length(edgeArray)} / 2;
fprintf('pop_eegfiltnew() - cutoff frequency(ies) (-6 dB): %s Hz\n', mat2str(cutoffArray))

% Window
winArray = windows('hamming', filtorder + 1);

% Filter coefficients
if revfilt == 1
    filterTypeArray = {'high', 'stop'};
    b = firws(filtorder, cutoffArray / fNyquist, filterTypeArray{length(cutoffArray)}, winArray);
else
    b = firws(filtorder, cutoffArray / fNyquist, winArray);  %425
end

if minphase
    disp('pop_eegfiltnew() - converting filter to minimum-phase (non-linear!)');
    b = minphaserceps(b);
end

% Plot frequency response
if plotfreqz
    freqz(b, 1, 8192, EEG1.srate);
end

% Filter
if minphase
    disp('pop_eegfiltnew() - filtering the data (causal)');
    EEG = firfiltsplit(EEG, b, 1);
else
    disp('pop_eegfiltnew() - filtering the data (zero-phase)');
    EEG = firfilt1(EEG, b);
end


% History string

end
