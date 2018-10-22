set -x


for compiler in allCalls noCalls;
#for compiler in adjusted  allCalls  head  noCalls  someCalls  vanilla
do
    unameOut="$(uname -s)"
    case $unameOut in
    MINGW*)
        HC="C:\\ghc\\msys64\\home\\Andi\\trees\\${compiler}\\inplace\\bin\\ghc-stage2.exe";
        HC_HEAD="C:\\ghc\\msys64\\home\\Andi\\trees\\head\\inplace\\bin\\ghc-stage2.exe";
        ;;
    *)
        HC=~/trees/${compiler}/inplace/bin/ghc-stage2 ;
        HC_HEAD=~/trees/head/inplace/bin/ghc-stage2 ;;
    esac

    mkdir "c_${compiler}" -p
    cp bench.sh "c_${compiler}"
    cp cabal.project "c_${compiler}"
    cp in.xml "c_${compiler}"/
    cd "c_${compiler}"


        LOG_DIR=../benchResults
        FLAG_NAMES=('vanilla' 'all' 'some' 'none' 'adjusted')
        FLAG_STRS=('-fno-new-blocklayout -fvanilla-blocklayout' '-fnew-blocklayout -fcfg-weights=callWeight=310' '-fnew-blocklayout -fcfg-weights=callWeight=300' '-fnew-blocklayout -fcfg-weights=callWeight=-900' '-fno-new-blocklayout -fno-vanilla-blocklayout')
        NFLAGS=$((${#FLAG_NAMES[@]} - 1))
        mkdir -p "$LOG_DIR"

        if [ ! -d "xml" ]; then
        git clone https://github.com/haskell-perf/xml.git
        fi

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
        BENCHMARKS="time"
        for i in $(seq 0 $NFLAGS);
        do
            HC_FLAGS="${FLAG_STRS[$i]}"
            FLAG_VARIANT="${FLAG_NAMES[$i]}"
            STORE_DIR=~/.store_"${FLAG_VARIANT}"
            BUILD_DIR=d-"$FLAG_VARIANT"
            echo "Configuration ${FLAG_NAMES[$i]} - ${HC_FLAGS}"
            cabal --store-dir="$STORE_DIR" new-build --builddir="$BUILD_DIR" -w "$HC" --ghc-options="${HC_FLAGS}" --enable-benchmarks --disable-tests -j5 all

            for benchmark in ${BENCHMARKS}
            do
                echo "Benchmark: $benchmark"
                #Use -L15 since these are pretty noisy
                cabal --store-dir="$STORE_DIR" new-run --builddir="$BUILD_DIR" -w "$HC" --ghc-options="${HC_FLAGS}" --enable-benchmarks --disable-tests \
                    "$benchmark" -- --csv "$LOG_DIR/${COMPILER_NAME}.${FLAG_NAMES[$i]}.${benchmark}.csv" -L15
            done
        done

        HC_FLAGS=""
        FLAG_VARIANT="head"
        STORE_DIR=~/.store_"${FLAG_VARIANT}"
        BUILD_DIR=d-"$FLAG_VARIANT"
        HC="$HC_HEAD"
        cabal --store-dir="$STORE_DIR" new-build --builddir="$BUILD_DIR" -w "$HC" --ghc-options="${HC_FLAGS}" --enable-benchmarks --disable-tests -j5 all
        for benchmark in ${BENCHMARKS};
        do
            echo "Benchmark: $benchmark"
            cabal --store-dir="$STORE_DIR" new-run --builddir="$BUILD_DIR" -w "$HC" --ghc-options="${HC_FLAGS}" --enable-benchmarks --disable-tests \
               "$benchmark" -- --csv "$LOG_DIR/${COMPILER_NAME}.${FLAG_VARIANT}.${benchmark}.csv" -L15
        done



    cd ..
done
