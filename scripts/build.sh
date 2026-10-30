#!/bin/bash
# Builds AOCL-BLIS (runtime CPU dispatch via the amdzen config) and HPL 2.3 into ./build.
# Runs on an xcn node (see Makefile). Needs internet for the two tarballs.
set -euo pipefail

HPL_VER=2.3
OMPI_VER=4.1.6
BLIS_VER=5.0          # amd/blis tag; if the tag 404s, check https://github.com/amd/blis/tags

ROOT=$(cd "$(dirname "$0")/.." && pwd)
B=$ROOT/build
mkdir -p "$B" && cd "$B"

# --- BLIS: amdzen = one binary with zen/zen2/zen3/zen4/zen5 kernels chosen at runtime
if [ ! -f blis/lib/libblis-mt.a ]; then
  curl -fsSL -o blis-$BLIS_VER.tar.gz https://github.com/amd/blis/archive/refs/tags/$BLIS_VER.tar.gz
  tar xzf blis-$BLIS_VER.tar.gz
  (cd blis-$BLIS_VER && ./configure -t openmp --enable-cblas --prefix="$B/blis" amdzen && make -j32 && make install)
fi

# --- Open MPI: the system one (Debian, PMIx 5) segfaults / loses its daemons on the xcn nodes.
# Bundled PMIx/hwloc/libevent avoid the system libpmix. HPL is rebuilt against it below.
if [ ! -x ompi/bin/mpirun ]; then
  W=$(mktemp -d)                        # compile on the node's local disk; $HOME is a slow network FS
  trap 'rm -rf "$W"' EXIT
  curl -fsSL -o "$W/openmpi.tar.gz" https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-$OMPI_VER.tar.gz
  tar xzf "$W/openmpi.tar.gz" -C "$W"
  (cd "$W/openmpi-$OMPI_VER" && ./configure --prefix="$B/ompi" --with-slurm --with-pmix=internal      --with-hwloc=internal --with-libevent=internal --without-verbs --without-ucx      --disable-mpi-fortran --disable-mpi-cxx && make -j32 && make install)
fi
export PATH="$B/ompi/bin:$PATH"

# --- HPL (always from a fresh tree: no recursive `make clean`, which is slow on the network FS)
rm -rf hpl-$HPL_VER
[ -f hpl-$HPL_VER.tar.gz ] || curl -fsSL -o hpl-$HPL_VER.tar.gz https://netlib.org/benchmark/hpl/hpl-$HPL_VER.tar.gz
tar xzf hpl-$HPL_VER.tar.gz
cd hpl-$HPL_VER
cat > Make.soc <<EOF
SHELL = /bin/sh
CD = cd
CP = cp
LN_S = ln -s
MKDIR = mkdir
RM = /bin/rm -f
TOUCH = touch
ARCH = soc
TOPdir = $B/hpl-$HPL_VER
INCdir = \$(TOPdir)/include
BINdir = \$(TOPdir)/bin/\$(ARCH)
LIBdir = \$(TOPdir)/lib/\$(ARCH)
HPLlib = \$(LIBdir)/libhpl.a
MPdir =
MPinc =
MPlib =
LAdir = $B/blis/lib
LAinc = -I$B/blis/include/blis
LAlib = \$(LAdir)/libblis-mt.a -lm
F2CDEFS =
HPL_OPTS = -DHPL_CALL_CBLAS
HPL_INCLUDES = -I\$(INCdir) -I\$(INCdir)/\$(ARCH) \$(LAinc) \$(MPinc)
HPL_LIBS = \$(HPLlib) \$(LAlib) \$(MPlib)
HPL_DEFS = \$(F2CDEFS) \$(HPL_OPTS) \$(HPL_INCLUDES)
CC = $B/ompi/bin/mpicc
CCNOOPT = \$(HPL_DEFS)
CCFLAGS = \$(HPL_DEFS) -O3 -fopenmp
LINKER = $B/ompi/bin/mpicc
LINKFLAGS = \$(CCFLAGS)
ARCHIVER = ar
ARFLAGS = r
RANLIB = echo
EOF
# HPL's recursive makefiles race under -j, so build it serially
make arch=soc
test -x bin/soc/xhpl
