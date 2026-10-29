#!/bin/bash
# Builds AOCL-BLIS (runtime CPU dispatch via the amdzen config) and HPL 2.3 into ./build.
# Runs on an xcn node (see Makefile). Needs internet for the two tarballs.
set -euo pipefail

HPL_VER=2.3
BLIS_VER=5.0          # amd/blis tag; if the tag 404s, check https://github.com/amd/blis/tags

ROOT=$(cd "$(dirname "$0")/.." && pwd)
B=$ROOT/build
mkdir -p "$B" && cd "$B"

# --- BLIS: amdzen = one binary with zen/zen2/zen3/zen4/zen5 kernels chosen at runtime
if [ ! -f blis/lib/libblis-mt.a ]; then
  curl -fsSL -o blis-$BLIS_VER.tar.gz https://github.com/amd/blis/archive/refs/tags/$BLIS_VER.tar.gz
  tar xzf blis-$BLIS_VER.tar.gz
  (cd blis-$BLIS_VER && ./configure -t openmp --enable-cblas --prefix="$B/blis" amdzen && make -j16 && make install)
fi

# --- HPL
if [ ! -d hpl-$HPL_VER ]; then
  curl -fsSL -o hpl-$HPL_VER.tar.gz https://netlib.org/benchmark/hpl/hpl-$HPL_VER.tar.gz
  tar xzf hpl-$HPL_VER.tar.gz
fi
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
CC = mpicc
CCNOOPT = \$(HPL_DEFS)
CCFLAGS = \$(HPL_DEFS) -O3 -fopenmp
LINKER = mpicc
LINKFLAGS = \$(CCFLAGS)
ARCHIVER = ar
ARFLAGS = r
RANLIB = echo
EOF
# HPL's recursive makefiles race under -j, so build it serially
make clean arch=soc >/dev/null 2>&1 || true
make arch=soc
test -x bin/soc/xhpl
