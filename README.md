# HPL on the NUS SoC Compute Cluster

    make        # builds AOCL-BLIS, Open MPI 4.1.6 and HPL 2.3 under ./build (runs on an xcn node via srun)
    make run    # runs HPL on 2 xcni nodes (sbatch --wait), prints the result table; input: config/HPL.dat

Run from a SoC login node. `make` uses the source tarballs in `dist/` (no internet needed); without `dist/` it downloads them.
Two nodes because the cluster's QOS caps a user at 256 CPUs (= 2 full xcni nodes; 128 CPUs each).
`RESULTS.md` lists every benchmark run, `HARDWARE.md` the node survey, `config/tuning/` the sweep inputs.
