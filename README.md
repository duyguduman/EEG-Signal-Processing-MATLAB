# EEG Signal Processing with MATLAB

**An open-source, step-by-step tutorial series on synthetic EEG generation, visualization, and signal processing.**

This repository pairs documented MATLAB scripts with an explanatory [GitHub Wiki](https://github.com/duyguduman/EEG-Signal-Processing-MATLAB/wiki). The scripts provide reproducible examples; the Wiki explains the underlying concepts, equations, implementation choices, and limitations for readers who are new to EEG analysis.

> **Synthetic data only.** The dataset is generated computationally and contains no recordings from human participants. It is intended for teaching and methodological demonstrations, not physiological validation.

## Start here

| Tutorial | Topic | Read the guide | MATLAB script |
|---|---|---|---|
| 00 | Synthetic EEG Data Generation | [Tutorial 00 — Wiki](https://github.com/duyguduman/EEG-Signal-Processing-MATLAB/wiki/Tutorial-00) | [`00_generate_synthetic_eeg.m`](matlab/00_generate_synthetic_eeg.m) |
| 01 | Visualizing a Synthetic Multichannel EEG Recording | [Tutorial 01 — Wiki](https://github.com/duyguduman/EEG-Signal-Processing-MATLAB/wiki/Tutorial-01) | [`01_visualize_raw_eeg.m`](matlab/01_visualize_raw_eeg.m) |

**New to EEG or MATLAB?** Start with [Tutorial 00](https://github.com/duyguduman/EEG-Signal-Processing-MATLAB/wiki/Tutorial-00). You can read the explanations and run each numbered `%%` section in MATLAB as you go.

## What is included?

The current example is a **64-channel, 256 Hz, 120-second** synthetic recording (30,720 samples per channel). It includes delta-, theta-, alpha-, and beta-like activity; alternating eyes-closed (EC) and eyes-open (EO) blocks; stronger simulated posterior alpha during EC; and deliberately added artifacts for demonstration.

Tutorial 01 introduces multichannel traces, short time windows, condition labeling, FFT amplitude spectra, and a simple EC/EO comparison. **FFT amplitude spectra are not PSD estimates**; formal PSD and Welch analysis will be addressed in a separate tutorial.

## Preview: MATLAB outputs

**Multichannel traces** — 16 selected electrodes in a five-second excerpt. The vertical offsets are for display only.

![Synthetic multichannel EEG traces](figures/01_raw_traces.png)

**Eyes closed vs. eyes open** — O1 over the full recording, with the simulated condition blocks marked.

![Synthetic O1 EEG recording with EC and EO blocks](figures/01_O1_full_recording.png)

**Frequency-domain comparison** — FFT amplitude spectra for equally long EC and EO segments. The posterior alpha difference was built into the simulation.

![Synthetic O1 EC versus EO FFT amplitude spectra](figures/01_EC_EO_fft_comparison.png)

Additional figures: [one-second O1 excerpt](figures/01_O1_zoom.png) · [O1 FFT spectrum](figures/01_O1_fft_spectrum.png). See [Tutorial 01 in the Wiki](https://github.com/duyguduman/EEG-Signal-Processing-MATLAB/wiki/Tutorial-01) for explanations and interpretation.

## Quick start

**Requirements:** MATLAB R2024 (or a compatible version). The current scripts do not require EEGLAB or third-party EEG toolboxes.

1. Download or clone this repository.
2. In MATLAB, set **Current Folder** to `EEG-Signal-Processing-MATLAB/matlab`.
3. Run the generator to recreate the dataset, then run the visualization script. Alternatively, skip the generator and use the supplied MAT file.

```matlab
% Current Folder: EEG-Signal-Processing-MATLAB/matlab
run('00_generate_synthetic_eeg.m');
run('01_visualize_raw_eeg.m');
```

The scripts use `fileparts(pwd)` to find the repository root and write outputs to `data/` and `figures/`. For detailed, beginner-oriented explanations, use the [Wiki](https://github.com/duyguduman/EEG-Signal-Processing-MATLAB/wiki).

## Repository layout

```text
EEG-Signal-Processing-MATLAB/
├── README.md
├── LICENSE
├── data/
│   ├── electrodes.tsv
│   └── synthetic_eeg_64ch.mat
├── figures/
│   └── 01_*.png / .svg / .fig
└── matlab/
    ├── 00_generate_synthetic_eeg.m
    └── 01_visualize_raw_eeg.m
```

## Next topics

Planned tutorials include PSD and Welch's method, scalp topographic mapping, time-frequency analysis (STFT, wavelets, synchrosqueezing), and EEG connectivity. These are **planned**, not included in the current release.

## Scientific scope

The spectral components, spatial weights, and artifacts are simplified educational models. The current dataset does not represent measured brain activity or provide validated ground truth for directed connectivity or source localization. The simulated EC/EO differences are design choices, not empirical findings.

## License and author

Original MATLAB code: [MIT License](LICENSE). Third-party electrode-coordinate templates may have separate licensing and attribution requirements; their provenance should be checked before reuse.

**Duygu Duman** · Biomedical Engineering · EEG Signal Processing · Brain Connectivity
