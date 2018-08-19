{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}


module BuildScript
    (header, createPatch, createHead, benchScript, render)
where

import qualified Types as T
import Config as C

import Data.Text.Prettyprint.Doc
import Data.Text.Prettyprint.Doc.Render.String
import Data.Foldable (foldl')
import Data.Maybe

quoteVar :: Doc () -> Doc ()
quoteVar v = "${" <> v <> "}"

lineSpace :: Int -> Doc ()
lineSpace n = foldl1 (<>) $ replicate n hardline

render = renderString . layoutSmart (LayoutOptions Unbounded)

benchScript :: T.ConfState -> Doc ()
benchScript conf =
    argCheck <> hardline <>
    "mkdir -p" <+> quoteVar "LOG_DIR" <> hardline <>
    runHead runCfg <> lineSpace 2 <>
    runPatches runCfg <> lineSpace 2 <>
    runAnalyse runCfg <> hardline
  where
    runCfg = T.benchConf conf

header conf = "#!/usr/bin/env bash" <> lineSpace 3 <> defineVars conf

defineVars :: T.ConfState -> Doc ()
defineVars conf =
    "LOGNAME=$1" <> hardline <>
    "LOG_DIR="<> (pretty . T.logDir $ conf) <> hardline <>
    "TREE_DIR="<> (pretty . T.treePath $ conf) <> hardline <>
    "RUNS=5" <>



    lineSpace 3 <>
    "mkdir -p" <+> quoteVar "TREE_DIR" <> hardline

argCheck =
    "if [ -z \"$1\" ]" <> hardline <> nest 4 (
    "then" <> hardline <>
    "echo \"error - Usage: <benchName>\"" <> hardline <>
    "exit") <> hardline <>
    "fi"


runHead :: forall a. T.BenchConfState -> Doc ()
runHead conf =
    let argumentVariations = buildVariantsFor Nothing (T.settings conf) :: [[String]]
        argStrings = map (foldl' (\as a -> as <+> pretty a) mempty) argumentVariations :: [Doc ()]
        benchNames = map (\x -> "base" <> pretty x) [0 :: Int ..]
        benchPairs = zip benchNames argStrings
    in
    "cd" <+> (quoteVar "TREE_DIR" <> "/" <> pretty (T.headPath conf) <> "/nofib" ) <> hardline <>
    vcat (map makeCommand benchPairs) <> hardline

makeCommand :: (Doc (),Doc ()) -> Doc ()
makeCommand (benchName, extraArgs) =
    "make clean && make boot && make EXTRA_HC_OPTS=" <> dquotes extraArgs <+>
        "NoFibRuns=${RUNS} -k 2>&1 | tee ${LOG_DIR}/log${LOGNAME}" <> benchName <> hardline

runPatches :: T.BenchConfState -> Doc ()
runPatches conf =
    let patches = T.patches conf
        makeCommands = vcat $ map (runPatch conf) patches
    in makeCommands

runPatch :: T.BenchConfState -> T.Patch -> Doc ()
runPatch conf patch =
    let (patchName,patchPath) =
            case patch of
                T.Patch name -> (name,name)
                T.NamedPatch name path -> (name, path)

        argumentVariations = buildVariantsFor (Just patch) (T.settings conf) :: [[String]]
        argStrings = map (foldl' (\as a -> as <+> pretty a) mempty) argumentVariations :: [Doc ()]
        benchNames = map (\x -> pretty patchName <> pretty x) [0 :: Int ..]
        benchPairs = zip benchNames argStrings
    in
    "#Running patch " <> pretty patchName <+> "in directory" <+> quoteVar "TREE_DIR" <> "/" <> pretty patchPath <> "/nofib" <> hardline <>
    "cd" <+> quoteVar "TREE_DIR" <> "/" <> pretty patchPath <> "/nofib" <> hardline <>
    vcat (map makeCommand benchPairs) <> hardline <> hardline

runAnalyse conf =
    "cd" <+> dquotes (mempty)

createHead :: forall a. T.ConfState -> Doc ()
createHead T.ConfState { T.baseCommit = commit } =
    "git clone --recursive git://git.haskell.org/ghc.git" <+> patchPath <> lineSpace 2 <>
    "cd" <+> patchPath <> hardline <>
    "git checkout" <+> pretty commit <> hardline <>
    "git submodule update --init --recursive" <> hardline <>
    "git clean -fd" <> hardline <>
    buildPatch
  where
    patchPath :: Doc ()
    patchPath = quoteVar "TREE_DIR" <> "/" <> "head"

createPatch :: T.BuildInfo -> Doc ()
createPatch (T.BuildInfo patch source config) =
    mkPatchDir patch <>
    applyPatch patch source <>
    applyConfig config <>
    buildPatch
  where

mkPatchDir :: forall a. T.Patch -> Doc ()
mkPatchDir patch =
    "git clone --recursive git://git.haskell.org/ghc.git" <+> patchPath <> lineSpace 2 <>
    "cd" <+> patchPath <> hardline
  where
    patchPath :: Doc ()
    patchPath = quoteVar "TREE_DIR" <> "/" <> pretty (T.getPatchFolder patch)

applyPatch :: T.Patch -> T.PatchSource -> Doc ()
applyPatch patch (T.FromGithub repo branch) =
    "git remote add" <+> patchOrigin <+> pretty repo <> hardline <>
        "git fetch" <+> patchOrigin <> hardline <>
        "git checkout" <+> patchOrigin <> "/" <> pretty branch <> hardline <>
        "git submodule update --init --recursive" <> hardline <>
        "git clean -fd" <> hardline
  where
    patchOrigin = pretty $ T.getPatchName patch

applyConfig :: String -> Doc ()
applyConfig config =
    let conf = pretty config
    in "echo '" <> conf <> "' >> mk/build.mk" <> hardline

buildPatch :: Doc ()
buildPatch =
    "./boot" <> hardline <>
    "./configure --enable-tarballs-autodownload" <> hardline <>
    "make &" <> hardline
