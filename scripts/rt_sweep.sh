#!/bin/bash
# 1-node ranks x threads sweep (uses config/grid_sweep.dat as the template). Prints one WR line per config.
cd "$(dirname "$0")/.."
for cfg in "64 1 4 16" "32 2 4 8" "16 4 4 4" "8 8 2 4" "2 32 1 2"; do
  read -r rpn t p q <<<"$cfg"
  f=$(mktemp)
  sed -e "s/^4 .*# of process grids.*/1            # of process grids (P x Q)/" \
      -e "s/^8 4 16 2 .*Ps/$p            Ps/" -e "s/^8 16 4 32 .*Qs/$q            Qs/" config/grid_sweep.dat > "$f"
  RPN=$rpn OMP_NUM_THREADS=$t NODES=1 HPLDAT=$f bash scripts/run.sh 2>&1 | grep -E "^WR|PASSED|FAILED|rror" | sed "s/^/[${rpn}x${t}] /"
  rm -f "$f"
done
