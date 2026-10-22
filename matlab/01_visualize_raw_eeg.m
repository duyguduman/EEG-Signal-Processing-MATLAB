%% =============================================================
% TUTORIAL 01 - VISUALIZING A SYNTHETIC MULTICHANNEL EEG RECORDING
%
% Author: Duygu Duman
%
%
% LEARNING OBJECTIVES
%  1. Load a previously generated EEG dataset.
%  2. Inspect the channel x sample data matrix.
%  3. Generate a time axis using the sampling frequency.
%  4. Select EEG channels by their standard electrode names.
%  5. Display a short, vertically offset, multichannel recording.
%  6. Visualize a complete channel with EC/EO condition blocks.
%  7. Export publication-ready figures for documentation.
%
% IMPORTANT: This dataset is synthetic, NOT a human recording.
% Run each section from the MATLAB Editor. Set Current Folder to
% the project's 'matlab' directory before running the script.
%% =============================================================



%% 1. INITIALIZE THE MATLAB ENVIRONMENT
% ---------------------------------------------------------------

clear; clc; close all;



%% 2. FIND THE PROJECT FOLDERS
% ---------------------------------------------------------------
% pwd returns the Current Folder path. Because our Current Folder
% is the 'matlab' subfolder, fileparts(pwd) moves up one level.
% Example: project/matlab -> project

root = fileparts(pwd);
dataFile = fullfile(root, 'data', 'synthetic_eeg_64ch.mat');
figureFolder = fullfile(root, 'figures');

% Check the recording exists before attempting to load it.
assert(isfile(dataFile), ...
    'EEG file not found. Set Current Folder to the matlab folder.');

% Create the output folder if it does not exist yet.
if ~isfolder(figureFolder)
    mkdir(figureFolder);
end



%% 3. LOAD THE EEG DATASET
% ---------------------------------------------------------------
% load(...,'eeg') loads only the variable named 'eeg' from the
% MAT-file. The result is a structure S with field S.eeg.

S = load(dataFile, 'eeg');
eeg = S.eeg;

% EEG data are stored as channels x samples. Convert single
% precision to double for convenient numerical operations.

X = double(eeg.data);
Fs = double(eeg.srate);     % Samples per second (Hz)
labels = string(eeg.chanlabels(:)); % Column of channel names

% Verify that metadata agree with the data matrix.
[nCh, nSamples] = size(X);
assert(nCh == numel(labels), 'Channel labels do not match data rows.');
assert(Fs > 0 && isfinite(Fs), 'Invalid sampling frequency.');
assert(all(isfinite(X(:))), 'EEG data contain NaN or Inf values.');




%% 4. CREATE THE TIME VECTOR AND INSPECT THE RECORDING
% ---------------------------------------------------------------
% For sampling frequency Fs, successive samples occur 1/Fs
% seconds apart. The first sample is at time zero.
% t has exactly as many values as X has columns.

t = (0:nSamples-1) / Fs;
recordingDuration = nSamples / Fs;

fprintf('Dataset: %d channels | %.0f Hz | %.1f seconds | %s\n', ...
    nCh, Fs, recordingDuration, eeg.units);
fprintf('Data matrix: %d channels x %d samples\n', nCh, nSamples);

% Optional: view the first few electrode labels in the workspace.
disp('First eight electrode labels:');
disp(labels(1:min(8,nCh)));




%% 5. SELECT CHANNELS AND A SHORT TIME INTERVAL
% ---------------------------------------------------------------
% Plotting all channels together can be visually crowded.
% We select 16 representative electrodes from frontal,
% central, parietal, occipital, and temporal scalp regions.
% Electrode labels are identifiers; they are NOT brain sources.

selected = ["Fp1","Fp2","F3","F4","Fz","C3","Cz","C4", ...
            "P3","Pz","P4","O1","Oz","O2","T7","T8"];

% Map each selected electrode name to a row in X.
% Doing this by name is safer than assuming fixed row numbers.
idx = zeros(numel(selected), 1);
for k = 1:numel(selected)
    channelIndex = find(labels == selected(k), 1);
    assert(~isempty(channelIndex), ...
        'Electrode %s is not present in this dataset.', selected(k));
    idx(k) = channelIndex;
end

% Inspect a five-second excerpt, from 5 s inclusive to 10 s exclusive.
startTime = 5;      % Seconds, user-defined
endTime = 10;       % Seconds, user-defined
mask = (t >= startTime) & (t < endTime);
assert(any(mask), 'Selected time window contains no EEG samples.');

% Extract selected channels and the requested time interval.
segment = X(idx, mask);               % [16 channels x time samples]
segmentTime = t(mask);                % Time vector for these samples

%% 6. DISPLAY VERTICALLY OFFSET EEG TRACES
% ---------------------------------------------------------------
% Each EEG channel has its own amplitude in microvolts (uV).
% If plotted directly on the same axes, traces would overlap.
%
% We add a constant vertical OFFSET to each channel for display.
% This does NOT modify the EEG data saved in the MAT-file.
%
% Offset for channel k = (k-1) * spacing.
% A spacing of 85 uV is manually selected for readability.
% If traces overlap, increase this value.

spacing = 85;  % Plot-only vertical separation (uV)
offsets = (0:numel(idx)-1)' * spacing;

% MATLAB implicit expansion adds each row's offset to its trace.
stacked = segment + offsets;

fig1 = figure('Color', 'w', 'Position', [90 80 1150 720]);
plot(segmentTime, stacked', 'LineWidth', 0.8);

% Put electrode names at the offset heights.
yticks(offsets);
yticklabels(selected);

% Reverse the display's vertical direction so the first listed
% channel appears at the top (a common EEG viewing convention).
set(gca, 'YDir', 'reverse');

xlabel('Time (s)');
ylabel('EEG channels (vertically offset; signals in \muV)');
title(sprintf('Synthetic EEG | %d of %d channels | %.0f-%.0f s', ...
    numel(idx), nCh, startTime, endTime));

% Display exactly the selected time range and channel stack.
xlim([startTime endTime]);
ylim([-spacing, max(offsets) + spacing]);
grid on;
box off;

% Note: Because traces are shifted, y-ticks label channels,
% not absolute voltage values. Compare amplitudes within traces.




%% 7. SAVE THE MULTICHANNEL FIGURE
% ---------------------------------------------------------------
% SVG preserves vector lines and text for scaling/editing.
% FIG preserves the editable MATLAB figure object.

figureBase = fullfile(figureFolder, '01_raw_traces');
exportgraphics(fig1, [figureBase '.png'], 'Resolution', 300);
print(fig1, fullfile(figureFolder, '01_raw_traces.svg'),'-dsvg', '-vector');
savefig(fig1, [figureBase '.fig']);




%% 8. SELECT ONE ELECTRODE FOR THE FULL 120-SECOND RECORDING
% ---------------------------------------------------------------
% O1 is an occipital scalp electrode and is useful here because
% posterior alpha activity was intentionally modulated in our
% synthetic EC/EO dataset. This does not establish biological
% validity; the modulation was built into the simulation.

channelToShow = "O1";
ch = find(labels == channelToShow, 1);
assert(~isempty(ch), 'Requested electrode is missing.');



%% 9. DEFINE THE SYNTHETIC EXPERIMENTAL CONDITIONS
% ---------------------------------------------------------------
% The generator used four 30-second blocks:
%   0-30 s   EC (eyes closed)
%   30-60 s  EO (eyes open)
%   60-90 s  EC
%   90-120 s EO
%
% These intervals are metadata describing the simulation.
% They are not detected from EEG signals.
blockStarts = [0 30 60 90];        % Seconds
blockEnds = [30 60 90 120];        % Seconds
blockNames = ["EC" "EO" "EC" "EO"];
blockColors = [0.85 0.93 0.87;     % Light green for EC
               0.88 0.92 0.98];    % Light blue for EO



%% 10. PLOT THE FULL RECORDING WITH CONDITION BACKGROUNDS
% ---------------------------------------------------------------
fig2 = figure('Color', 'w', 'Position', [100 100 1200 420]);

% First determine the y-axis range from the channel data.
y = X(ch, :);
yPad = 0.1 * (max(y) - min(y));
if yPad == 0, yPad = 1; end
yLimits = [min(y)-yPad, max(y)+yPad];

hold on;
% Draw semi-transparent condition backgrounds behind the trace.
for k = 1:numel(blockStarts)
    thisColor = blockColors(1 + (blockNames(k) == "EO"), :);
    patch([blockStarts(k) blockEnds(k) blockEnds(k) blockStarts(k)], ...
          [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
          thisColor, 'EdgeColor', 'none', 'FaceAlpha', 0.45, ...
          'HandleVisibility', 'off');
end

% Draw EEG trace over the colored regions.
plot(t, y, 'k', 'LineWidth', 0.6);

% Add vertical dashed lines at EC/EO block boundaries.
for boundary = blockStarts(2:end)
    xline(boundary, '--', 'Color', [0.35 0.35 0.35], ...
        'HandleVisibility', 'off');
end

% Add block labels near the upper edge.
for k = 1:numel(blockStarts)
    midTime = (blockStarts(k) + blockEnds(k))/2;
    text(midTime, yLimits(2)-0.08*range(yLimits), blockNames(k), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

xlim([0 recordingDuration]);
ylim(yLimits);
xlabel('Time (s)');
ylabel('Amplitude (\muV)');
title(sprintf('%s | Synthetic EEG with Eyes-Closed / Eyes-Open Blocks', ...
    channelToShow));
grid on;
box off;
hold off;




%% 11. SAVE THE FULL-RECORDING FIGURE
print(fig2, ...
    fullfile(figureFolder, '01_O1_full_recording.svg'), ...
    '-dsvg', '-vector');
figureBase = fullfile(figureFolder, '01_O1_full_recording');
exportgraphics(fig2, [figureBase '.png'], 'Resolution', 300);
print(fig2, ...
    fullfile(figureFolder, '01_O1_full_recording.svg'), ...
    '-dsvg', '-vector');
savefig(fig2, [figureBase '.fig']);



%% 12. ZOOM INTO A SHORT EEG SEGMENT
% ----------------------------------------------------------------
% EEG signals contain oscillations occurring at different speeds.
%
% When displaying an entire 120-second recording, individual
% oscillations are difficult to distinguish.
%
% Here, we zoom into a 1-second interval of the O1 channel.
%
% This allows us to observe how the EEG amplitude changes
% over a much shorter time scale.
%
% The selected interval (6-7 seconds) belongs to an
% eyes-closed (EC) block in our synthetic recording.
%
% The original data are not modified.
% ----------------------------------------------------------------

zoomStart = 6;      % Start time in seconds (user-defined)
zoomDuration = 1;   % Duration in seconds (user-defined)
zoomEnd = zoomStart + zoomDuration;

% Select samples belonging to the requested time interval.
zoomMask = (t >= zoomStart) & (t < zoomEnd);

% Extract time and amplitude values.
zoomTime = t(zoomMask);
zoomSignal = X(ch, zoomMask);

% Create the figure.
fig3 = figure('Color','w','Position',[100 100 1100 400]);

plot(zoomTime, zoomSignal, 'k', 'LineWidth', 1.2);

xlabel('Time (s)');
ylabel('Amplitude (\muV)');
title('Synthetic EEG | O1 | One-Second Signal Excerpt');

xlim([zoomStart zoomEnd]);
grid on;
box off;




%% 13. SAVE THE ZOOMED EEG FIGURE
% ----------------------------------------------------------------

figureBase = fullfile(figureFolder, '01_O1_zoom');

exportgraphics(fig3, [figureBase '.png'], 'Resolution', 300);
print(fig3, [figureBase '.svg'], '-dsvg', '-vector');
savefig(fig3, [figureBase '.fig']);




%% 14. INTRODUCTION TO THE FREQUENCY DOMAIN
% ----------------------------------------------------------------
% So far, we have visualized EEG signals in the time domain.
%
% The time domain shows how the signal amplitude changes
% over time.
%
% However, EEG signals contain multiple oscillatory
% components at different frequencies.
%
% The Fast Fourier Transform (FFT) allows us to examine
% the frequency content of a signal.
%
% For example:
%   2 Hz  -> 2 oscillations per second
%   10 Hz -> 10 oscillations per second
%   20 Hz -> 20 oscillations per second
%
% We will use a 20-second eyes-closed EEG segment.
%
% A longer segment provides finer FFT frequency-bin spacing,
% but it also provides less information about when changes
% occur within that segment.
%
% This is a preliminary frequency-domain visualization.
% Power Spectral Density (PSD) will be covered separately.
% ----------------------------------------------------------------

fftStart = 5;     % Start of the EC segment (seconds)
fftEnd = 25;      % End of the EC segment (seconds)

fftMask = (t >= fftStart) & (t < fftEnd);

% Extract the selected O1 channel data.
signalEC = X(ch, fftMask);

% Remove the segment mean (DC offset).
signalEC = signalEC - mean(signalEC);

% Number of samples in the selected segment.
M = numel(signalEC);

% Frequency-bin spacing:
% df = Fs / M
df = Fs / M;

fprintf('FFT segment duration: %.1f seconds\n', M/Fs);
fprintf('FFT frequency-bin spacing: %.3f Hz\n', df);




%% 15. COMPUTE AND VISUALIZE THE FFT AMPLITUDE SPECTRUM
% ----------------------------------------------------------------
% Before calculating the FFT, we apply a Hann window.
%
% Why?
% A finite signal segment may begin and end at different
% amplitudes. Treating it as periodic can produce spectral
% leakage, spreading energy across frequency bins.
%
% A Hann window reduces the contribution of the segment
% boundaries. It does not eliminate spectral leakage.
%
% We calculate the window manually to avoid requiring
% the Signal Processing Toolbox.
%
% The FFT produces complex-valued frequency coefficients.
% Their magnitudes describe the contribution of frequencies.
%
% For a real-valued signal, we display the nonnegative
% frequencies and apply single-sided amplitude scaling.
%
% This scaling compensates for the Hann window's coherent
% gain and is appropriate for interpreting isolated sinusoidal
% components. Broadband amplitudes require more care.
% ----------------------------------------------------------------

% Create a Hann window manually.
n = 0:M-1;
window = 0.5 - 0.5*cos(2*pi*n/(M-1));

% Apply the window to the EEG segment.
windowedEC = signalEC .* window;

% Compute the Fast Fourier Transform.
Y = fft(windowedEC);

% Convert FFT magnitudes to a single-sided amplitude spectrum.
A = abs(Y(1:floor(M/2)+1)) * 2 / sum(window);

% Do not double the DC component.
A(1) = A(1)/2;

% Do not double the Nyquist component for even M.
if mod(M,2) == 0
    A(end) = A(end)/2;
end

% Create the frequency axis.
f = (0:floor(M/2))*Fs/M;

% Plot the amplitude spectrum.
fig4 = figure('Color','w','Position',[100 100 1100 420]);

plot(f, A, 'LineWidth', 1.3);

xlabel('Frequency (Hz)');
ylabel('Single-Sided Amplitude Spectrum (\muV)');
title('Synthetic EEG | O1 | FFT Amplitude Spectrum (EC)');

xlim([0 40]);
grid on;
box off;




%% 16. COMPARE EYES-CLOSED AND EYES-OPEN SPECTRA
% ----------------------------------------------------------------
% Our synthetic dataset was designed to contain stronger
% posterior alpha activity during eyes-closed periods.
%
% Alpha activity is commonly studied around 8-13 Hz.
%
% We compare equal-length EC and EO segments from O1:
%
%   EC: 5-25 seconds
%   EO: 35-55 seconds
%
% Using equal-length segments gives both FFT calculations
% the same frequency-bin spacing.
%
% We use the same window and amplitude scaling.
%
% IMPORTANT:
% A difference in these spectra is expected because
% EC/EO alpha modulation was built into the simulation.
% This is not evidence obtained from a human experiment.
% ----------------------------------------------------------------

% Select the eyes-open interval.
eoMask = (t >= 35) & (t < 55);

% Extract the eyes-open signal.
signalEO = X(ch, eoMask);
signalEO = signalEO - mean(signalEO);

% Verify both segments contain the same number of samples.
assert(numel(signalEO) == M, ...
    'EC and EO segment lengths do not match.');

% Apply the same Hann window.
windowedEO = signalEO .* window;

% Compute the FFT.
Yeo = fft(windowedEO);

% Calculate the single-sided amplitude spectrum.
Aeo = abs(Yeo(1:floor(M/2)+1)) * 2 / sum(window);

Aeo(1) = Aeo(1)/2;

if mod(M,2) == 0
    Aeo(end) = Aeo(end)/2;
end

% Plot both amplitude spectra.
fig5 = figure('Color','w','Position',[100 100 1100 450]);

plot(f, A, 'LineWidth', 1.4);
hold on;

plot(f, Aeo, 'LineWidth', 1.4);

% Indicate the conventional alpha frequency range.
xline(8, '--', '8 Hz', 'HandleVisibility','off');
xline(13, '--', '13 Hz', 'HandleVisibility','off');

xlabel('Frequency (Hz)');
ylabel('Single-Sided Amplitude Spectrum (\muV)');
title('Synthetic EEG | O1 | Eyes Closed vs. Eyes Open');

legend('Eyes Closed (EC)', 'Eyes Open (EO)', ...
    'Location', 'northeast');

xlim([0 40]);
grid on;
box off;
hold off;


%% 17. SAVE THE FREQUENCY-DOMAIN FIGURES
% ----------------------------------------------------------------
% The next tutorial will introduce Power Spectral Density
% estimation and the Welch method in more detail.
%
% Scalp topographic mapping will also be introduced in
% a separate tutorial.
% ----------------------------------------------------------------

figureBase = fullfile(figureFolder, '01_O1_fft_spectrum');

exportgraphics(fig4, [figureBase '.png'], 'Resolution', 300);
print(fig4, [figureBase '.svg'], '-dsvg', '-vector');
savefig(fig4, [figureBase '.fig']);

% Save EC/EO frequency comparison.
figureBase = fullfile(figureFolder, '01_EC_EO_fft_comparison');

exportgraphics(fig5, [figureBase '.png'], 'Resolution', 300);
print(fig5, [figureBase '.svg'], '-dsvg', '-vector');
savefig(fig5, [figureBase '.fig']);

disp('Tutorial 01 completed: All figures have been saved.');

