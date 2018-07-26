
for compiler in allCalls;
#adjusted  allCalls  head  noCalls  someCalls  vanilla
do
    unameOut="$(uname -s)"
    case $unameOut in
    MINGW*)
        HC="C:\\ghc\\msys64\\home\\Andi\\trees5\\${compiler}\\inplace\\bin\\ghc-stage2.exe" ;;
    *)
        HC=~/trees4/${compiler}/inplace/bin/ghc-stage2 ;;
    esac


    mkdir "aeson_${compiler}" -p
    cp bench.sh "aeson_${compiler}"
    cp cabal.project "aeson_${compiler}"
    cd "aeson_${compiler}"
    bash bench.sh "$HC"
    cd ..
done
