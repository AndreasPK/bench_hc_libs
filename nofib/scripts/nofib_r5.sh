#!/usr/bin/env bash


LOGNAME=$1
LOG_DIR=~/logs_r5
TREE_DIR=~/trees_r5
RUNS=5


mkdir -p ${TREE_DIR}

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/head

cd ${TREE_DIR}/head
git checkout 120cc9f8
git submodule update --init --recursive
git clean -fd
./boot
./configure
make &

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/vanilla

cd ${TREE_DIR}/vanilla
git remote add vanilla https://github.com/AndreasPK/ghc.git
git fetch vanilla
git checkout vanilla/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O
GhcStage2HcOpts    = -O2  -fno-new-blocklayout  -fvanilla-blocklayout
GhcLibHcOpts       = -O2  -fno-new-blocklayout  -fvanilla-blocklayout
GhcRtsHcOpts       = -O2  -fno-new-blocklayout  -fvanilla-blocklayout
BUILD_PROF_LIBS    = NO
SplitObjs          = YES
SplitSections      = YES
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure
make &

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/allCalls

cd ${TREE_DIR}/allCalls
git remote add allCalls https://github.com/AndreasPK/ghc.git
git fetch allCalls
git checkout allCalls/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O
GhcStage2HcOpts    = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=310
GhcLibHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=310
GhcRtsHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=310
BUILD_PROF_LIBS    = NO
SplitObjs          = YES
SplitSections      = YES
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure
make &

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/noCalls

cd ${TREE_DIR}/noCalls
git remote add noCalls https://github.com/AndreasPK/ghc.git
git fetch noCalls
git checkout noCalls/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O
GhcStage2HcOpts    = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=-3000
GhcLibHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=-3000
GhcRtsHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=-3000
BUILD_PROF_LIBS    = NO
SplitObjs          = YES
SplitSections      = YES
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure
make -j2 &

wait

if [ -z "$1" ]
then
    echo "error - Usage: <benchName>"
    exit
fi

mkdir -p ${LOG_DIR}
cd ${TREE_DIR}/head/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}base0

make clean && make boot && make EXTRA_HC_OPTS=" -O1" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}base1

make clean && make boot && make EXTRA_HC_OPTS=" -O0" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}base2



#Running patch noCalls in directory ${TREE_DIR}/noCalls/nofib
cd ${TREE_DIR}/noCalls/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\"" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}noCalls0

make clean && make boot && make EXTRA_HC_OPTS=" -O1 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\"" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}noCalls1

make clean && make boot && make EXTRA_HC_OPTS=" -O0 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\"" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}noCalls2



#Running patch allCalls in directory ${TREE_DIR}/allCalls/nofib
cd ${TREE_DIR}/allCalls/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=301,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=300,backEdgeBonus=400\"" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}allCalls0

make clean && make boot && make EXTRA_HC_OPTS=" -O1 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=301,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=300,backEdgeBonus=400\"" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}allCalls1

make clean && make boot && make EXTRA_HC_OPTS=" -O0 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=301,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=300,backEdgeBonus=400\"" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}allCalls2



#Running patch vanilla in directory ${TREE_DIR}/vanilla/nofib
cd ${TREE_DIR}/vanilla/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}vanilla0

make clean && make boot && make EXTRA_HC_OPTS=" -O1" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}vanilla1

make clean && make boot && make EXTRA_HC_OPTS=" -O0" NoFibRuns=${RUNS} 2>&1 | tee ${LOG_DIR}/log${LOGNAME}vanilla2




cd ""

