# HARDWARE.md

Survey done via `ssh xlogin` (manual relay), 2026-10-29/30. Numbers come from pasted `lscpu`, `sinfo`, `scontrol` output.

## Login nodes (xlogin1, xlogin2) — build/submit only, never run HPL here
- QEMU Virtual CPU 2.5+ (2 sockets x 2 cores): **no AVX at all**. => never `-march=native` / BLAS autodetect on the login node.
- Ubuntu 24.04, gcc 13.3, git 2.43, make. No `module` command. Home `/home/b/bing2812` is a network FS (slow for many small files).
- System Open MPI 4.1.6 (Debian) is unusable on the xcn nodes (see NOTES.md); we build our own.

## Slurm
- Partitions `normal` (default, 3 h limit) and `long` (3 days) contain only xcn* nodes: USE THESE. `gpu`, `gpu-long` = xgp*: NEVER.
- `--exclusive` is refused ("Exclusive node access is not permitted"). Default memory is 3072 MB/CPU, so a 128-CPU request
  needs `--mem=0` (node has ~250 GB). `sbatch --wait` works. `srun --mpi=pmix` with the Debian Open MPI segfaults.
- Node class = Slurm feature = hostname prefix (`--constraint=xcni`).

## xcn node classes (one sample node each)
| class | sample | CPU | sockets | RAM | NIC (Mb/s) | notes |
|---|---|---|---|---|---|---|
| xcnc/xcnd | xcnc5, xcnd7 | Xeon E5-2620 v3 (Haswell), 12 cores, 2.4 GHz, AVX2 | 2 | 62 GB | 1000 | slow, 1 GbE |
| xcne | xcne0 | Xeon Gold 6230 (Cascade Lake) | 2 | 754 GB | 10000 | 8 nodes |
| xcnf | xcnf0 | AMD EPYC 7763 (Zen 3), AVX2 | 1 | 995 GB | 10000 | |
| xcng | xcng0 | **Neoverse-N1 (ARM aarch64)** | 1 | 1005 GB | 10000 | x86 binary will not run |
| xcnh | xcnh0 | AMD EPYC 9755 128-core (Zen 5), 512 threads | 2 | ~1 TB | 10000 | only 4 nodes (xcnh0-3); xcnh0 not in `long` |
| **xcni** | xcni0 | **AMD EPYC 9355 32-core (Zen 5)** | 2 | 251 GB (Slurm: 250G) | 10000 | ~20 nodes; **our target class** |
| xcnz | xcnz0 | Xeon Silver 4116 (Skylake-SP), 24 cores | 2 | 251 GB | 10000 | |

## xcni (chosen class)
- EPYC 9355: 2 sockets x 32 cores, 2 threads/core = 128 CPUs, 2 NUMA nodes (~128 GB each), L3 512 MiB total (16 instances).
- ISA: AVX2, AVX-512 (incl. bf16), FMA. Max boost 4413 MHz; the node exposes NO base frequency (acpi-cpufreq, no `base_frequency`).
- Network: 10 GbE (two ports). No InfiniBand. Inter-node MPI = TCP.
- Chosen over xcnh because xcnh has only 4 nodes (any other user's job on one = our `make run` queues) and over older classes for speed.
  xcnh would likely score higher in absolute terms; revisit only if time allows (see NOTES.md).

## Rpeak (xcni) — ASSUMPTIONS, not measured
- 64 cores/node (HT ignored) x 3.55 GHz (vendor base clock, from memory of the spec, UNVERIFIED) x 32 DP FLOP/cycle (Zen 5, AVX-512, 2 FMA) 
- 1 node = 7270.4 GFLOPS; 4 nodes = 29081.6 GFLOPS.
- The sustained all-core AVX-512 clock may differ, so "% Rpeak" is an estimate. State this in the report.
