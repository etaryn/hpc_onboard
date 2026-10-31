# NOTES.md — project state and handoff (read CLAUDE.md first, then this)

Last updated 2026-10-30. Everything here was verified in-session unless marked UNVERIFIED. Numbers: see RESULTS.md (from logs).

## 1. Status
Build pipeline works end to end on the cluster: `make` builds BLIS 5.0 + Open MPI 4.1.6 + HPL 2.3 into `build/`; `make run` submits via
`sbatch --wait`, blocks, prints the HPL table. 16 single-node runs (xcni) all PASSED. Best 1-node: **3702.8 GFLOPS (50.9% of an
assumed 7270.4 Rpeak)** with 16 ranks x 4 threads, 4x4 grid, NB=384, N=46080. **No 4-node run has been done yet.** Defaults in
`scripts/run.sh` and `config/HPL.dat` (N=92160, NB=384, 8x8) are a PROVISIONAL 4-node guess and have not been run since the cleanup.

## 2. How to reach the cluster — CLAUDE.md's "ssh soc, key auth, no prompts" is WRONG for this setup
- The only route is `ssh xlogin` (alias in `~/.ssh/config`, via jump host `stujump`). `stujump` requires key AND password on every login
  ("publickey partial success", then password). Connection multiplexing dies on Windows OpenSSH. `skeys` is unreachable.
- => **Manual relay.** I (Claude) cannot run anything on the cluster. Do NOT try `ssh` from the Bash tool: it hangs or fails.
  Ethan keeps an `ssh xlogin` window open, pastes my command blocks there, and pastes the output back.
- Never ask for or store passwords. Code sync: edit locally -> commit -> `git push origin main` -> Ethan runs `cd ~/hpc_onboard && git pull -q`.
  Repo on the cluster: `~/hpc_onboard` (cloned from the public GitHub repo etaryn/hpc_onboard).
- Relay etiquette: ONE paste-able block per round; start it with `git pull -q && git log --oneline -1` so the commit is recorded; filter
  output with grep (`grep -h -E "^WR|PASSED|FAILED"`) instead of asking for whole logs; ask for the first error block, not the tail.
  Raw job output is in `logs/hpl-<jobid>.out` on the cluster (gitignored). `run.sh` prints `slurm job id: N` before the output.

## 3. Cluster facts that matter (details in HARDWARE.md)
- Target class `xcni`: 2x EPYC 9355, 64 cores / 128 threads, 250 GB, 10 GbE, ~20 nodes. Login nodes are no-AVX QEMU: build on an xcn node.
- `xcng` is ARM: always pin jobs with `--constraint=xcni` (never plain `-N 4`). Max 4 nodes, always `-N` explicit, always `--time`.
- Slurm: `--exclusive` refused; default 3072 MB/CPU, so whole-node requests need `--mem=0`; each rank needs `-c 2*threads` (whole cores,
  HT siblings included) or Open MPI's core binding fails. Partition `normal` max 3 h.

## 4. Gotchas already paid for (do not re-learn)
0. **QOS `normal` caps each user at cpu=256 running** (`sacctmgr show qos`), i.e. 2 full xcni nodes (128 CPUs each, we must request whole cores incl. HT
   siblings). A 4-node job pends forever with `QOSMaxCpuPerUserLimit`. So the final config is **2 nodes**, not 4 (found 2026-10-31). Always check
   `squeue -u $USER` for strays; one job at a time. 4 nodes x half the cores buys no compute and adds network cost: not worth it.
1. **System Open MPI is broken** here (PMIx 5 segfault under `srun --mpi=pmix`; ORTE session_dir errors; mpirun daemon loss). We build
   Open MPI 4.1.6 with bundled pmix/hwloc/libevent into `build/ompi` and launch with its own `mpirun` inside `sbatch`.
2. `btl_vader_single_copy_mechanism none`: CMA is blocked (`Read -1, expected N, errno = 1` spam otherwise).
3. HPL's recursive makefiles race under `make -j`: build HPL serially. Don't run `make clean` on the NFS home (hung >5 min);
   `build.sh` re-extracts HPL into a fresh dir instead.
4. Compile Open MPI on node-local `/tmp` (NFS home is too slow; the first attempts hit the time limit). BLIS builds fine on NFS.
5. `make` considers an existing `build/hpl-2.3/bin/soc/xhpl` up to date: delete it (or `make clean`) to force a rebuild.
6. The local PC has no `make` and no cluster access; I can only syntax-check (`bash -n`). Python is available. Files must stay LF (`.gitattributes`).
7. BLIS selects `zen5` (BLIS_ARCH_DEBUG=1 printed "Selecting sub-configuration 'zen5', model 'Turin'").
8. 1-node results are noisy by ~1.5% run to run (same config scored 3173 and 3126): don't chase differences smaller than that.
9. When writing files from the shell on Windows, long heredocs with mixed quotes can fail to parse: use the Write tool for new files.

## 5. Results so far (1 node, xcni, N=46080 unless stated; GFLOPS)
- NB sweep (64x1, 8x8): 192:2358, 256:2684, 320:3009, **384:3173**, 512:2774.
- Grid (64 ranks, NB=384): 8x8:3126, **4x16:3274**, 16x4:2399, 2x32:2921.
- Ranks x threads (NB=384): 64x1:3282, 32x2:3476, **16x4:3703**, 8x8:3340, 2x32:2241.
- N=80000, NB=256, 64x1, 8x8: 2975 (the only large-N point so far).
- Not yet tried: secondary HPL.dat knobs (PFACT/RFACT/NBMIN/NDIV/BCAST/DEPTH/SWAP/L1/U/equilibration), OMP_PROC_BIND=spread,
  BLIS thread partitioning env (BLIS_JC_NT/IC_NT/JR_NT), NB 448, odd layouts (e.g. 12 ranks x 5 threads), xcnh.

## 6. Open decisions / UNVERIFIED assumptions
- Rpeak: the 3.55 GHz base clock is from memory of the vendor spec, NOT readable on the node; 32 FLOP/cycle assumes full-rate AVX-512 on
  Zen 5. Say "assumed" in the report; optionally also report % of a boost-clock Rpeak.
- `make` downloads 3 tarballs at build time (github.com, download.open-mpi.org, netlib.org). If the organizers' login node lacks internet it
  fails. Option: ship the tarballs in the submission archive (`*.tar.gz` is gitignored; add them to the archive only) and make `build.sh`
  use them when present. Decide before packaging.
- Fresh-clone `make` wall time is UNMEASURED (BLIS + Open MPI + HPL; the 60 min srun limit in the Makefile may or may not suffice).
- `config/HPL.dat` N is provisional. Whether the final run sits on xcni (20 nodes, reliable) or xcnh (4 nodes, probably faster, queue risk)
  is Ethan's call; recommend xcni unless time allows a 1-node xcnh comparison.
- Stale cluster state to clean (ask Ethan first): `~/hpc_onboard/build/openmpi-4.1.6/` and `build/openmpi-4.1.6.tar.gz` from the failed first
  attempt, `/tmp/build*.log` on the login nodes, `config/n80k.dat` (cluster-only file). Check `squeue -u $USER` is empty.

## 7. Plan for the next phase (steps in bold need Ethan's OK; every run gets rows in RESULTS.md)
A. Sanity after the cleanup (1 node, ~1 min): pull, then `NODES=1 HPLDAT=config/tuning/test.dat make run | tail -30`. Expect PASSED with
   the new 16x4 defaults and a `slurm job id:` line. Confirms the cleanup did not break the pipeline.
B. **First 2-node run** (replaces the 4-node plan, see gotcha 0; ~1-2 min per config): `NODES=2 N=65280 CFGS="16 4 4 8;16 4 2 16;8 8 4 4" bash scripts/rt_sweep.sh`.
   Ideal = 2 x 3.7 = 7.4 TFLOPS; Rpeak(2 nodes) = 14540.8 (assumed).
   Expect roughly 10-13 TFLOPS if scaling is decent (ideal 4 x 3.7 = 14.8). If communication-bound, check the 10 GbE interface name
   (`ip -br link`) and try `--mca btl_tcp_if_include <iface>`; fewer, fatter ranks also help.
C. 4-node tuning at N=92160, one variable at a time: best ranks x threads / grid from B, then NB {320,384,448}, then secondary knobs in this
   order: BCAST {1rM,2rM,Lng}, DEPTH {0,1,2}, PFACT/RFACT {C,R,L}, NBMIN/NDIV, SWAP {long,mix}, L1/U, OMP_PROC_BIND close vs spread, BLIS_*_NT.
   Several values of one knob fit in a single HPL.dat (HPL loops over them), so one job per knob. Stop when gains are below the noise
   (~1.5%): CLAUDE.md says not to spend extreme time.
D. **Full-size run (2 nodes).** N = floor(sqrt(0.80 x 2 x 250 GiB / 8) / NB) x NB = **231,552** for NB=384 (Slurm reports 250G per node; 80% of RAM).
   Estimated 25-35 min, so keep `TLIMIT=02:00:00`. Try 0.85 x RAM only if 0.80 runs clean. Update `config/HPL.dat`, log the run.
E. Package: final `config/HPL.dat` and the `run.sh` defaults must match the best run. **Clean-room test** on the cluster: `git archive`
   (or the chosen archive, tarballs included) -> unpack in a new temp dir -> `make && make run` in a fresh shell; record the `make` wall
   time; confirm `make run` blocks, prints the table, and no path is hardcoded. Ask before deleting the temp dir afterwards.
F. Report (2-3 page PDF; I draft it with the pdf skill, Ethan edits): setup, Rpeak assumptions, final Rmax and efficiency, the tuning journey
   (tables from section 5), lessons (broken system MPI/PMIx -> own Open MPI; hybrid MPI+OpenMP beat flat MPI by ~13%; wide grids beat tall;
   NB sweet spot 384; cluster policies). Ethan supplies the bio/resume and sends the email himself.

## 8. Operating rules for me (Claude) in this repo
- Hard constraints in CLAUDE.md always win: xcn only, <=4 nodes, `--time` on every job, nothing heavy on the login node, no passwords.
- Explain each step briefly; small reversible steps; one variable at a time; quote numbers from pasted logs, never from memory.
- Ask before: any 4-node run, the full-N run, deleting anything on the cluster, changing the build stack. `git push origin main` of this repo
  is the agreed sync channel; do not commit or push Ethan's own CLAUDE.md edits unless he asks.
- Scripted local edits: Bash tool (Git Bash) with python/sed, `bash -n` every script before pushing, keep LF endings.
- After every result Ethan pastes: append rows to RESULTS.md (commit hash, job id, raw numbers), commit, push, then give the next block.
