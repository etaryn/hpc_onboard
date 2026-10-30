# RESULTS

| # | date | commit | nodes | ranks x threads | P x Q | N | NB | other knobs | time (s) | GFLOPS | % Rpeak | PASSED? | notes |
|---|------|--------|-------|-----------------|-------|---|----|-------------|----------|--------|---------|---------|-------|
| 1 | 2026-10-30 | 818d816 | 1 (xcni0) | 64x1 | 8x8 | 10000 | 256 | PFACT=R RFACT=C NBMIN=4 NDIV=2 BCAST=1rM DEPTH=1 SWAP=mix; BLIS 5.0 (amdzen), own OpenMPI 4.1.6 | 0.48 | 1391.3 | tbd (Rpeak for xcni not fixed yet) | PASSED (3.96328737e-03) | correctness run only; many `Read -1, expected 10240, errno = 1` lines from vader CMA (job id not captured) |
