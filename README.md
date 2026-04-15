# Sleep scoring with Olfactory Bulb

sleep-scoring pipeline based on olfactory bulb gamma and delta activity, hippocampal theta oscillations, and optionally accelerometer-derived movement.

This repository currently contains the **first internal version** of the pipeline. It is not yet a self-contained public package.

## What this repo does

At a high level, the pipeline:

1. standardizes the raw Open Ephys folder structure,
2. copies session metadata (`ExpeInfo.mat`),
3. converts Open Ephys `.npy` event folders into `.mat`,
4. runs preprocessing to build `LFPData`, `behavResources`, and channel metadata,
5. computes spectrograms and band-power summaries,
6. scores vigilance states using:
   - **OB gamma** to separate wake vs sleep,
   - **HPC theta/delta ratio** to separate REM vs non-REM,
   - or **OB high gamma** to separate REM vs non-REM
   - **OB delta** to separate N1 vs N2/N3,
   - optional **movement/accelerometer** scoring,
7. saves state epochs and summary figures in the session `ephys` folder.

## Repository structure

```text
OlfactoryBulb_VigilanceStates/
├── README.md
├── SleepScoring_Windows_WSL_configuration_guide.pdf
├── ob_preproc/
│   ├── Master_SleepScoring_preproc.m
│   ├── fix_folder_structure.m
│   ├── copy_ExpeInfo.m
│   ├── convertEvents2Mat_wrapper.m
│   ├── convertEvents2Mat.py
│   ├── calculate_spectrograms.m
│   ├── calculate_brain_power.m
│   ├── FilterLFP.m
│   └── ndm_scripts/
└── sleep_scoring/
    ├── SleepScoring_Ferret_FV_BAMG.m
    └── helpers/
        ├── FindNoiseEpoch_SleepScoring.m
        ├── FindGammaEpoch_SleepScoring.m
        ├── FindThetaEpoch_SleepScoring_Ferret_BM.m
        ├── FindREM_OBGamma_SleepScoring_Ferret_BM.m
        ├── Find_Delta_Epoch.m
        ├── FindMovementAccelero_SleepScoring.m
        ├── cleanSleepStates_BM.m
        ├── Figure_SleepScoring_OBGamma_Ferret.m
        └── Figure_SleepScoring_Accelero_Ferret.m
```

## Execution flow

### Full pipeline entry point

The main entry point is:

```matlab
Master_SleepScoring_preproc(sessions)
```

where `sessions` is a cell array of session folders:

```matlab
sessions = {
    'Z:\Arsenii\React_Active\experiment\Processed_data\Tvorozhok\20260224', ...
    'Z:\Arsenii\React_Active\experiment\Processed_data\Mochi\20260304'
};
```

### What `Master_SleepScoring_preproc` does

For each session, the script currently performs:

1. `fix_folder_structure(datapath)`  
   Moves `recording1` one level up when Open Ephys exported an extra `Record Node*/experiment*` nesting.

2. `copy_ExpeInfo(datapath)`  
   Copies `ExpeInfo.mat` into `<session>/ephys/` if it is found one level above the session folder.
   `ExpeInfo.mat` is a metadata file that contains electrode mapping and should be calibrated for each animal. Then, it can be reused as a template, for every animal-specific session.

4. `convertEvents2Mat_wrapper(...)`  
   Runs the bundled Python script over `continuous/` and `events/` folders to convert Open Ephys `.npy` files into `.mat`.

5. `GUI_StepOne_ExperimentInfo`
   This is expected to generate the lab-standard processed `ephys` outputs, notably `LFPData/`, `behavResources.mat`, and `ChannelsToAnalyse/`.

6. `RAE_make_run_manifest(...)` **(specific to React Active project. Must be ignored otherwise)**  
   Creates run manifests and higher-level epochs for React Active sessions.

7. `Master_LFP_NP_preproc(...)` **(Neuropixels specific)**  
   Extracts Neuropixels LFP channels for sleep scoring.

8. Writes `ChannelsToAnalyse/ThetaREM.mat` using a hard-coded hippocampal channel per animal.

9. `calculate_spectrograms(...)`

10. `SleepScoring_Ferret_FV_BAMG('recompute', 1, 'full_ob', 1)`

11. `calculate_brain_power(...)`

## Required data format

There are really **two valid input levels**:

- raw session format, for the **full pipeline**, and
- processed `ephys` format, for **sleep scoring only**.

### 1) Raw session format expected by the full pipeline

A session folder should look approximately like this before preprocessing:

```text
<session>/
├── ephys/
│   ├── <recording_A>/
│   │   └── recording1/
│   │       ├── continuous/
│   │       │   └── ... .dat files
│   │       │   └── ... .npy files
│   │       └── events/
│   │           └── ... .npy files
│   ├── <recording_B>/
│   │   └── recording1/
│   │       ├── continuous/
│   │       └── events/
│   └── ...
└── ../ExpeInfo.mat   or   <session>/ephys/ExpeInfo.mat
```

The helper `fix_folder_structure.m` also supports the Open Ephys layout where `recording1` is nested one level deeper:

```text
<session>/ephys/<recording>/Record Node*/experiment*/recording1/
```

and moves `recording1` up to:

```text
<session>/ephys/<recording>/recording1/
```

### 2) Minimal processed format required to run sleep scoring only

If preprocessing was already done elsewhere, then the scoring code expects the following under `ephys/`:

```text
<session>/ephys/
├── LFPData/
│   ├── LFP<channel>.mat
│   ├── LFP<channel>.mat
│   └── ...
├── ChannelsToAnalyse/
│   ├── Bulb_deep.mat
│   ├── ThetaREM.mat
│   └── optional other channel files
├── behavResources.mat
└── optional existing spectrum files
```

### Required file contents

#### `LFPData/LFP<channel>.mat`

Must contain a variable named:

- `LFP`

This variable is expected to be a lab-standard time series object compatible with functions such as:

- `Range`
- `Data`
- `Restrict`
- `tsd`

The code assumes the usual lab convention of timestamps in **1e-4 s units**.

#### `ChannelsToAnalyse/*.mat`

These files are expected to contain a scalar channel identifier, ideally as:

- `channel`

The most important files for sleep scoring are:

- `ChannelsToAnalyse/Bulb_deep.mat`
- `ChannelsToAnalyse/ThetaREM.mat`

Additional accepted filenames are also checked in some functions (not recommended):

- OB: `Bulb.mat`, `OB.mat`, `B.mat`
- HPC: `ThetaREM_ch.mat`, `HPC.mat`, `Hippocampus.mat`
- ACx: `AuCx.mat`, `ACx.mat`, `AuditoryCx.mat`, `AuCx_deep.mat`
- PFC: `PFC.mat`, `PFC_deep.mat`, `PFCx.mat`

#### `behavResources.mat`

Used only if movement-based scoring or stim masking is needed.

Expected variables:

- `MovAcctsd` for accelerometer / movement signal
- optionally `TTLInfo`, with `TTLInfo.StimEpoch`

If `behavResources.mat` or `MovAcctsd` is absent, the accelerometer branch is skipped.

### Spectrogram files

The plotting and noise-detection code expects spectrum files such as:

- `H_Low_Spectrum.mat`
- `B_Low_Spectrum.mat`
- `B_Middle_Spectrum.mat`

These are generated by `calculate_spectrograms.m`.

These files are expected to contain a cell array named `Spectro` with:

- `Spectro{1}`: power matrix
- `Spectro{2}`: time vector in seconds
- `Spectro{3}`: frequency vector in Hz

## Quick start

### A. Full pipeline from raw data

1. Add this repository and all external dependencies to the MATLAB path.
2. Open `ob_preproc/Master_SleepScoring_preproc.m`.
3. Edit the hard-coded local paths:

```matlab
github_location = {'D:\Arsenii\GitHub\NeuroMeta'; '/home/mathilde/GitHub'};
python_location = 'C:\Users\Arsenii Goriachenkov\.conda\envs\sleepscoring\python.exe';
```

4. Prepare your session list.
5. If you are using Linux, make ndm_scripts folder executable. If you work from windows computer, you might have to set up a WSL environment and add ndm_scripts folder to its path. At GUI step of preprocessing, these scripts will be executed in Linux environment. This process is described in `SleepScoring_Windows_WSL_configuration_guide.pdf`
6. Run:

```matlab
Master_SleepScoring_preproc(sessions)
```
or run it manually section by section (recommended):

**Prepare data**
After this step you should see:
1. `continuous_Acquisition_Board-100.acquisition_board.mat` file in `continuous` folder (or similar)
2. `Acquisition_Board-100.acquisition_board_TTL.mat` and `events_MessageCenter.mat` file in `events` folder (or similar)
3. `ExpeInfo.mat` in `ephys` folder

**GUI_StepOne_ExperimentInfo** step
1. Go to `ephys` folder or to the folder where you have `ExpeInfo.mat` file. 
2. This step ideally should be done once per animal. Then, you just copy `ExpeInfo.mat` file that you set up to all other sessions with the same layout.
   
<img width="1244" height="862" alt="image" src="https://github.com/user-attachments/assets/631f45b2-3c78-498a-b69c-80c4222a1c1b" />

Input all metadata. You can leave `Recording room`, `MouseNum`, `Mouse strain`, `Recording`, `Camera type` as it is. This is artefactual to MOBS pipeline and will be adapted to LSP in future versions.
click `I'm done` and then `Next step`

<img width="955" height="527" alt="image" src="https://github.com/user-attachments/assets/f52dae65-2b60-4f69-9b2d-33363241f0c4" />
Select `Num Wideband Channels`. This is the number of channels you have on your EIB (or the number of data channels you have recorded). Currently, we mostly use 16-channel layout.
Select `Num Accelero Channels`. We usually use head-stages with accelerometer. Each head-stage has 3 accelerometer channels. Calculate accordingly.
At the moment, we use 0 `Num Dig Channels`, 4 `Num Digital Inputs` and 8 `Num Analog Channels`. Change if it's different.
Click `I'm done`

Go to `Channel Identity`
<img width="2004" height="1243" alt="image" src="https://github.com/user-attachments/assets/6eddf30c-073b-4ef1-a22d-6739580250c3" />
Map channels according to your layout (you should know it from the surgery or you can deduce it from your recording)
Click `I'm done`

Go to `Digital Channel Identity`
<img width="550" height="730" alt="image" src="https://github.com/user-attachments/assets/e1e72493-68f1-46e1-874c-2f3e85df64da" />
Make sure the layout is as it is on the screenshot above. Or change it if it's different
Click `I'm done`

Go to `Channels to analyse`
<img width="575" height="922" alt="image" src="https://github.com/user-attachments/assets/00f43558-f31b-430a-adc9-8fe314bd0932" />
Here you select channels that will appear as scalar values in your ChannelsToAnalyse folder later and that will be used for Sleep Scoring and other analysis. I recommend looking at the raw signals in Neuroscope or OpenEphys and make decision based on signal quality.
Click `I'm done`

You can ignore `QualityChannels`

Click `Next Step`

<img width="909" height="798" alt="image" src="https://github.com/user-attachments/assets/314e6152-7ff6-4db9-9279-2b3fe337b3e4" />
Click `Get the data folders`
Answer questions: 
Is there ephys? 'yes'
Which software did you use? Likely, `OpenEphys or mixed`
Is there behaviour? `No`
Do you want to clean spike files? `No`
Number of folders to concatenate. If you have one continuous recording, then the answer is '1'. If you have multiple recordings, you can stitch them together here.
Click `GetFile`
Go to the folder where you have your `Continuous.dat` file
Input session name
If the signal is satisfactory, click `Ref done`. If not, you can manually select a channel and use it as a reference to your signal.
Click `I'm done`
Click on the folder path and select it.
Click `I'm done`
Have a little break, you're doing great so far!

### B. Sleep scoring only from an already processed `ephys` folder
In MATLAB:

```matlab
cd('<session>/ephys')
SleepScoring_Ferret_FV_BAMG('recompute', 1, 'full_ob', 1)
```

This assumes that at minimum:

- `LFPData/` exists,
- `ChannelsToAnalyse/Bulb_deep.mat` exists,
- `ChannelsToAnalyse/ThetaREM.mat` exists,
- required toolbox functions are on the path.

## Scoring logic

### 1. Noise removal

`FindNoiseEpoch_SleepScoring` defines noisy periods using:

- 18-20 Hz high-frequency noise,
- low-frequency grounding noise (< 2 Hz),
- optional manually thresholded high-amplitude LFP noise,
- optional manually entered weird/noisy periods,
- optional 200 ms windows after each stim onset (`TTLInfo.StimEpoch`).

Output:

- `Epoch`: valid non-noisy recording time
- `TotalNoiseEpoch`
- `SubNoiseEpoch`

### 2. Wake vs sleep from OB gamma

`FindGammaEpoch_SleepScoring` computes an OB gamma envelope and thresholds it.

In the ferret pipeline, the default operational band is:

- **40-60 Hz** for OB gamma sleep/wake separation

Low OB gamma = sleep candidate.

### 3. REM vs non-REM from hippocampal theta/delta ratio

`FindThetaEpoch_SleepScoring_Ferret_BM` computes:

- theta band: **3-6 Hz**
- denominator delta band: **0.2-3 Hz**

High theta/delta ratio inside sleep is classified as REM candidate.

### 4. REM from OB high gamma in the full-OB variant

`FindREM_OBGamma_SleepScoring_Ferret_BM` computes a second REM-like signal from:

- **50-75 Hz** OB gamma

This is used when `full_ob = 1`.

### 5. N1 vs N2/N3 from OB delta

`Find_Delta_Epoch` computes OB delta envelope:

- **0.5-4 Hz**

High OB delta inside non-REM sleep is classified as N2/N3 candidate. Remaining sleep is labeled N1.

### 6. State cleanup

`cleanSleepStates_BM` then enforces:

- merging nearby bouts,
- minimum state durations,
- no overlap,
- full coverage of the analyzed epoch,
- priority order: `Wake > REM > N2/N3 > N1`.

## Main outputs

All outputs are written in the session `ephys/` folder.

### Core sleep-scoring files

#### `SleepScoring_OBGamma.mat`

Contains OB+HPC-based scoring results. The script saves at least:

- `ISEpoch`
- `DeltaEpoch`
- `REMEpoch`
- `SWSEpoch`
- `Wake`
- `Sleep`
- `SmoothGamma`
- `ThetaEpoch`
- `SmoothTheta`
- `SmoothDelta_OB`
- `Info`
- `Epoch`
- `SubNoiseEpoch`
- `TotalNoiseEpoch`

#### `SleepScoring_Accelero.mat`

Contains movement-based scoring results when `MovAcctsd` is available. Saved variables include:

- `ISEpoch`
- `DeltaEpoch`
- `REMEpoch`
- `SWSEpoch`
- `Wake`
- `ImmobilityEpoch`
- `tsdMovement`
- `ThetaEpoch`
- `SmoothTheta`
- `SmoothDelta_OB`
- `Info`
- `Epoch`
- `SubNoiseEpoch`
- `TotalNoiseEpoch`

#### `SleepScoring_FullOB.mat`

Contains the full-OB variant where REM is derived from high OB gamma. Saved variables include:

- `ISEpoch`
- `DeltaEpoch`
- `REMEpoch`
- `SWSEpoch`
- `Wake`
- `Sleep`
- `SmoothGamma`
- `GammaHighEpoch_OB`
- `SmoothGamma_high`
- `SmoothDelta_OB`
- `Info`
- `Epoch`
- `SubNoiseEpoch`
- `TotalNoiseEpoch`

### Figures and logs

- `SleepScoringOB.png`
- `SleepScoringAccelero.png`
- `SleepScoring_history.txt`

### Spectrum files produced by `calculate_spectrograms`

Depending on available channels:

- `AuCx_Low_Spectrum.mat`
- `AuCx_Middle_Spectrum.mat`
- `B_UltraLow_Spectrum.mat`
- `B_Low_Spectrum.mat`
- `B_LowEvent_Spectrum.mat`
- `B_Middle_Spectrum.mat`
- `B_High_Spectrum.mat`
- `H_Low_Spectrum.mat`
- `H_Middle_Spectrum.mat`
- `PFCx_Low_Spectrum.mat`
- `PFCx_Middle_Spectrum.mat`

### Brain power summary

`calculate_brain_power.m` writes a `BrainPower` struct into `SleepScoring_OBGamma.mat` with:

- `BrainPower.signal_names`
- `BrainPower.Power`

## Interactive steps

The current first version is **not fully batch-safe**.

By default, several helper functions open figures and ask for user confirmation or threshold adjustment, including:

- noise thresholding,
- weird/noisy epoch entry,
- movement thresholding.

So even if you call the master script on multiple sessions, the run is still effectively semi-manual.

## Known issues and limitations

### 1. Missing `NoiseEpoch.mat` save

`FindNoiseEpoch_SleepScoring.m` checks whether `NoiseEpoch.mat` exists on re-run, but it never actually saves that file. So the caching logic is currently incomplete.

### 2. `calculate_brain_power` output is overwritten later

`calculate_brain_power.m` writes `BrainPower` into `SleepScoring_OBGamma.mat`, but `SleepScoring_Ferret_FV_BAMG.m` later recreates `SleepScoring_OBGamma.mat` with a plain `save(...)`, which overwrites that earlier content. As written, `BrainPower` is **not guaranteed to survive** the full pipeline.

### 3. Accelerometer-only mode is not truly supported yet

The script offers the possibility to continue without an OB channel, but later parts of the accelerometer branch still rely on `SleepOB` and `DeltaEpoch`. In practice, the current implementation should be treated as requiring:

- one OB channel, and
- one HPC/theta channel.

### 4. Hard-coded animal/channel logic

`Master_SleepScoring_preproc.m`, `calculate_spectrograms.m`, and `calculate_brain_power.m` contain hard-coded channel assumptions for specific animals. For a new animal, you should either:

- provide the correct files in `ChannelsToAnalyse/`, or
- edit the hard-coded logic.

### 5. Hard-coded local installation paths

`Master_SleepScoring_preproc.m` contains machine-specific paths for:

- GitHub root,
- Python executable.

These must be edited before use on another machine.

## Authors / provenance

This ferret-adapted sleep-scoring workflow is based on earlier MOBs lab sleep-scoring code and was adapted over time by multiple contributors, as acknowledged in the headers:

- Sophie Bagur
- Samuel Laventure
- Baptiste Maheo
- Arsenii Goriachenkov
- and earlier MOBs lab contributors

