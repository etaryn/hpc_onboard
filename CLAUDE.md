# Kent Ridge HPC Onboarding — Option 1: HPL Software Benchmarking

Ethan (NUS CS student) is doing the Kent Ridge HPC try-out: get HPL (High-Performance
Linpack) running across the NUS SoC Compute Cluster, then tune it for the best GFLOPS score.
The organizers say the exercise is meant to show "how you think", so Ethan stays in the
loop: explain each decision briefly, and prefer small, explainable steps over big
opaque changes. Don't spend extreme amounts of time on it.

Source docs:
- Onboarding: https://docs.google.com/document/d/e/2PACX-1vQIKF-1OJftiJPLL1n0L4Z6Il3siC-2-KOEwa28XanM9hIdtv662M8uglaENVwhjGY5F-J-afK41K7V/pub
- Option 1 instructions: https://docs.google.com/document/d/e/2PACX-1vQP-1mDVAj_PcOadm9hjczi1shJzdZBL6rlBMDR8nOHR9Ua5keLvzGSVK6yaX6k4TVX8C1WrKlxrTql/pub
- HPL: https://netlib.org/benchmark/hpl/

## HARD constraints (never violate)

1. Run only on the SoC Compute Cluster.
2. CPU only. Use ONLY `xcn*` nodes. NEVER submit to, ssh into, or list in a nodelist any `xgp*` (GPU) node.
3. Max 4 compute nodes per run (the login node doesn't count). Always pass `-N` <= 4 explicitly.
4. Don't hog shared resources: set a `--time` limit on every job, cancel stray jobs
   (`squeue -u $USER`, `scancel`), and never run HPL or heavy builds on the login node.
5. No sudo or system-wide installs. Everything lives under `$HOME` (or the project dir).
6. Never write passwords, tokens, or SSH keys into files, logs, or messages.

## Deliverable contract

The organizers download the archive to a SoC login node, unpack it, and run:

    make        # must build everything needed (HPL + any deps) from a clean checkout
    make run    # must run HPL with our chosen config; its output IS the final score

So:
- `make` must work in a fresh shell with no manual steps (load modules inside the
  Makefile/scripts, not in our ~/.bashrc). Use relative paths only, no hardcoded /home/<user>.
- `make run` must BLOCK until HPL finishes and print the HPL result table
  (use `srun` or `sbatch --wait` + cat the output). Returning just a job ID is a failure.
- Ship the `HPL.dat` actually used.
- Before submitting, test the whole thing by unpacking the archive into a temp dir and running
  `make && make run` from scratch.

Submission (Ethan does this himself): email ccris@comp.nus.edu.sg and srirams@comp.nus.edu.sg
with the code archive (.zip/.tar.gz) + a concise PDF report (how the score was achieved,
what was learned) + a short bio/resume.

## Two-session setup

There are two Claude Code sessions talking to each other:

- **Local session** (Ethan's Windows PC, folder `hpc_onboard`): source of truth for
  the code, Makefile, HPL.dat templates, notes and the report. Plans the work, writes and edits files,
  reviews results, and writes the report. It cannot reach the cluster.
- **Cluster session** (SoC login node): runs everything that touches the cluster:
  `sinfo`, `module`, builds, `srun`/`sbatch`, reading job output. It's the source of truth for
  hardware facts and benchmark results.

Coordination rules:
- Keep code in sync through one channel (preferably a git repo both sides push/pull,
  otherwise scp). Say which commit/version a run used.
- Cluster → local: report the exact command run, the relevant raw output (not a paraphrase),
  and the job ID. For HPL runs, always include N, NB, P, Q, ranks/threads, node list,
  the Time and Gflops line, and whether the residual check PASSED.
- Local → cluster: send exact commands or file diffs, not vague instructions.
- Each session asks Ethan before anything that is expensive or hard to undo
  (a full 4-node run, deleting files, changing the build stack).
- Log every benchmark run in `RESULTS.md` (one row per run, see below). Failed runs too.

## Plan

1. **Survey** (cluster session). Record in `HARDWARE.md`: partitions (`sinfo`), xcn CPU model,
   sockets, cores, threads, clock, ISA (AVX2/AVX-512), memory per node (`lscpu`, `free -g`,
   `numactl -H` via `srun` on an xcn node), interconnect, and the available modules
   (compilers, MPI, MKL/AOCL/OpenBLAS).
2. **Compute Rpeak** = nodes x cores x clock x DP FLOPs per cycle
   (e.g. AVX-512 with 2 FMA units = 32, AVX2 with 2 FMA units = 16). State the assumptions.
3. **Build** hpl-2.3 against an optimized BLAS: MKL on Intel, AOCL-BLIS on AMD, OpenBLAS as a fallback.
   Never use reference BLAS. Pick an MPI library that works with Slurm's `srun`.
4. **Correctness first**: a small 1-node run (small N) passes the residual check.
5. **Scale to 4 nodes**, then tune:
   - N ~ sqrt(0.80 x total_RAM_bytes / 8), rounded down to a multiple of NB. Leave headroom for OS/MPI.
   - NB: sweep ~192–384 (BLAS-dependent).
   - P x Q = total MPI ranks. Keep it near-square with P <= Q.
   - Ranks vs threads: 1 rank/core vs 1 rank/socket (or NUMA domain) + OpenMP threads.
   - Process binding/affinity (`--cpu-bind=cores`, OMP_PROC_BIND / OMP_PLACES).
   - Secondary HPL.dat knobs (PFACT, RFACT, BCAST, DEPTH, swap) only after the above.
   Tune on small/medium N for speed, confirm on the full N. Change one variable at a time.
6. **Package**: Makefile with `make` / `make run`, the final HPL.dat, and the Slurm script. Do a clean-room test.
7. **Report** (local session drafts, Ethan edits): setup, Rpeak, final Rmax and efficiency
   (Rmax/Rpeak), tuning journey with what helped and what didn't, lessons learned. Keep it concise.

## RESULTS.md format

| # | date | commit | nodes | ranks x threads | P x Q | N | NB | other knobs | time (s) | GFLOPS | % Rpeak | PASSED? | notes |

## Conventions

- Project layout (suggested): `Makefile`, `hpl/` (source/build), `config/HPL.dat`,
  `scripts/run_hpl.slurm`, `scripts/build.sh`, `RESULTS.md`, `HARDWARE.md`, `report/`.
- Pin versions (HPL version, module versions) in the build script.
- Keep raw logs from runs under `logs/` (gitignored if large). Quote numbers from logs, never from memory.
