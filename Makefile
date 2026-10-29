# `make`     builds AOCL-BLIS + HPL 2.3 under ./build (compile runs on an xcn node, not the login node)
# `make run` runs HPL via srun and blocks until the result table is printed
XHPL := build/hpl-2.3/bin/soc/xhpl

all: $(XHPL)

$(XHPL):
	srun -p normal -N 1 -n 1 -c 16 --constraint=xcni --time=00:30:00 bash scripts/build.sh

run: all
	bash scripts/run.sh

clean:
	rm -rf build

.PHONY: all run clean
