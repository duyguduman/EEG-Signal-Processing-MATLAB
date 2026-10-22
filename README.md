# EEG Signal Processing with MATLAB

**An open-source tutorial series on EEG simulation, visualization, and signal processing using MATLAB.**

This repository explores the computational foundations of electroencephalography (EEG) through documented MATLAB scripts and reproducible examples. The first tutorials cover the generation of a **64-channel synthetic EEG recording**, visualization of multichannel time series, and an introduction to the frequency domain using the **Fast Fourier Transform (FFT)**. Further signal-processing methods will be added as the series develops.

> **Data disclaimer:** All EEG signals in this repository are **synthetic**, not recordings from human participants. The examples are intended for education and methodological demonstrations; the simulation is not a physiologically validated model of human EEG.

## What you'll learn

- How EEG data are organized as **channels × samples**, with electrode labels, positions, and sampling metadata.
- How to build a controlled EEG-like simulation with oscillatory activity, condition blocks, and artifacts.
- How to inspect **multichannel recordings** and individual electrode traces in the time domain.
- How to introduce **frequency-domain analysis** using the FFT and compare simulated eyes-closed (EC) and eyes-open (EO) conditions.
- How to export reproducible figures for scientific documentation.

## Repository structure

```text
EEG-Signal-Processing-MATLAB/
├── README.md
├── LICENSE
├── data/
│   ├── electrodes.tsv
│   └── synthetic_eeg_64ch.mat
├── figures/
│   ├── 01_raw_traces.{png,svg,fig}
│   ├── 01_O1_full_recording.{png,svg,fig}
│   ├── 01_O1_zoom.{png,svg,fig}
│   ├── 01_O1_fft_spectrum.{png,svg,fig}
│   └── 01_EC_EO_fft_comparison.{png,svg,fig}
└── matlab/
    ├── 00_generate_synthetic_eeg.m
    └── 01_visualize_raw_eeg.m
```

## Requirements

- **MATLAB R2024**.
- No EEGLAB or third-party EEG toolbox is required for the current tutorials.

## Getting started

1. Download or clone this repository from [GitHub](https://github.com/duyguduman/EEG-Signal-Processing-MATLAB).
2. In MATLAB, set the **Current Folder** to the repository's `matlab` subfolder. Both scripts use `fileparts(pwd)` to locate the project root, so this step is important.
3. Run Tutorial 00 to regenerate the synthetic dataset, or use the supplied `.mat` file directly.
4. Run Tutorial 01 to load the dataset, display the EEG figures, and export them to `figures/`.

```matlab
% Run these commands with Current Folder set to:
% EEG-Signal-Processing-MATLAB/matlab

run('00_generate_synthetic_eeg.m');
run('01_visualize_raw_eeg.m');
```

The MATLAB scripts contain numbered `%%` sections, so you can also work through them one section at a time in the MATLAB Editor.

## Tutorials

### Tutorial 00 — Synthetic EEG generation

**Script:** [`00_generate_synthetic_eeg.m`](matlab/00_generate_synthetic_eeg.m)

Generates a synthetic recording with **64 EEG channels**, a **256 Hz** sampling rate, and a duration of **120 seconds**. The simulation includes delta-, theta-, alpha-, and beta-like components, spatially varying amplitudes, alternating EC/EO blocks, 1/f-like background noise, artificial eye blinks, muscle-like artifacts, and an intentionally noisy segment. The signal is then assigned a synthetic average reference.

The parameter values and artifact models were selected for instructional purposes; they are not estimates from participant recordings.

### Tutorial 01 — EEG visualization and an introduction to FFT

**Script:** [`01_visualize_raw_eeg.m`](matlab/01_visualize_raw_eeg.m)

Loads the generated recording and demonstrates channel selection by electrode name, vertically offset multichannel traces, inspection of a full channel and a short excerpt, single-sided FFT amplitude spectra, and a basic EC/EO spectral comparison. The script exports **PNG**, **SVG**, and editable MATLAB **FIG** files.

The FFT visualizations are introductory and should not be interpreted as PSD estimates. Spectral estimation and Welch's method will be addressed separately.

## Simulated recording design

| Time (s) | Condition |
|---|---|
| 0–30 | Eyes closed (EC) |
| 30–60 | Eyes open (EO) |
| 60–90 | Eyes closed (EC) |
| 90–120 | Eyes open (EO) |

Posterior alpha activity was **intentionally made stronger in EC blocks**, so an EC/EO difference is an expected property of the simulation rather than an empirical finding.

## Figures

### 1. Multichannel EEG traces

Sixteen selected channels over a five-second window, displayed with vertical offsets for readability. The offsets are for plotting only and are not changes to the stored EEG signals.

![Synthetic multichannel EEG traces](figures/01_raw_traces.png)

### 2. Full O1 recording: eyes closed and eyes open

The O1 channel over the full 120-second recording, with background shading indicating the simulated EC and EO blocks.

![O1 recording and EC/EO blocks](figures/01_O1_full_recording.png)

### 3. A one-second O1 excerpt

A closer look at the time-domain waveform; shorter intervals make individual oscillations easier to inspect.

![Zoomed O1 EEG excerpt](figures/01_O1_zoom.png)

### 4. O1 FFT amplitude spectrum

A first visualization of the frequency content of an EC segment. This plot shows a **single-sided amplitude spectrum**, not power spectral density.

![O1 FFT amplitude spectrum](figures/01_O1_fft_spectrum.png)

### 5. EC versus EO: FFT amplitude spectra

A comparison of equally long synthetic EC and EO segments from O1. Posterior alpha modulation was built into the generator, so differences near the alpha range should be interpreted in that context.

![EC and EO FFT amplitude spectrum comparison](figures/01_EC_EO_fft_comparison.png)

## Scope and limitations

- The signals and artifacts are simplified simulations, **not physiologically validated EEG or EMG recordings**.
- Channel-level spatial weighting is not a model of individual cortical sources.
- The current simulation does **not** provide ground truth for evaluating directed connectivity methods.
- The FFT figures introduce the frequency domain; **PSD estimation, Welch's method, and time-frequency analysis** are separate topics.
- **Scalp topographic maps** will be addressed in a dedicated tutorial. Interpolated scalp maps should not be interpreted as source localization.

## Planned extensions

Future tutorials may cover PSD and Welch's method, scalp topographic mapping, STFT, wavelet and synchrosqueezing transforms, and EEG connectivity analyses. Planned topics are not yet part of the released scripts.

## License and reuse

The original MATLAB code is shared under the [MIT License](LICENSE). If reusing the teaching materials, please make clear that the example EEG dataset is synthetic. The source and redistribution permissions for any third-party electrode coordinate templates should be checked separately.

## Author

**Duygu Duman**  
Biomedical Engineering · EEG Signal Processing · Brain Connectivity
