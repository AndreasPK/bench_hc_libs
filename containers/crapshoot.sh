#set -x

PREFIX="./c_allCalls/d-all/build/x86_64-windows/ghc-8.7.20180718/containers-bench-0.6.0.1/b/"
PREFIX="./c_allCalls/d-none/build/x86_64-windows/ghc-8.7.20180718/containers-bench-0.6.0.1/b/"
PREFIX="./c_allCalls/d-vanilla/build/x86_64-windows/ghc-8.7.20180718/containers-bench-0.6.0.1/b/"

for f in ${PREFIX}intmap-benchmarks/build/intmap-benchmarks/intmap-benchmarks.exe \
${PREFIX}intset-benchmarks/build/intset-benchmarks/intset-benchmarks.exe \
${PREFIX}lookupge-intmap/build/lookupge-intmap/lookupge-intmap.exe \
${PREFIX}lookupge-map/build/lookupge-map/lookupge-map.exe \
${PREFIX}map-benchmarks/build/map-benchmarks/map-benchmarks.exe \
${PREFIX}sequence-benchmarks/build/sequence-benchmarks/sequence-benchmarks.exe \
${PREFIX}set-benchmarks/build/set-benchmarks/set-benchmarks.exe \
${PREFIX}set-operations-intmap/build/set-operations-intmap/set-operations-intmap.exe \
${PREFIX}set-operations-intset/build/set-operations-intset/set-operations-intset.exe \
${PREFIX}set-operations-map/build/set-operations-map/set-operations-map.exe \
${PREFIX}set-operations-set/build/set-operations-set/set-operations-set.exe ;
do
	$f -n 30 ;
done


