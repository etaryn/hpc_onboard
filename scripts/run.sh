#!/bin/bash
# Runs HPL on an x86 xcn class (xcni), blocks until the job ends, then prints its output.
# Tuning knobs are env overrides, e.g.:  NODES=1 HPLDAT=config/test.dat make run
set -euo pipefail
cd "$(dirname "$0")/.."

NODES=${NODES:-4}                       # hard limit: <= 4
RPN=${RPN:-64}                          # MPI ranks per node (xcni: 64 physical cores; -c = 2 x threads = full cores incl. HT siblings)
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1}
HPLDAT=${HPLDAT:-config/HPL.dat}
TLIMIT=${TLIMIT:-02:00:00}

mkdir -p logs
cp "$HPLDAT" build/hpl-2.3/bin/soc/HPL.dat
echo "submitting HPL job ($NODES node(s) x $RPN ranks, $HPLDAT); waiting for it to finish..." >&2
rc=0
jid=$(sbatch --parsable --wait -p normal -N "$NODES" --ntasks-per-node="$RPN" -c $((2 * OMP_NUM_THREADS)) --mem=0 --constraint=xcni \
      --time="$TLIMIT" -o logs/hpl-%j.out scripts/run_hpl.slurm) || rc=$?
cat "logs/hpl-${jid%%;*}.out"
exit $rc
