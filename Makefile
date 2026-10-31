# `make`     builds BLIS + Open MPI + HPL 2.3 under ./build (via srun on an xcn node, not the login node)
# `make run` submits scripts/run_hpl.slurm with `sbatch --wait` and prints the HPL result table
XHPL := build/hpl-2.3/bin/soc/xhpl

all: $(XHPL)

$(XHPL):
	srun -p normal -N 1 -n 1 -c 32 --constraint=xcni --time=01:00:00 bash scripts/build.sh

run: all
	bash scripts/run.sh

clean:
	rm -rf build

# Submission archive: sources + the 3 upstream tarballs (dist/), so `make` needs no internet. Run on the cluster.
archive:
	bash scripts/build.sh fetch
	tar czf hpl-submission.tar.gz --transform 's,^,hpl_onboard/,' Makefile README.md HARDWARE.md RESULTS.md config scripts dist

.PHONY: all run clean archive
