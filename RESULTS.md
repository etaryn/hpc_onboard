# RESULTS

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
