{-
Utility to get the cross product of various GHC settings on nofib runs.
-}

module Main
where

import qualified Types as T
import Config as C
import BuildScript
import Data.Text.Prettyprint.Doc (vcat)

ignoreCalls =
    "-fcfg-weights=\\\"" ++
    "uncondWeight=1000," ++
    "condBranchWeight=800," ++
    --"switchWeight=0," ++
    "callWeight=-1," ++
    "likelyCondWeight=900," ++
    "unlikelyCondWeight=300," ++
    "infoTablePenalty=3000," ++
    "backEdgeBonus=400\\\""

ignoreSomeCalls =
    "-fcfg-weights=\\\"" ++
    "uncondWeight=1000," ++
    "condBranchWeight=800," ++
    --"switchWeight=0," ++
    "callWeight=300," ++
    "likelyCondWeight=900," ++
    "unlikelyCondWeight=300," ++
    "infoTablePenalty=300," ++
    "backEdgeBonus=400\\\""

considerAllCalls =
    "-fcfg-weights=\\\"" ++
    "uncondWeight=1000," ++
    "condBranchWeight=800," ++
    --"switchWeight=0," ++
    "callWeight=301," ++
    "likelyCondWeight=900," ++
    "unlikelyCondWeight=300," ++
    "infoTablePenalty=300," ++
    "backEdgeBonus=400\\\""


patchBuildConfig :: Either Bool Int -> String
patchBuildConfig conf =
    "SRC_HC_OPTS        = -O -H64m\n" ++
    "GhcStage1HcOpts    = -O2\n" ++
    "GhcStage2HcOpts    = -O2 " ++ newSetting ++ vanilla ++ weight ++ "\n" ++
    "GhcLibHcOpts       = -O2 "++ newSetting ++ vanilla ++ weight ++ "\n" ++
    "GhcRtsHcOpts       = -O2 "++ newSetting ++ vanilla ++ weight ++ "\n" ++
    "BUILD_PROF_LIBS    = NO\n" ++
    "SplitObjs          = YES\n" ++
    "SplitSections      = YES\n" ++
    "HADDOCK_DOCS       = NO\n" ++
    "BUILD_SPHINX_HTML  = NO\n" ++
    "BUILD_SPHINX_PDF   = NO\n" ++
    "BUILD_MAN          = NO\n"
  where
    newSetting
        | Right _ <- conf   = " -fnew-blocklayout    "
        | otherwise         = " -fno-new-blocklayout "
    vanilla
        | Left True <- conf
                    = " -fno-vanilla-blocklayout "
        | otherwise = " -fvanilla-blocklayout    "
    weight
        | Right callWeight <- conf
        = " -fcfg-weights=callWeight=" ++ show callWeight ++ " "
        | otherwise = " "


config :: T.ConfState
config = buildConfig $ do
    treeDir "~/trees"
    logDir "~/logs"
    headDir "head"
    baseCommit "565ef4cc"

    let noCalls = patch "noCalls"
    let someCalls = patch "someCalls"
    let allCalls = patch "allCalls"
    let adjusted = patch "adjusted"
    let vanilla = patch "vanilla"

    let githubLayout = fromGithub "https://github.com/AndreasPK/ghc.git" "layoutOpt"


    patchList [
        noCalls,
        --someCalls,
        allCalls,
        adjusted,
        vanilla
        ]

    addBuild $ buildInfo noCalls githubLayout (patchBuildConfig $ Right (-3000))
    -- addBuild $ buildInfo someCalls githubLayout (patchBuildConfig $ Right (300))
    addBuild $ buildInfo allCalls githubLayout (patchBuildConfig $ Right (310))
    addBuild $ buildInfo adjusted githubLayout (patchBuildConfig $ Left True)
    addBuild $ buildInfo vanilla githubLayout (patchBuildConfig $ Left False)

    mapM_ forAll
      [ switch ["-O2", "-O1", "-O0"]
      --, toggle $ "-fproc-alignment=64"
      ]

    -- mapM_ forPatches
    --   [ switch
    --     [ "-fnew-blocklayout -fcfg-weights=callWeight=300"
    --     , "-fnew-blocklayout -fcfg-weights=callWeight=-900"
    --     , "-fnew-blocklayout -fcfg-weights=callWeight=301"
    --     --, "-fno-new-blocklayout -fno-vanilla-blocklayout"
    --     , "-fno-new-blocklayout -fvanilla-blocklayout" ]
    --   ]


    forPatch noCalls    $ always  ignoreCalls
    --forPatch someCalls  $ always  ignoreSomeCalls
    forPatch allCalls   $ always  considerAllCalls
    forPatch adjusted   $ always  "-fno-new-blocklayout -fno-vanilla-blocklayout"




main :: IO ()
main = do
    let bench = benchScript config
    let buildHead = createHead config
    let buildPatches = vcat $ map createPatch $ T.buildConf config

    putStrLn $ render (header config)
    putStrLn $ render buildHead
    putStrLn $ render buildPatches
    putStrLn $ "wait"
