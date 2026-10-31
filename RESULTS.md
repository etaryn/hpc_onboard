# RESULTS

One row per run, failures included. % Rpeak uses Rpeak = 7270.4 GFLOPS/node (assumption, see HARDWARE.md).
Runs 1-16 are all single-node on xcni; Slurm job IDs were not captured before run.sh started printing them.

| # | date | commit | nodes | ranks x threads | P x Q | N | NB | other knobs | time (s) | GFLOPS | % Rpeak | PASSED? | notes |
|---|------|--------|-------|-----------------|-------|---|----|-------------|----------|--------|---------|---------|-------|
| 1 | 2026-10-30 | 818d816 | 1 (xcni0) | 64x1 | 8x8 | 10000 | 256 | PFACT=R RFACT=C NBMIN=4 NDIV=2 BCAST=1rM DEPTH=1 SWAP=mix; BLIS 5.0 (amdzen), own OpenMPI 4.1.6 | 0.48 | 1391.3 | tbd (Rpeak for xcni not fixed yet) | PASSED (3.96328737e-03) | correctness run only; many `Read -1, expected 10240, errno = 1` lines from vader CMA (job id not captured) |
| 2 | 2026-10-30 | fd934a4 | 1 (xcni) | 64x1 | 8x8 | 80000 | 256 | same HPL.dat knobs as #1; vader single-copy off | 114.73 | 2975.2 | 40.9 (vs 7270.4 assumed) | PASSED (2.73986968e-03) | job 1041018; Rpeak = 64 cores x 3.55 GHz (vendor base, unverified) x 32 FLOP/cycle |
| 3 | 2026-10-30 | b93ef0f | 1 (xcni) | 64x1 | 8x8 | 46080 | 192 | NB sweep, other knobs as #1; BLIS picked zen5 | 27.66 | 2358.4 | 32.4 | PASSED (2.66824432e-03) |  (job id not captured) |
| 4 | 2026-10-30 | b93ef0f | 1 (xcni) | 64x1 | 8x8 | 46080 | 256 | NB sweep, other knobs as #1; BLIS picked zen5 | 24.31 | 2683.7 | 36.9 | PASSED (2.53702174e-03) |  (job id not captured) |
| 5 | 2026-10-30 | b93ef0f | 1 (xcni) | 64x1 | 8x8 | 46080 | 320 | NB sweep, other knobs as #1; BLIS picked zen5 | 21.68 | 3009.2 | 41.4 | PASSED (3.11362091e-03) |  (job id not captured) |
| 6 | 2026-10-30 | b93ef0f | 1 (xcni) | 64x1 | 8x8 | 46080 | 384 | NB sweep, other knobs as #1; BLIS picked zen5 | 20.56 | 3173.3 | 43.6 | PASSED (2.78637526e-03) | best NB (job id not captured) |
| 7 | 2026-10-30 | b93ef0f | 1 (xcni) | 64x1 | 8x8 | 46080 | 512 | NB sweep, other knobs as #1; BLIS picked zen5 | 23.52 | 2773.6 | 38.1 | PASSED (2.95935318e-03) |  (job id not captured) |
| 8 | 2026-10-30 | 1eb1fb8 | 1 (xcni) | 64x1 | 8x8 | 46080 | 384 | grid sweep, other knobs as #1 | 20.87 | 3126.3 | 43.0 | PASSED (2.99187676e-03) | job id not captured |
| 9 | 2026-10-30 | 1eb1fb8 | 1 (xcni) | 64x1 | 4x16 | 46080 | 384 | grid sweep, other knobs as #1 | 19.92 | 3274.0 | 45.0 | PASSED (3.03730013e-03) | job id not captured |
| 10 | 2026-10-30 | 1eb1fb8 | 1 (xcni) | 64x1 | 16x4 | 46080 | 384 | grid sweep, other knobs as #1 | 27.19 | 2399.5 | 33.0 | PASSED (3.33896545e-03) | job id not captured |
| 11 | 2026-10-30 | 1eb1fb8 | 1 (xcni) | 64x1 | 2x32 | 46080 | 384 | grid sweep, other knobs as #1 | 22.33 | 2921.3 | 40.2 | PASSED (3.34813783e-03) | job id not captured |
| 12 | 2026-10-30 | a7c69c9 | 1 (xcni) | 64x1 | 4x16 | 46080 | 384 | ranks x threads sweep; OMP_PLACES=cores PROC_BIND=close; map-by slot:PE=T | 19.88 | 3281.8 | 45.1 | PASSED (2.84159225e-03) | job id not captured |
| 13 | 2026-10-30 | a7c69c9 | 1 (xcni) | 32x2 | 4x8 | 46080 | 384 | ranks x threads sweep; OMP_PLACES=cores PROC_BIND=close; map-by slot:PE=T | 18.77 | 3475.9 | 47.8 | PASSED (2.99264417e-03) | job id not captured |
| 14 | 2026-10-30 | a7c69c9 | 1 (xcni) | 16x4 | 4x4 | 46080 | 384 | ranks x threads sweep; OMP_PLACES=cores PROC_BIND=close; map-by slot:PE=T | 17.62 | 3702.8 | 50.9 | PASSED (3.47203804e-03) | job id not captured |
| 15 | 2026-10-30 | a7c69c9 | 1 (xcni) | 8x8 | 2x4 | 46080 | 384 | ranks x threads sweep; OMP_PLACES=cores PROC_BIND=close; map-by slot:PE=T | 19.53 | 3340.2 | 45.9 | PASSED (3.63630038e-03) | job id not captured |
| 16 | 2026-10-30 | a7c69c9 | 1 (xcni) | 2x32 | 1x2 | 46080 | 384 | ranks x threads sweep; OMP_PLACES=cores PROC_BIND=close; map-by slot:PE=T | 29.12 | 2240.5 | 30.8 | PASSED (4.81312856e-03) | job id not captured |
| 17 | 2026-10-30 | 7bebd1f | 1 (xcni) | 16x4 | 4x4 | 10000 | 256 | post-cleanup sanity, config/tuning/test.dat via `make run`; job 1041536 | 0.33 | 2022.1 | 27.8 | PASSED (4.08286292e-03) | pipeline OK after cleanup; tiny N, not a score |
| 18 | 2026-10-31 | 5e2cd60 | 2 (xcni[2-3]) | 16x4 | 4x8 | 65280 | 384 | default NIC selection; job 1049115 | - | - | - | HUNG, cancelled at 25 min | xhpl 99.9% CPU, RSS 10 MB; `connect() to 192.168.58.21:1031 failed`; fixed by 22af5da (pin to 192.168.48.0/21) |
| 19 | 2026-10-31 | 22af5da | 2 (xcni[0-1]) | 16x4 | 4x4 (!) | 65280 | 384 | rt_sweep, job 1049194; intended 4x8 | 46.27 | 4008.7 | 27.6 | PASSED (3.44688494e-03) | INVALID config: 4x4 grid on 32 ranks leaves 16 ranks idle (maxrss 36 GB vs 18 GB elsewhere = matrix on one node). Likely HPL.dat clobbered by a second concurrent sweep (job 1049195 was from it); rerun as run 22 |
| 20 | 2026-10-31 | 22af5da | 2 (xcni[0-1]) | 16x4 | 2x16 | 65280 | 384 | rt_sweep, job 1049199; map-by slot:PE=4, OMP close | 31.43 | 5900.7 | 40.6 | PASSED (2.35129699e-03) | first valid 2-node score; 1.59x the 1-node best (3702.8) |
| 21 | 2026-10-31 | 22af5da | 2 (xcni[0-1]) | 8x8 | 4x4 | 65280 | 384 | rt_sweep, job 1049203 | 39.65 | 4677.4 | 32.2 | PASSED (3.40056232e-03) | fewer, fatter ranks lose to 16x4 here |
| 22 | 2026-10-31 | 1b700c7 | 2 (xcni[0-1]) | 16x4 | 4x8 | 65280 | 384 | rt_sweep alone, job 1049243 | 35.52 | 5221.7 | 35.9 | PASSED (2.67250229e-03) | clean rerun of run 19: 4x8 is 11.5% slower than 2x16 (wider is better) |
| 23 | 2026-10-31 | 22af5da | 2 (xcni[0-1]) | 8x8 | 4x4 | 65280 | 384 | job 1049195, from the duplicate sweep | 40.18 | 4615.8 | 31.7 | residual not captured | repeat of run 21 (4677.4): 1.3% apart, within noise |
| 24 | 2026-10-31 | 914bbba | 2 (xcni[0-1]) | 16x4 | 1x32 | 65280 | 384 | rt_sweep alone, job 1049265 | 40.68 | 4559.6 | 31.4 | PASSED (2.41133216e-03) | too flat: grid ranking 2x16 (5900.7) > 4x8 (5221.7) > 1x32 (4559.6) |
| 25 | 2026-10-31 | a43550b | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 320 | rt_sweep NBS="320 384 448" one job 1049272, 2x16 | 35.50 | 5698.5 | 39.2 | PASSED (2.22407938e-03) | NB sweep, 3% below 384 |
| 26 | 2026-10-31 | a43550b | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 384 | rt_sweep NBS="320 384 448" one job 1049272, 2x16 | 34.45 | 5873.4 | 40.4 | PASSED (2.59701323e-03) | best NB again (matches run 20 at N=65280: 5900.7) |
| 27 | 2026-10-31 | a43550b | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 448 | rt_sweep NBS="320 384 448" one job 1049272, 2x16 | 38.87 | 5205.5 | 35.8 | PASSED (2.42581663e-03) | 11% below 384 |
| 28 | 2026-10-31 | 0463c2f | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 384 | BCAST=0 (1rg); one job 1049307 (WR10C2R4) | 34.53 | 5858.8 | 40.3 | PASSED (2.39574637e-03) | within noise of 1rM |
| 29 | 2026-10-31 | 0463c2f | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 384 | BCAST=1 (1rM); one job 1049307 (WR11C2R4) | 34.16 | 5923.0 | 40.7 | PASSED (2.59029708e-03) | best; current default |
| 30 | 2026-10-31 | 0463c2f | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 384 | BCAST=2 (2rg); one job 1049307 (WR12C2R4) | 35.33 | 5726.6 | 39.4 | PASSED (2.67837801e-03) | 3.3% below 1rM |
| 31 | 2026-10-31 | 0463c2f | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 384 | BCAST=3 (2rM); one job 1049307 (WR13C2R4) | 34.91 | 5795.6 | 39.9 | PASSED (2.32060123e-03) | 2.2% below 1rM |
| 32 | 2026-10-31 | 0463c2f | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 384 | BCAST=4 (Lng); one job 1049307 (WR14C2R4) | 54.94 | 3682.5 | 25.3 | PASSED (2.58090230e-03) | 38% below 1rM |
| 33 | 2026-10-31 | 0463c2f | 2 (xcni[0-1]) | 16x4 | 2x16 | 67200 | 384 | BCAST=5 (LnM); one job 1049307 (WR15C2R4) | 47.87 | 4226.8 | 29.1 | PASSED (2.58090230e-03) | 29% below 1rM |

## Failed launch attempts (no HPL output; before run #1)
| what | symptom | cause / fix |
|---|---|---|
| `srun --mpi=pmix` + Debian Open MPI 4.1.6, 64 ranks | segfault in `libpmix.so.2` `pmix_hwloc_setup_topology` | system PMIx unusable; built own Open MPI |
| same + `PMIX_MCA_gds=hash`, `OMPI_MCA_orte_tmpdir_base=/dev/shm` | `ORTE_ERROR_LOG ... session_dir.c` in MPI_Init | same root cause |
| `salloc` + Debian `mpirun` | "ORTE has lost communication with a remote daemon" | same root cause |
| own Open MPI, `--ntasks-per-node=64` (64 of 128 CPUs) | `hwloc_set_cpubind returned "Error" for bitmap "35,99"` | cpuset held one HT sibling only; ask for whole cores (`-c 2`) |
| `--exclusive` | `Exclusive node access is not permitted` | policy; use `-c` instead |
| `-c 2` x 64 tasks, default memory | `Requested node configuration is not available` | 3072 MB/CPU x 128 > node RAM; add `--mem=0` |
