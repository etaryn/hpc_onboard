#!/bin/bash
# Submitted by scripts/run.sh with -N/--ntasks-per-node/--constraint/--time on the command line.
B=$SLURM_SUBMIT_DIR/build
export LD_LIBRARY_PATH=$B/ompi/lib:$B/blis/lib:$LD_LIBRARY_PATH
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-4}
cd "$B/hpl-2.3/bin/soc"
echo "nodes: $SLURM_JOB_NODELIST  ranks: $SLURM_NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"
export OMP_PLACES=cores OMP_PROC_BIND=close
"$B/ompi/bin/mpirun" --mca btl_vader_single_copy_mechanism none -x OMP_NUM_THREADS -x OMP_PLACES -x OMP_PROC_BIND -x BLIS_ARCH_DEBUG -np "$SLURM_NTASKS" --map-by slot:PE=$OMP_NUM_THREADS --bind-to core ./xhpl
