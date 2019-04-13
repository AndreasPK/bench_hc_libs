#!/bin/bash

#Execute using ./driver <pathToGhc> [aliasForGhc [BuildFlags [FlagAlias]]]
#If any optional flag is given all flags before that must also be given.

set -x

LOG_DIR=benchResults
mkdir -p "$LOG_DIR"
LOG_DIR="../$LOG_DIR"

BENCHMARKS="set-operations-set set-operations-map set-operations-intset set-operations-intmap
            set-benchmarks sequence-benchmarks map-benchmarks lookupge-map lookupge-intmap
            intset-benchmarks intmap-benchmarks"

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
    #Use -L10 since these are pretty noisy
    cabal --store-dir="$HOME/.${STORE_DIR}" new-run --builddir="$BUILD_DIR" -w "$HC" --ghc-options="${HC_FLAGS}" --enable-benchmarks --disable-tests \
        "$BENCHMARK" -- --csv "$LOG_DIR/${HC_NAME}.${NAME}.${BENCHMARK}.csv" -L10
}


# custom per library, run inside of library repository
function setup_benchmarks() {
    mkdir "build" -p
    cp cabal.project "build"
    cd "build"

    if [ ! -d "containers" ]; then
        git clone http://github.com/haskell/containers.git
    fi
    cabal new-update
}

setup_benchmarks

# "/e/ghc_regSpill/inplace/bin/ghc-stage2.exe"
for BENCHMARK in $BENCHMARKS
do
runBenchmark "${HC}" "${HC_NAME}" "${HC_FLAGS}" "${HC_NAME}" "${BENCHMARK}";
done

cd ..

