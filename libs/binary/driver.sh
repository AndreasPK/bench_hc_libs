#!/bin/bash

#Execute using ./driver <pathToGhc> [aliasForGhc [BuildFlags [FlagAlias]]]
#If any optional flag is given all flags before that must also be given.

set -x

LOG_DIR=benchResults
mkdir -p "$LOG_DIR"
LOG_DIR="../$LOG_DIR"

BENCHMARKS="get builder generics-bench put"

HC=${1:-ghc}
HC_NAME=${2:-vanilla}
HC_FLAGS=${3:-""}
FLAG_ALIAS=${4:-$HC_NAME}
# HC_NAME=${1:-vanilla}

#We use a compiler and a build name in case we want to benchmark different flags.
#args: compiler-exec compiler-name build-flags log-name bench-name
function runBenchmark() {
    HC="$1"
    HC_NAME="$2"
    HC_FLAGS="$3"
    NAME="$4"
    BENCHMARK="$5"
    STORE_DIR="s_$HC_NAME"
    BUILD_DIR="b_$NAME"

    echo "Benchmark: $NAME"
    cabal --store-dir="$HOME/.${STORE_DIR}" new-run --builddir="$BUILD_DIR" -w "$HC" --ghc-options="${HC_FLAGS}" --enable-benchmarks --disable-tests \
        "$BENCHMARK" -- --csv "$LOG_DIR/${HC_NAME}.${NAME}.${BENCHMARK}.csv" -n1
}


# custom per library, run inside of library repository
function setup_benchmarks() {
    mkdir "build" -p
    cp cabal.project "build"
    cd "build"

    #2019-04-13 Monad fail not patched yet so use fork
    if [ ! -d "binary" ]; then
        git clone https://github.com/kolmodin/binary
    fi
    cp binary/generics-bench.cache.gz .
    sed "s/name:            binary/name: binary-bench/" binary/binary.cabal  -i
    cabal new-update
}

setup_benchmarks

# "/e/ghc_regSpill/inplace/bin/ghc-stage2.exe"
for BENCHMARK in $BENCHMARKS
do
runBenchmark "${HC}" "${HC_NAME}" "${HC_FLAGS}" "${HC_NAME}" "${BENCHMARK}";
done

cd ..

