
for compiler in adjusted  allCalls  head  noCalls  someCalls  vanilla
do
    case $compiler in
    head)
        HC_FLAGS="-v0"
        ;;
    vanilla)
        HC_FLAGS="-fno-new-blocklayout -fvanilla-blocklayout"
        ;;
    adjusted)
        HC_FLAGS="-fno-new-blocklayout -fno-vanilla-blocklayout"
        ;;
    allCalls)
        HC_FLAGS="-fnew-blocklayout -fcfg-weights=callWeight=305"
        ;;
    someCalls)
        HC_FLAGS="-fnew-blocklayout -fcfg-weights=callWeight=300"
        ;;
    noCalls)
        HC_FLAGS="-fnew-blocklayout -fcfg-weights=callWeight=-900"
        ;;
    esac

    unameOut="$(uname -s)"
    case $unameOut in
    MINGW*)
        HC="C:\\ghc\\msys64\\home\\Andi\\trees5\\${compiler}\\inplace\\bin\\ghc-stage2.exe" ;;
    *)
        HC=~/trees4/${compiler}/inplace/bin/ghc-stage2 ;;
    esac


    mkdir "aeson_${compiler}"
    cp bench.sh "aeson_${compiler}"
    cp cabal.project "aeson_${compiler}"
    cd "aeson_${compiler}"
    bash bench.sh "$HC" "$HC_FLAGS"
    cd ..
done
