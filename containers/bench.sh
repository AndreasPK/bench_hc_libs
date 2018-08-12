set -x

LOG_DIR=../benchResults
FLAG_NAMES=('vanilla' 'all' 'some' 'none')
FLAG_STRS=('-fno-new-blocklayout -fvanilla-blocklayout' '-fnew-blocklayout -fcfg-weights=callWeight=310' '-fnew-blocklayout -fcfg-weights=callWeight=300' '-fnew-blocklayout -fcfg-weights=callWeight=-900')
mkdir -p "$LOG_DIR"


if [ -z ${1} ]; then
    echo "Please specify a compiler: $0 <HC>"
    #exit
    HC="C:\\ghc\\msys64\\home\\Andi\\ghc_layout\\inplace\\bin\\ghc-stage2.exe"
else
    HC="$1"
fi

if [ ! -d "containers" ]; then
  git clone http://github.com/haskell/containers.git
  sed "s/name: containers/name: containers-bench/" containers/containers.cabal  -i
  sed "s/1.3/1.6/" containers/containers.cabal  -i

fi
#cd aeson
#cabal new-update

if [ ! -d "primitive" ]; then
  git clone https://github.com/haskell/primitive.git
  cd primitive
  git reset --hard a2af610
  cd ..
fi

if [ ! -d "vector-algorithms" ]; then
  curl https://hub.darcs.net/dolio/vector-algorithms/dist --output vector-algorithms.zip
  unzip vector-algorithms.zip
  sed "s/Odph/O2/" -i vector-algorithms/vector-algorithms.cabal
fi

cabal new-update

#Build with different flags

DIR_NAME=${PWD##*/}
COMPILER_NAME=${DIR_NAME#c_}
BENCHMARKS="set-operations-set set-operations-map set-operations-intset set-operations-intmap
            set-benchmarks sequence-benchmarks map-benchmarks lookupge-map lookupge-intmap
            intset-benchmarks intmap-benchmarks"

for benchmark in ${BENCHMARKS};
do

    for i in {0..3};
    do
        HC_FLAGS="${FLAG_STRS[$i]}"
        FLAG_VARIANT="${FLAG_NAMES[$i]}"
        STORE_DIR=~/.store_"${FLAG_VARIANT}"
        BUILD_DIR=d-"$FLAG_VARIANT"
        echo "Benchmark: $benchmark - Flags ${FLAG_VARIANT} - ${HC_FLAGS}"

        cabal --store-dir="$STORE_DIR" new-run --builddir="$BUILD_DIR" -w "$HC" --ghc-options="${HC_FLAGS}" --enable-benchmarks --disable-tests \
            "$benchmark" -- --csv "$LOG_DIR/${COMPILER_NAME}.${FLAG_NAMES[$i]}.${benchmark}.csv"
    done

    #Benchmark against head
    HC_FLAGS=""
    STORE_DIR=~/.store_head
    BUILD_DIR=d-head
    cabal --store-dir="$STORE_DIR" new-run --builddir="$BUILD_DIR" -w "$HOME/trees/head/inplace/bin/ghc-stage2" --enable-benchmarks --disable-tests \
        "$benchmark" -- --csv "$LOG_DIR/${COMPILER_NAME}.${FLAG_NAMES[$i]}.${benchmark}.csv"

done