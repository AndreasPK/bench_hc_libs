#!/usr/bin/env bash

#Build 5 variants of GHC in folder $TREE_DIR
#All five builds will run in parallel.
TREE_DIR=~/trees
THREADS="-j2" # Use "-j2" if you have 8+ cores


mkdir -p ${TREE_DIR}

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/head

cd ${TREE_DIR}/head
git checkout fce07c99fa6528e95892604edb73fb975d6a01fc
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O2
GhcStage2HcOpts    = -O2
GhcLibHcOpts       = -O2
GhcRtsHcOpts       = -O2
BUILD_PROF_LIBS    = NO
SplitObjs          = NO
SplitSections      = NO
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure --enable-tarballs-autodownload
make ${THREADS} &

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/vanilla

cd ${TREE_DIR}/vanilla
git remote add vanilla https://github.com/AndreasPK/ghc.git
git fetch vanilla
git checkout vanilla/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O2
GhcStage2HcOpts    = -O2  -fno-new-blocklayout  -fvanilla-blocklayout
GhcLibHcOpts       = -O2  -fno-new-blocklayout  -fvanilla-blocklayout
GhcRtsHcOpts       = -O2  -fno-new-blocklayout  -fvanilla-blocklayout
BUILD_PROF_LIBS    = NO
SplitObjs          = NO
SplitSections      = NO
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure --enable-tarballs-autodownload
make ${THREADS} &

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/adjusted

cd ${TREE_DIR}/adjusted
git remote add adjusted https://github.com/AndreasPK/ghc.git
git fetch adjusted
git checkout adjusted/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O2
GhcStage2HcOpts    = -O2  -fno-new-blocklayout  -fno-vanilla-blocklayout
GhcLibHcOpts       = -O2  -fno-new-blocklayout  -fno-vanilla-blocklayout
GhcRtsHcOpts       = -O2  -fno-new-blocklayout  -fno-vanilla-blocklayout
BUILD_PROF_LIBS    = NO
SplitObjs          = NO
SplitSections      = NO
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure --enable-tarballs-autodownload
make ${THREADS} &

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/allCalls

cd ${TREE_DIR}/allCalls
git remote add allCalls https://github.com/AndreasPK/ghc.git
git fetch allCalls
git checkout allCalls/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O2
GhcStage2HcOpts    = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=310
GhcLibHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=310
GhcRtsHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=310
BUILD_PROF_LIBS    = NO
SplitObjs          = NO
SplitSections      = NO
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure --enable-tarballs-autodownload
make ${THREADS} &

git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/someCalls

cd ${TREE_DIR}/someCalls
git remote add someCalls https://github.com/AndreasPK/ghc.git
git fetch someCalls
git checkout someCalls/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O2
GhcStage2HcOpts    = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=300
GhcLibHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=300
GhcRtsHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=300
BUILD_PROF_LIBS    = NO
SplitObjs          = NO
SplitSections      = NO
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure --enable-tarballs-autodownload
make ${THREADS} &
git clone --recursive git://git.haskell.org/ghc.git ${TREE_DIR}/noCalls

cd ${TREE_DIR}/noCalls
git remote add noCalls https://github.com/AndreasPK/ghc.git
git fetch noCalls
git checkout noCalls/layoutOpt
git submodule update --init --recursive
git clean -fd
echo 'SRC_HC_OPTS        = -O -H64m
GhcStage1HcOpts    = -O2
GhcStage2HcOpts    = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=-3000
GhcLibHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=-3000
GhcRtsHcOpts       = -O2  -fnew-blocklayout     -fvanilla-blocklayout     -fcfg-weights=callWeight=-3000
BUILD_PROF_LIBS    = NO
SplitObjs          = NO
SplitSections      = NO
HADDOCK_DOCS       = NO
BUILD_SPHINX_HTML  = NO
BUILD_SPHINX_PDF   = NO
BUILD_MAN          = NO
' >> mk/build.mk
./boot
./configure --enable-tarballs-autodownload
make ${THREADS} &

wait
echo "Done"
