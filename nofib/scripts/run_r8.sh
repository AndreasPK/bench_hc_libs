#!/usr/bin/env bash


LOGNAME=$1
LOG_DIR=~/logs
TREE_DIR=~/trees
RUNS=5

if [ -z "$1" ]
then
    echo "error - Usage: <benchName>"
    exit
fi
mkdir -p ${LOG_DIR}
cd ${TREE_DIR}/head/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}base0

make clean && make boot && make EXTRA_HC_OPTS=" -O1" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}base1

make clean && make boot && make EXTRA_HC_OPTS=" -O0" NoFibRuns=0 -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}base2



#Running patch noCalls in directory ${TREE_DIR}/noCalls/nofib
cd ${TREE_DIR}/noCalls/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\"" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}noCalls0

make clean && make boot && make EXTRA_HC_OPTS=" -O1 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\"" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}noCalls1

make clean && make boot && make EXTRA_HC_OPTS=" -O0 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\"" NoFibRuns=0 -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}noCalls2



#Running patch allCalls in directory ${TREE_DIR}/allCalls/nofib
cd ${TREE_DIR}/allCalls/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=301,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=300,backEdgeBonus=400\"" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}allCalls0

make clean && make boot && make EXTRA_HC_OPTS=" -O1 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=301,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=300,backEdgeBonus=400\"" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}allCalls1

make clean && make boot && make EXTRA_HC_OPTS=" -O0 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=301,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=300,backEdgeBonus=400\"" NoFibRuns=0 -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}allCalls2



#Running patch adjusted in directory ${TREE_DIR}/adjusted/nofib
cd ${TREE_DIR}/adjusted/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\" -fno-new-blocklayout -fno-vanilla-blocklayout" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}adjusted0

make clean && make boot && make EXTRA_HC_OPTS=" -O1 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\" -fno-new-blocklayout -fno-vanilla-blocklayout" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}adjusted1

make clean && make boot && make EXTRA_HC_OPTS=" -O0 -fcfg-weights=\"uncondWeight=1000,condBranchWeight=800,callWeight=-1,likelyCondWeight=900,unlikelyCondWeight=300,infoTablePenalty=3000,backEdgeBonus=400\" -fno-new-blocklayout -fno-vanilla-blocklayout" NoFibRuns=0 -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}adjusted2



#Running patch vanilla in directory ${TREE_DIR}/vanilla/nofib
cd ${TREE_DIR}/vanilla/nofib
make clean && make boot && make EXTRA_HC_OPTS=" -O2 -fno-new-blocklayout -fvanilla-blocklayout" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}vanilla0

make clean && make boot && make EXTRA_HC_OPTS=" -O1 -fno-new-blocklayout -fvanilla-blocklayout" NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}vanilla1

make clean && make boot && make EXTRA_HC_OPTS=" -O0 -fno-new-blocklayout -fvanilla-blocklayout" NoFibRuns=0 -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}vanilla2




cd ""

