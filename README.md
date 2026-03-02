# DRL Herding (IJHC) — Supplementary Repository

This repository contains supplementary materials for the DRL herding study:

1. DRL training outputs from Unity/ML-Agents (`DRL-AA`, `DRL-HP-AA`)
2. Human–AI experiment builds (Experiment 1 and Experiment 2)
3. Stata scripts, datasets, and analysis outputs

## Running the Experiment Builds

### Requirements
- Windows machine (the included builds are Windows executables).

### Experiment 1
1. Open `02_human_ai_builds/Herding_preference_study_Exp1/`.
2. Run the `.exe` file in that folder.
3. The experiment launches directly in full-screen mode and runs end-to-end.

### Experiment 2
1. Open `02_human_ai_builds/Herding_preference_study_Exp2/`.
2. Choose one build version:
   - `ver1`
   - `ver2`
3. Run the `.exe` file inside the selected version folder.
4. The experiment launches directly in full-screen mode and runs end-to-end.

`Exp2` includes two versions because Agent 1 and Agent 2 labels were counterbalanced between `DRL-AA` and `DRL-HP-AA`.

## Output Data Location

After each run, experiment output is saved under:

- `DesktopHerding_HumanAI_Experiments_2022_Data/OutData`

Within this folder, CSV exports are located in:

- `DesktopHerding_HumanAI_Experiments_2022_Data/OutData/CSV`
