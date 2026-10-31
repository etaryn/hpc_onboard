#!/bin/bash
# Ranks x threads sweep. Env: NODES (default 1), N (default 46080), NBS (default "384", may list several), CFGS ("rpn threads P Q;..." with P*Q = NODES*rpn).
# Uses config/tuning/grid_sweep.dat as the template. Prints one WR line per config.
cd "$(dirname "$0")/.."
NODES=${NODES:-1}; N=${N:-46080}; NBS=${NBS:-384}; BCASTS=${BCASTS:-1}; DEPTHS=${DEPTHS:-1}   # BCASTS/DEPTHS: lists like NBS
CFGS=${CFGS:-"64 1 4 16;32 2 4 8;16 4 4 4;8 8 2 4"}
IFS=';' read -ra LIST <<<"$CFGS"
for cfg in "${LIST[@]}"; do
  read -r rpn t p q <<<"$cfg"
  f=$(mktemp)
  sed -e "s/^[0-9]* *Ns$/$N            Ns/" -e "s/^4 .*# of process grids.*/1            # of process grids (P x Q)/" \
      -e "s/^1 *# of NBs$/$(wc -w <<<"$NBS")            # of NBs/" -e "s/^384 *NBs$/$NBS            NBs/" \
      -e "s/^1 *# of broadcast$/$(wc -w <<<"$BCASTS")            # of broadcast/" -e "s/^1 *BCASTs .*/$BCASTS            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)/" \
      -e "s/^1 *# of lookahead depth$/$(wc -w <<<"$DEPTHS")            # of lookahead depth/" -e "s/^1 *DEPTHs .*/$DEPTHS            DEPTHs (>=0)/" \
      -e "s/^8 4 16 2 .*Ps/$p            Ps/" -e "s/^8 16 4 32 .*Qs/$q            Qs/" config/tuning/grid_sweep.dat > "$f"
  RPN=$rpn OMP_NUM_THREADS=$t NODES=$NODES HPLDAT=$f bash scripts/run.sh 2>&1 | grep -E "^WR|PASSED|FAILED|rror|nodes:|slurm job" | sed "s/^/[${NODES}n ${rpn}x${t}] /"
  rm -f "$f"
done
