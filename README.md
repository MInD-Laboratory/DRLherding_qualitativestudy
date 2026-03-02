# DRL Herding Qualitative Study
# Supplementary Repository for paper
Add DOI and citation here

This repository contains supplementary materials for the DRL herding study:

1. DRL training builds and outputs from Unity/ML-Agents (`DRL-AA`, `DRL-HP-AA`)
2. Human–AI experiment builds (Experiment 1 and Experiment 2)
3. Stata scripts, datasets, and analysis outputs

## DRL Training Builds and Results (ML-Agents)

- The Unity builds used to train DRL agents with ML-Agents are stored in their respective methodology folders.
- Training run outputs for each methodology are stored in:
   - `01_DRL_training/training_results/DRL-AA/`
   - `01_DRL_training/training_results/DRL-HP-AA/`

These are Unity headless Linux training builds and are intended to be launched through `mlagents-learn` with the corresponding YAML config file (hyperparameters, trainer settings, and run options).

### Requirements (training)
- Linux machine/environment with Unity-compatible execution support.
- Python + `mlagents` installed.
- A training config YAML for the target methodology.

### Launching training
1. Go to the folder for the target methodology build/config.
2. Start training with `mlagents-learn` and the respective YAML.
3. Pass the Unity headless build path with `--env`.

`Example mlagents command`:

```bash
mlagents-learn Herders_BB.yaml --env Shepherding_BB.x86_64 --run-id Shepherding_TS_1
```

ML-Agents documentation: https://github.com/Unity-Technologies/ml-agents

## Running the Experiment Builds

### Requirements
- Windows machine (the included builds are Windows executables).

### Experiment 1
1. Open `02_exp_builds/Herding_preference_study_Exp1/`.
2. Run `DesktopHerding_HumanAI_Experiments_2022.exe`.
3. The experiment launches directly in full-screen mode and runs end-to-end.

### Experiment 2
1. Open `02_exp_builds/Herding_preference_study_Exp2/`.
2. Choose one build version:
   - `ver1`
   - `ver2`
3. Run `DesktopHerding_HumanAI_Experiments_2022.exe` inside the selected version folder.
4. The experiment launches directly in full-screen mode and runs end-to-end.

`Exp2` includes two versions because Agent 1 and Agent 2 labels were counterbalanced between `DRL-AA` and `DRL-HP-AA`.

## Output Data Location

After each run, experiment output is saved under:

- `DesktopHerding_HumanAI_Experiments_2022_Data/OutData`

Within this folder, CSV exports are located in:

- `DesktopHerding_HumanAI_Experiments_2022_Data/OutData/CSV`
