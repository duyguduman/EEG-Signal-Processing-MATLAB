%% =========================================================
%   TUTORIAL 00 - SYNTHETIC EEG DATA GENERATION
% 
%   Author: Duygu Duman
%
%   OBJECTIVE
%   ---------
%   This tutorial demonstrates how to generate a synthetic EEG dataset
%   that resembles some basic characteristics of multichannel EEG.
%
%   The generated data will contain:
%
%   1. 64 EEG channels with standard electrode labels and positions.
%   2. Delta, theta, alpha, and beta-like oscillatory activity.
%   3. Spatially varying oscillatory amplitudes.
%   4. Alternating eyes-closed (EC) and eyes-open (EO) conditions.
%   5. Stronger posterior alpha activity during EC periods.
%   6. Independent channel-specific background noise.
%   7. Simulated eye-blink artifacts.
%   8. Simulated muscle artifacts.
%   9. Simulated 50-Hz electrical interference.
%   10. An intentionally noisy EEG channel segment.
%
%   The final dataset will contain:
%       64 channels
%       256 samples
%       120 seconds of simulated recording
%
%   IMPORTANT
%   ---------
%   These signals are completely synthetic. They are NOT recordings from
%   human participants.
%   
%   The simulation is intended for educational purposes and for
%   demonstrating signal processing methods.
%
%   It should not be considered a physiologically validated model of human
%   EEG, brain connectivity, or neural source activity.
%
%   REQUIREMENTS
%   ------------
%   MATLAB
%   No EEGLAB or  third-party EEG toolbox required.
%
%   =====================================================================

%% 1. INITIALIZE THE MATLAB ENVIRONMENT
% ---------------------------------------------------------------

clear; clc; close all; 

%% 2. DEFINE THE PROJECT DIRECTORY
% ---------------------------------------------------------------
% Our project is organized into separate folders:
%
% EEG-MATLAB-Fundamentals/
% |
% |-- data/
% |     |-- electrodes.tsv
% |
% |-- matlab/
% |     |-- 00_generate_synthetic_eeg.m

root = fileparts(pwd);

% The 'pwd' function returns MATLAB's current working directory.
%
% Since we are working inside the 'matlab' folder, fileparts(pwd)
% moves one directory level up to the project root.
%
% Example:
%   Current folder: C:/EEG_Project/matlab
%   Project root:   C:/EEG_Project

%% 3. LOAD THE EEG ELECTRODE MONTAGE
% ----------------------------------------------------------------
% An EEG montage describes the spatial arrangement of electrodes
% used during a recording.
%
% Each electrode has:
%   - A channel label (e.g., Fp1, Fz, Cz, O1)
%   - A spatial position (X, Y, Z)
%
% In our project, electrode information is stored in a TSV file.
%
% TSV stands for "Tab-Separated Values".
% It is a text-based format in which columns are separated by tabs.
%
% The readtable function imports this file as a MATLAB table.
%
% fullfile constructs a file path using the correct separator
% for the operating system.
%
% The electrodes.tsv file should contain:
%
%   name       x       y       z
%   Fp1        ...     ...     ...
%   Fp2        ...     ...     ...
%   ...
%
% Spatial coordinates will later be used for EEG scalp maps.
% ----------------------------------------------------------------
montage = readtable( ...
    fullfile(root, 'data', 'electrodes.tsv'), ...
    'FileType', 'text', ...
    'Delimiter', '\t');



%% 4. EXTRACT ELECTRODE LABELS AND COORDINATES
% ----------------------------------------------------------------
% The montage table contains different types of information.
% We extract the electrode names and coordinates separately.
%
% labels:
%   A string array containing the names of the EEG channels.
%   Example:
%       ["Fp1"; "Fp2"; "F3"; "F4"; ...]
%
% xyz:
%   A numerical matrix containing electrode coordinates.
%
%   Each row represents one electrode.
%   Each column represents one spatial dimension.
%
%   Column 1: X coordinate
%   Column 2: Y coordinate
%   Column 3: Z coordinate
%
% For a 64-channel EEG montage:
%
%   size(xyz) = [64, 3]
%
% The order of labels must match the order of coordinate rows.
%
% NOTE:
% These positions come from a standard electrode template,
% not from individual electrode digitization.
% ----------------------------------------------------------------

labels = string(montage.name);

xyz = [montage.x, montage.y, montage.z];



%% 5. DEFINE THE EEG RECORDING PARAMETERS
% ----------------------------------------------------------------
% EEG is a continuous electrical signal that is represented
% digitally by sampling its amplitude at regular intervals.
%
% Sampling frequency (Fs):
%   Number of samples acquired per second, in Hertz (Hz).
%
% If Fs = 256 Hz:
%   The system represents the EEG signal using 256 samples
%   per second, per channel.
%
% Recording duration:
%   Total length of the simulated EEG recording in seconds.
%
% Total samples:
%   N = Fs * recording duration
%
% In our example:
%   N = 256 * 120 = 30,720 samples
%
% Therefore, each EEG channel will contain 30,720 data points.
%
% The Nyquist frequency is:
%   f_Nyquist = Fs / 2 = 128 Hz
%
% Frequencies above the Nyquist limit cannot be uniquely
% represented at this sampling rate without aliasing.
%
% In real EEG acquisition, appropriate anti-aliasing filtering
% is required before digitization.
% ----------------------------------------------------------------

Fs = 256; seconds = 120;
N = Fs * seconds;



%% 6. CREATE THE TIME VECTOR
% ----------------------------------------------------------------
% MATLAB arrays are indexed starting from 1, but EEG recording
% time is conventionally represented starting at 0 seconds.
%
% The time vector associates each sample with its time position.
%
% Mathematical definition:
%   t[n] = n / Fs
%                   where:
%                   n = 0, 1, 2, ..., N-1
%
% For Fs = 256 Hz:
%
%   t(1) = 0 seconds
%   t(2) = 1/256 seconds
%   t(3) = 2/256 seconds
%
% The interval between consecutive samples is:
%   dt = 1/Fs = 0.00390625 seconds
%
% This is approximately 3.91 milliseconds.
%
% The last sample occurs at (N-1)/Fs, rather than exactly
% at the full recording duration.
% ----------------------------------------------------------------

t = (0:N-1) / Fs;


%% 7. SET RANDOM SEED AND COUNT CHANNELS
% ----------------------------------------------------------------
% Several components of our EEG simulation will contain
% random numbers.
%
% For example:
%   - Background noise
%   - Channel-specific phases
%   - Independent signal fluctuations
%
% The rng function initializes MATLAB's random number generator.
%
% By using a fixed seed, the same random number sequence
% is produced each time the script is executed, assuming
% compatible MATLAB random number generator behavior.
%
% This is useful for:
%   - Reproducible tutorials
%   - Debugging
%   - Comparing analysis methods
%
% 'twister' specifies the Mersenne Twister algorithm.
%
% numel(labels) returns the number of EEG channels.
% ----------------------------------------------------------------
% Set a fixed random seed to ensure reproducible results.
% 42 is an arbitrary number; using the same seed generates
% the same sequence of random numbers each time the code runs.
rng(42, 'twister');

% Count the number of EEG channels from the electrode labels.
nCh = numel(labels);



%% 8. DEFINE EEG FREQUENCY COMPONENTS
% ----------------------------------------------------------------
% Human EEG activity contains oscillations distributed across
% different frequency ranges.
%
% Commonly used frequency bands include:
%
%   Delta: approximately 0.5-4 Hz
%   Theta: approximately 4-8 Hz
%   Alpha: approximately 8-13 Hz
%   Beta:  approximately 13-30 Hz
%
%
% Here, we manually select representative center frequencies
% for four simulated EEG-like spectral components.
%
% 'centers' defines the peak frequency of each component.
% 'spreads' controls the width of its Gaussian spectral weighting.
%
% These values are illustrative simulation parameters,
% not parameters estimated from real EEG recordings.
%
% The Gaussian profiles overlap and do not create strict
% band-pass limits.
% ----------------------------------------------------------------

centers = [2, 5.5, 10, 20];   % Delta, theta, alpha, beta centers (Hz)
spreads = [1.5, 2.2, 1.8, 5]; % Gaussian width parameters (Hz)


%% 9. INITIALIZE THE LATENT SOURCE MATRIX
% ----------------------------------------------------------------
% We create four shared signal components, one for each
% frequency range defined above.
%
% These components are called "latent sources" in this tutorial
% because they will later be mixed across EEG channels.
%
% The matrix dimensions are:
%   4 x N
% Each row contains one simulated spectral component.
%   Row 1: Delta-like component
%   Row 2: Theta-like component
%   Row 3: Alpha-like component
%   Row 4: Beta-like component
%
% zeros(4,N) creates a matrix filled with zeros.
%
% Preallocating memory improves computational efficiency.
% ----------------------------------------------------------------

latents = zeros(4, N);



%% 10. CREATE THE FREQUENCY VECTOR
% ----------------------------------------------------------------
% The Fast Fourier Transform (FFT) represents a discrete signal
% in the frequency domain.
%
% FFT frequency resolution is:
%   df = Fs / N
%
% For our recording:
%   df = 256 / 30720 = approximately 0.00833 Hz
%
% The vector below contains nonnegative frequency bins
% from 0 Hz to the Nyquist frequency.
%
% Since N is even, the nonnegative spectrum contains:
%   N/2 + 1 frequency bins
%
% The first bin represents 0 Hz (DC).
% The last bin represents the Nyquist frequency.
%
% We will use this vector to construct frequency-domain
% Gaussian weighting functions.
% ----------------------------------------------------------------

freq = (0:floor(N/2)) * Fs / N;



%% 11. GENERATE BAND-LIMITED LATENT SIGNALS
% ----------------------------------------------------------------
% In this section, we construct four oscillatory components
% by shaping random noise in the frequency domain.
%
% The general procedure is:
%   1. Generate random white noise.
%   2. Compute its FFT.
%   3. Construct a Gaussian-shaped frequency response.
%   4. Multiply the spectrum by this frequency response.
%   5. Apply the inverse FFT.
%   6. Normalize the resulting signal.
%
% This method creates random signals whose spectral energy
% is concentrated around selected frequencies.
%
% Unlike a pure sine wave, these signals fluctuate over time
% because they originate from random noise.
%
% The resulting waveforms are still simplified simulations
% and should not be interpreted as realistic neural sources.
% ----------------------------------------------------------------

for k = 1:4

    % -------------------------------------------------------------
    % Step 11.1: Generate random white noise
    %
    % randn generates normally distributed random numbers.
    %
    % White noise contains random fluctuations with approximately
    % uniform expected power across frequencies.
    % -------------------------------------------------------------

    v = randn(1, N);


    % -------------------------------------------------------------
    % Step 11.2: Transform the noise into the frequency domain
    %
    % fft computes the Discrete Fourier Transform using
    % an efficient numerical algorithm.
    %
    % The resulting complex values contain frequency-domain
    % amplitude and phase information.
    % -------------------------------------------------------------

    V = fft(v);


    % -------------------------------------------------------------
    % Step 11.3: Construct a Gaussian spectral weighting function
    %
    % The Gaussian function is:
    %   G(f) = exp(-0.5 * ((f-f0)/sigma)^2)
    %                                  where:
    %                                  f0    = central frequency
    %                                  sigma = spectral width parameter
    %
    % Frequencies near the center receive higher weights.
    % Frequencies farther away receive progressively lower weights.
    %
    % This is a frequency-domain amplitude weighting function.
    % It is not a Power Spectral Density (PSD) estimate.
    % -------------------------------------------------------------

    shape = exp(-0.5 * ((freq - centers(k)) / spreads(k)).^2);


    % -------------------------------------------------------------
    % Step 11.4: Reconstruct the full two-sided frequency response
    %
    % FFT output contains positive and negative frequency
    % components.
    %
    % For a real-valued time-domain signal, the frequency
    % representation has conjugate symmetry.
    %
    % Since the weighting function is real-valued, we construct
    % a symmetric weighting vector.
    %
    % The DC and Nyquist bins are not duplicated.
    %
    % The following indexing assumes an even number of samples.
    % -------------------------------------------------------------

    envelope = [shape, shape(end-1:-1:2)];


    % -------------------------------------------------------------
    % Step 11.5: Apply spectral weighting and inverse FFT
    %
    % Element-wise multiplication modifies the amplitude
    % of each frequency component.
    %
    % ifft converts the modified spectrum back into a
    % time-domain signal.
    %
    % real removes negligible numerical imaginary components
    % that may arise during floating-point computation.
    %
    % The filtering operation is performed on the complete
    % recording, so this is an offline, noncausal operation.
    % -------------------------------------------------------------

    v = real(ifft(V .* envelope));


    % -------------------------------------------------------------
    % Step 11.6: Normalize the signal
    %
    % std(v) calculates the standard deviation.
    %
    % Dividing by the standard deviation creates a component
    % with approximately unit standard deviation.
    %
    % This allows us to control the contribution of each
    % component through amplitude weights later.
    %
    % eps is MATLAB's floating-point epsilon.
    % max(std(v),eps) avoids division by zero.
    % -------------------------------------------------------------

    latents(k,:) = v / max(std(v), eps);

end



%% 12. NORMALIZE ELECTRODE COORDINATES
% ----------------------------------------------------------------
% Electrode positions are represented by 3D coordinates.
%
% To describe approximate electrode directions independently
% of distance from the coordinate origin, we normalize each
% coordinate vector by its Euclidean length.
%
% The Euclidean norm of a coordinate vector is:
%   ||r|| = sqrt(x^2 + y^2 + z^2)
%
% The normalized coordinate is:
%   p = r / ||r||
%
% MATLAB's vecnorm(xyz,2,2) calculates the Euclidean norm
% for each row of the coordinate matrix.
%
% This preserves the direction of each electrode coordinate
% while converting it approximately to unit length.
%
% The operation assumes that the montage is expressed in a
% meaningful head-centered coordinate system.
%
% It does not register individual electrode locations to
% anatomical regions or identify cortical source locations.
% ----------------------------------------------------------------

p = xyz ./ max(vecnorm(xyz, 2, 2), eps);



%% 13. DEFINE SPATIAL WEIGHTING FUNCTIONS
% ----------------------------------------------------------------
% EEG rhythms and artifacts can show different spatial patterns
% across the scalp.
%
% Here, we define simplified spatial weights for posterior,
% frontal, and temporal electrode locations.
%
% The electrode coordinates (p) were previously normalized
% to unit length.
%
% Coordinate convention:
%   X-axis: Left-right direction
%   Y-axis: Anterior-posterior direction
%
% We assume:
%   Positive Y = anterior (frontal)
%   Negative Y = posterior (occipital)
%
% The parameters below are manually selected for simulation.
% They are NOT physiological constants.
% ----------------------------------------------------------------

% Spatial offset:
% Shifts the weighting function along the anterior-posterior
% axis. A value of 0.25 allows the weight to extend slightly
% beyond the central region of the scalp.

spatialOffset = 0.25;

% Spatial scaling factor:
% Controls how gradually the spatial weight increases.
% A larger value produces a slower spatial transition.
%
% With offset = 0.25 and scale = 1.25, a weight reaches 1
% at a normalized coordinate of +/-1 in the target direction.

spatialScale = 1.25;


% Posterior weighting:
% Assigns higher values to posterior electrodes.
% The negative sign reverses the Y-axis direction.

posterior = max(0, min(1, (-p(:,2) + spatialOffset) / spatialScale));


% Frontal weighting:
% Assigns higher values to anterior/frontal electrodes.

frontal = max(0, min(1, (p(:,2) + spatialOffset) / spatialScale));


% Temporal/lateral weighting:
% Uses the absolute X coordinate to assign higher weights
% to electrodes located toward either side of the scalp.
%
% No additional offset is used for this weighting function.

temporal = min(1, abs(p(:,1)));


%% 14. DEFINE EXPERIMENTAL CONDITIONS
% ----------------------------------------------------------------
% We simulate two resting-state conditions:
%
%   EC = Eyes Closed
%   EO = Eyes Open
%
% The 120-second recording is divided into four blocks:
%
%   0-30 s    : Eyes Closed
%   30-60 s   : Eyes Open
%   60-90 s   : Eyes Closed
%   90-120 s  : Eyes Open
%
% floor(t/30) assigns samples to consecutive 30-second blocks.
%
% mod(...,2) produces an alternating sequence of 0 and 1.
%
% The logical expression identifies the even-numbered blocks
% as the eyes-closed condition.
%
% double converts logical values to numerical 0 and 1.
%
% In the resulting ec vector:
%   ec = 1: Eyes Closed
%   ec = 0: Eyes Open
%
% The condition timing is deliberately imposed by the
% simulation. No human participant performed these tasks.
% ----------------------------------------------------------------

ec = double(mod(floor(t/30), 2) == 0);



%% 15. SMOOTH EC/EO TRANSITIONS
% ----------------------------------------------------------------
% EC and EO conditions initially change abruptly (0 or 1).
% To simulate gradual changes in alpha amplitude, we smooth
% the condition vector using a Hann-shaped window.
%
% The transition half-width (0.6 seconds) is an arbitrary
% simulation parameter, not a physiological constant.
%
% The complete smoothing window spans approximately 1.2 s.

transitionHalfWidth = 0.6;  % Half-width in seconds (user-defined)

% Convert the half-width from seconds to samples.
L = round(transitionHalfWidth * Fs);

% Create a symmetric Hann-shaped smoothing window.
smoothWin = (1 - cos(2*pi*(0:2*L)/(2*L))) / 2;

% Normalize window weights so their sum equals one.
smoothWin = smoothWin / sum(smoothWin);

% Smooth the EC/EO condition vector while preserving its length.
ecSmooth = conv(ec, smoothWin, 'same');




%% 16. SIMULATE POSTERIOR ALPHA MODULATION
% ----------------------------------------------------------------
% Posterior alpha activity is typically stronger during
% eyes-closed (EC) than eyes-open (EO) resting conditions.
%
% We model this using three user-defined parameters:
%
% baselineAlpha:
%   Background alpha amplitude shared across electrodes.
%
% posteriorAlphaEO:
%   Additional alpha amplitude at maximally posterior
%   electrodes during eyes-open periods.
%
% posteriorAlphaEC:
%   Additional alpha amplitude at maximally posterior
%   electrodes during eyes-closed periods.
%
% These values are illustrative simulation parameters,
% not values estimated from human EEG recordings.
%
% All amplitudes are expressed in simulated microvolts.
% ----------------------------------------------------------------

baselineAlpha = 1.3;     % Background alpha amplitude (uV)

posteriorAlphaEO = 1.2;  % Additional posterior alpha during EO (uV)
posteriorAlphaEC = 4.8;  % Additional posterior alpha during EC (uV)

% Interpolate between EO and EC amplitudes.
% ecSmooth approximately equals:
%   0 during EO
%   1 during EC

posteriorAlpha = posteriorAlphaEO + (posteriorAlphaEC - posteriorAlphaEO) * ecSmooth;

% Apply spatial weighting to the posterior alpha contribution.
alphaAmp = baselineAlpha + posterior * posteriorAlpha;




%% 17. MIX THE LATENT COMPONENTS ACROSS CHANNELS
% ----------------------------------------------------------------
% We now construct the initial multichannel EEG-like signals.
%
% Each channel is represented as a weighted mixture of the
% four previously generated spectral components.
%
% A simplified mixture can be written as:
%   X_i(t) = sum_k a_ik(t) * s_k(t)
%                 where:
%                 X_i(t)  = signal at channel i
%                 s_k(t)  = latent component k
%                 a_ik(t) = spatial and/or time-varying amplitude weight
%
% In our simulation:
%
%   Alpha contribution:
%       Stronger at posterior electrodes and during EC.
%
%   Theta contribution:
%       Increased toward frontal electrodes.
%
%   Beta contribution:
%       Slightly increased toward lateral electrodes.
%
%   Delta contribution:
%       Similar amplitude across electrodes.
%
% The resulting X matrix contains:
%
%   nCh rows    = EEG channels
%   N columns   = time samples
%
% IMPORTANT:
% All channels share the same four latent time series,
% with different spatial weights.
%
% This produces artificial cross-channel dependence.
% It is not a realistic model of neuronal connectivity.
% ----------------------------------------------------------------

X = alphaAmp .* latents(3,:) + ...
    (1.3 + frontal) .* latents(2,:) + ...
    (.7 + .5 * temporal) .* latents(4,:) + ...
    .7 * latents(1,:);




%% 18. DEFINE A 1/f-LIKE BACKGROUND NOISE SPECTRUM
% ----------------------------------------------------------------
% EEG signals often exhibit an aperiodic spectral component
% in which power decreases as frequency increases.
%
% This behavior is commonly described as 1/f-like activity.
%
% To approximate this, we apply a frequency-dependent
% amplitude weighting function to white noise:
%
%       H(f) = 1 / sqrt(max(f_min, f))
%
% Since power is proportional to squared amplitude,
% this produces approximately P(f) proportional to 1/f
% for frequencies above f_min.
%
% The lower frequency limit prevents division by zero
% and limits excessive low-frequency amplification.
%
% f_min = 0.5 Hz is a user-defined simulation parameter,
% not a physiological constant.

minFrequency = 0.5;  % Lower frequency limit (Hz)

% Create frequency bins from 0 Hz to the Nyquist frequency.
fAll = (0:floor(N/2)) * Fs / N;

% Define the spectral amplitude weighting function.
weights = 1 ./ sqrt(max(minFrequency, fAll));



%% 19. ADD INDEPENDENT COLORED NOISE TO EACH CHANNEL
% ----------------------------------------------------------------
% In the previous section, the EEG channels shared a small
% number of latent components.
%
% Here, we introduce channel-specific random fluctuations.
%
% For each channel:
%
%   1. Generate an independent random noise sequence.
%   2. Transform the noise using FFT.
%   3. Apply the frequency-dependent weighting function.
%   4. Return to the time domain using inverse FFT.
%   5. Normalize the noise standard deviation.
%   6. Add the noise to the existing channel signal.
%
% This makes the EEG channels less identical and adds
% approximately 1/f-like background fluctuations.
%
% The factor 2 controls the standard deviation of the
% added noise component before average referencing.
%
% Since signal amplitudes are intended to represent
% microvolts, the scaling is interpreted in microvolts.
% ----------------------------------------------------------------

for ch = 1:nCh

    % Generate an independent random sequence.
    noise = randn(1, N);

    % Transform the random sequence to the frequency domain.
    F = fft(noise);

    % Create a symmetric weighting function for the full FFT.
    spectral = [weights, weights(end-1:-1:2)];

    % Apply spectral weighting and return to the time domain.
    noise = real(ifft(F .* spectral));

    % Normalize noise amplitude and add it to the channel.
    X(ch,:) = X(ch,:) + 2 * noise / max(std(noise), eps);

end


%% 20. ADD A POSTERIOR 10-Hz OSCILLATORY COMPONENT
% ----------------------------------------------------------------
% We introduce an additional 10-Hz sinusoidal component.
%
% 10 Hz lies within the conventional alpha frequency range.
%
% Each channel receives a different random phase.
%
% The mathematical form is:
%   x_i(t) = A_i * sin(2*pi*f*t + phi_i)
%
%                   where:
%                   A_i   = amplitude determined by posterior weighting
%                   f     = 10 Hz
%                   phi_i = random phase for channel i
%
% rand(nCh,1) generates independent uniform random values
% between 0 and 1.
%
% The transformation:
%
%   -pi + 2*pi*rand(...)
%
% maps these values to the interval [-pi,pi].
%
% The amplitude is stronger at posterior electrodes.
%
% NOTE:
% Unlike the previously generated alpha-like latent source,
% this component is a pure sinusoid.
%
% It is not directly modulated by the EC/EO condition.
% Therefore, it may also be visible during eyes-open blocks.
%
% Its purpose is to provide a clearly identifiable
% narrowband 10-Hz spectral component.
% ----------------------------------------------------------------

phases = -pi + 2*pi*rand(nCh,1);

X = X + .6 * posterior .* sin(2*pi*10*t + phases);



%% 21. SIMULATE EYE-BLINK ARTIFACTS
% ----------------------------------------------------------------
% Eye blinks produce electrical artifacts in EEG recordings,
% usually with larger amplitudes over frontal electrodes.
%
% Here, each blink is modeled using a Gaussian-shaped pulse:
%
% B(t) = A * exp(-0.5 * ((t - t0) / sigma)^2)
%               A     : Blink amplitude (uV)
%               t0    : Center time of the blink (seconds)
%               sigma : Temporal standard deviation of the pulse (seconds)
%
% All parameters below are user-defined for this simulation.
% They are not estimated from real eye-blink recordings.
% ----------------------------------------------------------------

% Define the center times of simulated eye blinks (seconds).
% Irregular intervals are used to avoid perfectly periodic blinks.
blinkTimes = [7.2, 18.6, 39.5, 47.8, 68.0, 83.2, 101.3, 111.7];

% Define spatial amplitude parameters.
blinkBaseAmp = 3;       % Baseline contribution across channels (uV)
blinkFrontalAmp = 35;   % Additional frontal contribution (uV)

% Define the temporal width of each Gaussian pulse.
% Larger sigma values produce broader, slower artifacts.
blinkSigma = 0.13;      % Standard deviation in seconds

% Calculate blink amplitude for each EEG channel.
% Frontal electrodes receive stronger blink artifacts.
blinkAmp = blinkBaseAmp + blinkFrontalAmp * frontal;

% Add a Gaussian-shaped artifact at each blink time.
for bt = blinkTimes

    blinkWave = exp(-0.5 * ((t - bt) / blinkSigma).^2);

    % Multiply the temporal waveform by channel amplitudes.
    % blinkAmp:  nCh x 1
    % blinkWave: 1 x N
    % Result:    nCh x N

    X = X + blinkAmp * blinkWave;

end




%% 22. SIMULATE MUSCLE-LIKE ARTIFACTS
% ----------------------------------------------------------------
% EEG recordings can be contaminated by electrical activity
% generated by muscles (electromyographic activity, EMG).
%
% Facial and jaw muscle activity may introduce high-frequency
% noise, particularly in electrodes near the temporal regions.
%
% In this simulation, we add short bursts of random,
% high-frequency-rich noise to imitate muscle artifacts.
%
% We will:
%   1. Define when the artifacts occur.
%   2. Generate random noise for each EEG channel.
%   3. Emphasize rapid fluctuations in the noise.
%   4. Normalize the noise amplitude.
%   5. Add stronger artifacts to lateral electrodes.
%
% NOTE:
% The parameters below are chosen for educational purposes.
% They are not estimated from real EMG recordings.
% ----------------------------------------------------------------

% Define the start times of muscle artifacts (seconds).
% These times are manually selected to simulate three
% separate muscle activity episodes during the recording.

muscleOnsets = [24, 57, 96];

% Define how long each muscle artifact lasts.
muscleDuration = 2.4;  % Duration in seconds (user-defined)

% Define the target standard deviation of the artifact.
% At electrodes with temporal weight = 1, the added noise
% will have approximately this standard deviation before
% average referencing.

muscleArtifactStd = 7;  % Standard deviation in microvolts


% Generate and add each muscle artifact.
for onset = muscleOnsets

    % Step 1: Find samples within the artifact interval.
    % For example, onset = 24 and duration = 2.4 means
    % that the artifact occurs from 24.0 to 26.4 seconds.

    ix = find(t >= onset & t < onset + muscleDuration);


    % Step 2: Generate independent random noise for each channel.
    % randn produces normally distributed random values.
    %
    % Matrix dimensions:
    %   Rows    = EEG channels (64)
    %   Columns = samples within the artifact interval

    Z = randn(nCh, numel(ix));


    % Step 3: Emphasize rapid changes in the random noise.
    %
    % diff calculates differences between consecutive samples.
    % This reduces slowly varying components and produces
    % a signal with relatively stronger high-frequency content.
    %
    % The zero column preserves the original matrix size.

    Z = [zeros(nCh,1), diff(Z,1,2)];


    % Step 4: Normalize the noise separately for each channel.
    %
    % std(Z,0,2) calculates the standard deviation of each row.
    % Dividing by this value produces approximately unit
    % standard deviation in each channel.
    %
    % eps prevents division by zero.

    Z = Z ./ max(std(Z,0,2), eps);


    % Step 5: Add the muscle-like artifact to the EEG signal.
    %
    % muscleArtifactStd controls the noise amplitude.
    % temporal controls the spatial distribution:
    %
    %   temporal = 0 -> No added muscle artifact
    %   temporal = 1 -> Maximum artifact amplitude
    %
    % The artifact is stronger at lateral electrodes.

    X(:,ix) = X(:,ix) + muscleArtifactStd * temporal .* Z;

end




%% 23. SIMULATE 50-Hz ELECTRICAL INTERFERENCE
% ----------------------------------------------------------------
% EEG recordings can be contaminated by electrical power
% line interference.
%
% In countries using a 50-Hz electricity supply, such
% interference may appear as a narrowband component near 50 Hz.
%
% We simulate this using a sinusoidal signal:
%   x(t) = A * sin(2*pi*f*t)
%
% Here:
%   A = 0.45 microvolts
%   f = 50 Hz
%
% The same waveform is added to all channels.
%
% IMPORTANT:
% This creates perfectly common-mode interference.
%
% Because we apply a common average reference later,
% this identical component will be removed almost entirely
% by the referencing operation.
%
% Therefore, the final saved dataset should not be assumed
% to retain a visible 50-Hz interference peak.
%
% If a future tutorial aims to demonstrate line-noise removal,
% the interference model should be modified to include
% channel-specific amplitudes and/or phases.
% ----------------------------------------------------------------

X = X + .45 * sin(2*pi*50*t);


%% 24. INTRODUCE AN INTENTIONALLY NOISY CHANNEL SEGMENT
% ----------------------------------------------------------------
% In real EEG recordings, some channels may contain intervals
% with unusually high noise levels.
%
% Possible causes include:
%   - Poor electrode contact
%   - Electrode movement
%   - Cable movement
%   - Increased electrode impedance
%   - Other recording disturbances
%
% We simulate a noisy segment in channel F8.
% The noisy interval is:
%
%   Start: 72 seconds
%   End:   78 seconds
%
% First, we locate the sample indices corresponding
% to this interval.
%
% Next, we locate the F8 channel using its label.
%
% Finally, we add random noise with a standard deviation
% of 12 microvolts to this interval.
%
% This creates a known artifact for future tutorials
% about channel quality assessment and artifact detection.
%
% It does not reproduce a specific physical electrode fault.
% ----------------------------------------------------------------

ix = t >= 72 & t < 78;

f8 = find(labels == "F8");

X(f8,ix) = X(f8,ix) + 12 * randn(1, nnz(ix));


%% 25. APPLY COMMON AVERAGE REFERENCING
% ----------------------------------------------------------------
% EEG voltages are always measured relative to a reference.
%
% In common average referencing (CAR), the mean signal
% across all channels is subtracted from each channel.
%
% Mathematical definition:
%   X_CAR(i,t) = X(i,t) - mean_j(X(j,t))
%                       where:
%                         i = channel index
%                         j = all included EEG channels
%
% In MATLAB:
%   mean(X,1)
% calculates the mean across channels for each time sample.
% The resulting row vector is subtracted from all channels.
%
% After CAR, the channel average at each time point is
% approximately zero, apart from numerical precision.
%
% IMPORTANT:
% CAR can redistribute artifacts from noisy channels
% to other channels.
%
% Since we intentionally introduced artifacts in the dataset,
% this limitation should be considered during interpretation.
%
% In real EEG preprocessing, reference selection and bad-channel
% management require careful methodological decisions.
%
% Here, CAR is used as a simplified demonstration.
% ----------------------------------------------------------------

X = X - mean(X,1);


%% 26. ORGANIZE EEG DATA INTO A MATLAB STRUCTURE
% ----------------------------------------------------------------
% MATLAB structures allow us to store multiple related
% variables within a single organized data object.
%
% We create a structure named 'eeg'.
%
% Its fields contain:
%
%   eeg.data:
%       EEG signal matrix [channels x samples]
%
%   eeg.srate:
%       Sampling frequency in Hz
%
%   eeg.time_s:
%       Time vector in seconds
%
%   eeg.chanlabels:
%       EEG channel names
%
%   eeg.xyz_m:
%       Electrode coordinates in meters
%
%   eeg.units:
%       Signal amplitude unit
%
%   eeg.reference:
%       Description of the reference operation
%
%   eeg.description:
%       Statement identifying the data as synthetic
%
%   eeg.seed:
%       Random seed for reproducibility
%
% single(X) converts the data from double precision
% to single precision.
%
% Single precision requires approximately 4 bytes per value,
% compared with approximately 8 bytes for double precision.
%
% This reduces storage requirements.
%
% NOTE:
% The unit name 'uV' describes the intended simulated
% amplitude scale. The data are not calibrated measurements
% from real EEG equipment.
%
% Electrode coordinate units must agree with electrodes.tsv.
% ----------------------------------------------------------------

eeg = struct( ...
    'data', single(X), ...
    'srate', Fs, ...
    'time_s', t, ...
    'chanlabels', {cellstr(labels)}, ...
    'xyz_m', xyz, ...
    'units', 'uV', ...
    'reference', 'synthetic average reference', ...
    'description', 'SYNTHETIC simulation - NOT human EEG', ...
    'seed', 42);


%% 27. SAVE THE SYNTHETIC EEG DATASET
% ----------------------------------------------------------------
% The save function stores MATLAB variables in a MAT file.
%
% We save the EEG structure in the project's data folder.
%
% The file name:
%
%   synthetic_eeg_64ch.mat
%
% The -v7 option specifies MATLAB MAT-file format version 7.
%
% This format can be read by MATLAB and by several external
% scientific software libraries.
%
% The resulting file contains the 'eeg' structure.
%
% Future tutorials will load this file instead of generating
% the EEG signals again.
% ----------------------------------------------------------------

save(fullfile(root, 'data', 'synthetic_eeg_64ch.mat'), 'eeg', '-v7');


%% 28. DISPLAY A SUMMARY OF THE GENERATED RECORDING
% ----------------------------------------------------------------
% fprintf prints formatted information to the Command Window.
%
% %d displays an integer.
% %.0f displays a number with zero decimal places.
% \n inserts a new line.
%
% This output allows us to confirm:
%
%   - Number of EEG channels
%   - Number of samples
%   - Total recording duration
%
% Expected output:
%   Created 64 channels x 30720 samples (120 seconds).
% ----------------------------------------------------------------

fprintf('Created %d channels x %d samples (%.0f seconds).\n', ...
    nCh, N, seconds);


%% 29. VERIFY THE GENERATED DATASET
% ----------------------------------------------------------------
% Before moving to signal visualization or spectral analysis,
% we verify the dimensions and basic numerical properties.
%
% size(eeg.data):
%   Returns the number of channels and samples.
%
% isfinite:
%   Checks whether values are finite.
%
% The tests below should confirm:
%   1. The data matrix contains nCh rows.
%   2. Each channel has N samples.
%   3. There are no NaN or Inf values.
%   4. The channel labels match the coordinate matrix.
% ----------------------------------------------------------------

assert(isequal(size(eeg.data), [nCh, N]), ...
    'Unexpected EEG data dimensions.');

assert(all(isfinite(eeg.data(:))), ...
    'The generated EEG contains invalid numerical values.');

assert(size(xyz,1) == numel(labels), ...
    'Electrode coordinates and labels do not match.');

disp('Synthetic EEG dataset verification completed.');
