# DRL Herding (IJHC) — Supplementary Repository

This repository contains all supplementary materials for the paper:

1. Unity project used to train DRL agents, including training results for:
   - `DRL-AA`
   - `DRL-HP-AA`
2. Builds used for human–AI interaction experiments:
   - `exp1`
   - `exp2`
3. Stata code and datasets used for statistical analysis.

## Repository Structure

```text
.
├── 01_unity_project/
│   ├── training_results/
│   │   ├── DRL-AA/
│   │   └── DRL-HP-AA/
├── 02_human_ai_builds/
│   ├── exp1/
│   └── exp2/
└── 03_stata_analysis/
    ├── code/
    ├── data/
    │   ├── raw/
    │   └── processed/
    └── outputs/
```

## What to Place in Each Folder

### `01_unity_project/`
- Full Unity project used for training (Assets, Packages, ProjectSettings, etc.).
- Keep project-level documentation (Unity version, package list, scene/run instructions).

### `01_unity_project/training_results/DRL-AA/`
- Training logs, model checkpoints, metrics, and evaluation outputs for `DRL-AA`.

### `01_unity_project/training_results/DRL-HP-AA/`
- Training logs, model checkpoints, metrics, and evaluation outputs for `DRL-HP-AA`.

### `02_human_ai_builds/exp1/`
- Executable build and required runtime files used in Experiment 1.
- Include a short run note (platform, launch command, required dependencies).

### `02_human_ai_builds/exp2/`
- Executable build and required runtime files used in Experiment 2.
- Include a short run note (platform, launch command, required dependencies).

### `03_stata_analysis/code/`
- Stata scripts (`.do`) for data cleaning, model fitting, and result generation.

### `03_stata_analysis/data/raw/`
- Raw data exactly as collected/exported before processing.

### `03_stata_analysis/data/processed/`
- Analysis-ready datasets generated from raw data.

### `03_stata_analysis/outputs/`
- Generated tables, figures, logs, and exported statistical outputs.

## Suggested Minimal Documentation to Add

- Unity version and target platform(s).
- Which build corresponds to `exp1` vs `exp2`.
- Execution order for Stata scripts (e.g., `01_clean.do` → `02_model.do` → `03_tables.do`).
- Any data access/ethics constraints (if applicable).

## Notes

- Empty folders include `.gitkeep` files so Git tracks the directory layout.
- For large binaries/checkpoints, consider using Git LFS.
