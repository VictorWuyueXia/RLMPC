# MATLAB sources (LMPC racing prototype)

## Suggested entry points

1. **Live scripts (interactive)**: open `../live_scripts/Launch.mlx` in MATLAB if that was your primary driver for simulations and visualization.
2. **Core race setup**: `initializeRace.m` builds dummy laps and initial buffers used by the LMPC loop.
3. **Controller step**: `solveLMPC.m` (work-in-progress in this snapshot) calls `linearModel.m` for linearization.

## Data dependencies

Track and cost data load from `../../data/track.mat` and related globals set before calling `initializeRace`. See `../../data/README.md` for `lambdas.mat` (large file; not committed).

## File map (active)

| File | Role |
|------|------|
| `initializeRace.m` | Race / track initialization, dummy laps |
| `solveLMPC.m` | LMPC solve step (prototype) |
| `linearModel.m` | Discrete linearization for MPC |
| `generate_combinations.m` | Combination generation helper |
| `linear_combinations.m` | Linear combination utilities |
| `updateLapCosts.m` | Lap cost updates |
| `KNeighbors.m` | Neighbor query helper |
| `dummyCar.m` / `discreteDummyCar.m` | Plant / discrete model helpers |
| `statesToXY.m` | State to XY mapping |

See `CANONICAL.md` for deduplication and archive notes.
