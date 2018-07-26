#set -x

LOG_DIR=../benchResults
mkdir -p "$LOG_DIR"

if [ -z ${1} ]; then
    echo "Please specify a compiler: $0 <HC>"
    #exit
    HC="C:\\ghc\\msys64\\home\\Andi\\trees5\\vanilla\\inplace\\bin\\ghc-stage2.exe"
else
    HC="$1"
fi

echo "Using flags: $HC_FLAGS"

if [ ! -d "aeson" ]; then
  git clone https://github.com/bos/aeson.git
fi
#cd aeson
#cabal new-update

if [ ! -d "primitive" ]; then
  git clone https://github.com/haskell/primitive.git
  cd primitive
  git reset --hard a2af610
  cd ..
fi

if grep "primitive" cabal.project; then
    echo "cabal.project already updated"
else
    echo "packages: primitive/" >> cabal.project
    echo -e "repository head.hackage\n" \
  "  url: http://head.hackage.haskell.org/\n" \
  "  secure: True\n" \
  "  root-keys: 07c59cb65787dedfaef5bd5f987ceb5f7e5ebf88b904bbd4c5cbdeb2ff71b740\n" \
  "             2e8555dde16ebd8df076f1a8ef13b8f14c66bad8eafefd7d9e37d0ed711821fb\n" \
  "             8f79fd2389ab2967354407ec852cbe73f2e8635793ac446d09461ffb99527f6e\n" \
  "  key-threshold: 3" >> cabal.project
fi

if [ ! -d "json-builder" ]; then
    git clone https://github.com/nikomi/json-builder.git
    cd json-builder
    git reset --hard fef4700
    cd ..
fi


FLAG_NAMES=('vanilla' 'all' 'some' 'none')
FLAG_STRS=('-fno-new-blocklayout -fvanilla-blocklayout' '-fnew-blocklayout -fcfg-weights=callWeight=310' '-fnew-blocklayout -fcfg-weights=callWeight=300' '-fnew-blocklayout -fcfg-weights=callWeight=-900')

cp aeson/benchmarks/json-data . -r

cabal new-update

DIR_NAME=${PWD##*/}
COMPILER_NAME=${DIR_NAME#aeson_}
for i in {0..3};
do
    HC_FLAGS="${FLAG_STRS[$i]}"
    FLAG_VARIANT="${FLAG_NAMES[$i]}"
    STORE_DIR=~/.store_"${FLAG_VARIANT}"
    echo "Flags ${FLAG_VARIANT} - ${HC_FLAGS}"
    cabal --store-dir=$STORE_DIR new-build -w "$HC" --allow-newer=base,primitive --ghc-options=\""${HC_FLAGS}"\" --enable-benchmarks --disable-tests -j5 all

    for benchmark in aeson-benchmark-typed aeson-benchmark-micro aeson-benchmark-map aeson-benchmark-json-parse aeson-benchmark-foldable aeson-benchmark-escape aeson-benchmark-dates aeson-benchmark-compare-with-json aeson-benchmark-compare aeson-benchmark-auto-compare aeson-benchmark-aeson-parse aeson-benchmark-aeson-encode;
    do
        cabal--store-dir=$STORE_DIR new-run -w "$HC" --allow-newer=base,primitive --ghc-options=\""${HC_FLAGS}"\" --enable-benchmarks --disable-tests \
            "$benchmark" -- --csv "$LOG_DIR/${COMPILER_NAME}.${FLAG_NAMES[$i]}.${benchmark}.csv"
    done
done

cd