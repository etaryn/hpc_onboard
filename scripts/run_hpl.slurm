#!/bin/bash
# Submitted by scripts/run.sh with -N/--ntasks-per-node/--constraint/--time on the command line.
B=$SLURM_SUBMIT_DIR/build
export LD_LIBRARY_PATH=$B/ompi/lib:$B/blis/lib:$LD_LIBRARY_PATH
export OMP_NUM_THREADS=${OMP_NUM_THREADS:-4}
cd "$B/hpl-2.3/bin/soc"
echo "nodes: $SLURM_JOB_NODELIST  ranks: $SLURM_NTASKS  OMP_NUM_THREADS=$OMP_NUM_THREADS"
export OMP_PLACES=cores OMP_PROC_BIND=close
# Nodes have 2 NICs; the 192.168.58.x port is not routable between nodes and Open MPI hangs trying it. CIDR (not an iface name) so it holds on any node.
"$B/ompi/bin/mpirun" --mca btl_vader_single_copy_mechanism none --mca btl_tcp_if_include 192.168.48.0/21 --mca oob_tcp_if_include 192.168.48.0/21 -x OMP_NUM_THREADS -x OMP_PLACES -x OMP_PROC_BIND -x BLIS_ARCH_DEBUG -np "$SLURM_NTASKS" --map-by slot:PE=$OMP_NUM_THREADS --bind-to core ./xhpl
