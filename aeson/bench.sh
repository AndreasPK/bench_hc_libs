#set -x
if [ -z ${1} ]; then
    echo "Please specify a compiler: $0 <HC>"
    #exit
    HC="C:\\ghc\\msys64\\home\\Andi\\ghc_layout\\inplace\\bin\\ghc-stage2.exe"
else
    HC="$1"
fi

if [[ -z ${2} ]]; then
    echo "Warning: No flags given"
    #HC_FLAGS="-fno-new-blocklayout -fvanilla-blocklayout "
    HC_FLAGS="-fnew-blocklayout "
else
    HC_FLAGS="${2}"
fi
echo "Using flags: $HC_FLAGS"

if [ -z ${3} ]; then
    echo "Warning: bin dir not given"
    BIN_DIR="pbin"
else
    BIN_DIR="$3"
fi
echo "Using bin dir: $BIN_DIR"

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




cabal new-configure all -w "$HC" --allow-newer=base,primitive --ghc-options="$HC_FLAGS" --bindir="$BIN_DIR" --enable-benchmarks
cabal new-build all -j4 --reinstall

cp aeson/benchmarks/json-data . -r

for benchmark in aeson-benchmark-typed aeson-benchmark-micro aeson-benchmark-map aeson-benchmark-json-parse aeson-benchmark-foldable aeson-benchmark-escape aeson-benchmark-dates aeson-benchmark-compare-with-json aeson-benchmark-compare aeson-benchmark-auto-compare aeson-benchmark-aeson-parse aeson-benchmark-aeson-encode;
do
    cabal new-run "$benchmark" -- --csv $benchmark.csv
done

cd