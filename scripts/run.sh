#!/bin/bash
# Runs HPL on an x86 xcn class (xcni) and blocks until done. Output (incl. result table) goes to stdout.
# Tuning knobs are env overrides, e.g.:  NODES=1 HPLDAT=config/test.dat make run
set -euo pipefail
cd "$(dirname "$0")/.."

NODES=${NODES:-4}                       # hard limit: <= 4
RPN=${RPN:-64}                          # MPI ranks per node (xcni: 64 physical cores)
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1}
HPLDAT=${HPLDAT:-config/HPL.dat}
TLIMIT=${TLIMIT:-02:00:00}

mkdir -p logs
cp "$HPLDAT" build/hpl-2.3/bin/soc/HPL.dat
cd build/hpl-2.3/bin/soc
srun -p normal -N "$NODES" -n $((NODES * RPN)) --ntasks-per-node="$RPN" --constraint=xcni \
     --mpi=pmix --cpu-bind=cores --time="$TLIMIT" ./xhpl
