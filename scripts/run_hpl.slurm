#!/bin/bash
# Submitted by scripts/run.sh with -N/--ntasks-per-node/--constraint/--time on the command line.
B=$SLURM_SUBMIT_DIR/build
export LD_LIBRARY_PATH=$B/ompi/lib:$B/blis/lib:$LD_LIBRARY_PATH
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-1}
cd "$B/hpl-2.3/bin/soc"
echo "nodes: $SLURM_JOB_NODELIST  ranks: $SLURM_NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"
"$B/ompi/bin/mpirun" --mca btl_vader_single_copy_mechanism none -np "$SLURM_NTASKS" --bind-to core --map-by core ./xhpl
