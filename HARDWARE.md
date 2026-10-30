# HARDWARE.md

Survey via `ssh xlogin` (manual relay), 2026-10-30. Raw numbers are from pasted `lscpu`/`sinfo` output.

## Login node (xlogin1) — NOT where HPL runs
- QEMU Virtual CPU 2.5+, 2 sockets x 2 cores, 1 thread/core.
- ISA flags: no `avx` at all (grep for avx/avx2/avx512f/fma printed nothing).
- => `make` on the login node must NOT use `-march=native` or BLAS autodetect.
- Tools: gcc 13.3.0 (Ubuntu 24.04), Open MPI 4.1.6 (`mpicc`/`mpirun`), git 2.43, make. No `module` command.
- Slurm MPI plugins: none, pmi2, pmix (pmix_v5). No system BLAS (only FFTW found in /usr/lib/x86_64-linux-gnu).

## Slurm partitions
- `normal` (default, 3h limit) and `long` (3 days): xcn* nodes only. USE THESE.
- `gpu`, `gpu-long`: xgp* nodes. NEVER USE.
- xcn nodes are heterogeneous by CPUTot/RealMemory: 99x (24 CPU, 63 GB), 30x (128, 1 TB), 20x (128, 256 GB),
  4x (512, 1 TB), 4x (48, 256 GB), 3x (64, 256 GB), 2x (80, 384 GB), 6x (80, 768 GB).
  A 4-node run must be pinned to one identical class.

## xcnd7 (sample of the 24-CPU / 63 GB class)
- Intel Xeon E5-2620 v3 @ 2.40 GHz (Haswell-EP), 2 sockets x 6 cores, 2 threads/core (HT), 24 CPUs.
- ISA: AVX, AVX2, FMA, no AVX-512. Max 2400 MHz, min 1200 MHz.
- Memory: 62 GB total (NUMA0 31.7 GB, NUMA1 32.3 GB); distances 10/21.
- NUMA: node0 = CPUs 0-5,12-17; node1 = CPUs 6-11,18-23 (HT siblings are +12).
- Cache: L2 256 KB/core, L3 15 MB/socket.
- Interconnect: Ethernet only (enp2s0f0/f1 UP), no InfiniBand (/sys/class/infiniband missing). Speed not yet checked.

## Rpeak (xcnd7 class)
Assumptions: 12 physical cores/node (ignore HT), 2.4 GHz nominal, AVX2 with 2 FMA units = 16 DP FLOP/cycle.
- 1 node: 12 x 2.4 x 16 = 460.8 GFLOPS
- 4 nodes: 1843.2 GFLOPS
- Caveat: Haswell-EP runs AVX code below the nominal clock, so real Rpeak is lower; revisit if efficiency looks odd.

## xcn node classes (one sample node each; Slurm feature name = class prefix, e.g. `--constraint=xcni`)
| class | sample | CPU | sockets | RAM | NIC speed (Mb/s) |
|---|---|---|---|---|---|
| xcnc/xcnd | xcnc5 | Xeon E5-2620 v3 (Haswell) | 2 | 62 GB | 1000 (1 GbE) |
| xcne | xcne0 | Xeon Gold 6230 (Cascade Lake) | 2 | 754 GB | 10000 |
| xcnf | xcnf0 | AMD EPYC 7763 (Zen 3) | 2 | 995 GB | 10000 |
| xcng | xcng0 | **Neoverse-N1 (ARM aarch64)** | 1 | 1005 GB | 10000 |
| xcnh | xcnh0 | AMD EPYC 9755 128-core (Zen 5) | 2 | 1002 GB | 10000 |
| xcni | xcni0 | AMD EPYC 9355 32-core (Zen 5) | 2 | 251 GB | 10000 |
| xcnz | xcnz0 | Xeon Silver 4116 (Skylake-SP) | 2 | 251 GB | 10000 |
- xcng is ARM: an x86 binary will not run there. The Slurm job must be pinned to an x86 class.
- (`nproc` printed 2 in the survey only because `srun -n1` limits the cgroup to 1 core + its HT sibling.)

## Software / network
- Cluster has internet (github.com, pypi.org return HTTP 200) => can fetch hpl-2.3 and build OpenBLAS/BLIS under $HOME.
- Open MPI 4.1.6 (Debian), built with Slurm, UCX, libfabric, PMIx (ext3x); btl: self, tcp, vader, openib, ofi.
- /opt/soc has bin, files, models, pe, var (not yet inspected).

## TODO
- Detailed lscpu (clock, ISA flags, NUMA) for the class we choose.
- Decide node class for the final run (availability vs speed).

## Rpeak for xcni (EPYC 9355, the class we run on)
Assumptions: 64 cores/node (2 x 32, ignore HT), 3.55 GHz vendor base clock (NOT readable on the node:
no cpufreq base_frequency; only max boost 4413 MHz is reported), Zen 5 AVX-512 = 32 DP FLOP/cycle/core.
- 1 node: 64 x 3.55 x 32 = 7270.4 GFLOPS
- 4 nodes: 29081.6 GFLOPS
- Real all-core AVX-512 clock may differ; treat % Rpeak as an estimate.
