# Portfolio summary (for reviewers)

## One-line pitch

MATLAB prototype for **learning-informed / data-driven MPC-style autonomous racing** on a defined track, with supporting analysis and visualization live scripts.

## What is in this repository

- **Written report**: `report/VXia_FinalReport.pdf`
- **Code**: `../src/matlab` (core `.m` files) and `../src/live_scripts` (`.mlx` drivers)
- **Data**: `../data/track.mat` (small); large `lambdas.mat` is intentionally not committed
- **Figures**: `figures/` exports for quick visual scanning in the Git hosting UI

## What is intentionally excluded

Third-party vehicle simulation (ADVISOR), full reference codebases, and a personal PDF library — see `MATERIALS_OUTSIDE_REPO.md`.

## Reproducibility (honest scope)

- **MATLAB** with Live Editor support for `.mlx` files.
- **Toolboxes**: depends on your local configuration when the project was built (Optimization, Control System, etc.); confirm against your MATLAB session before claiming a minimal toolbox list.
- **Large binary** `lambdas.mat`: restore from your private backup if required for full replication.

## Suggested reading order

1. Skim rasterized pages under `figures/report_p*.png` or open the PDF.
2. Open `../src/live_scripts/Launch.mlx` if available.
3. Read `../src/matlab/initializeRace.m` then `solveLMPC.m` for algorithm structure.
