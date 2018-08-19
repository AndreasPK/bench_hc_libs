{-# LANGUAGE ScopedTypeVariables #-}

module Config
where

import Types as T
import Control.Monad.State.Strict
import Data.Monoid

type CM = State ConfState

buildConfig :: CM a -> ConfState
buildConfig = flip execState defaultConfig

defaultConfig :: ConfState
defaultConfig =
    T.ConfState
        "logs" --log dir
        "." -- build tree path
        defBench
        "master" -- base commit/branch
        [] -- build no new patches
  where
    defBench =
        T.BenchConfState
            "head" -- head path
            [Patch "ghc"] -- patch paths
            [] -- No default settings

modBench :: (BenchConfState -> BenchConfState) -> CM ()
modBench f = do
    s <- get :: CM ConfState
    let bs = f $ benchConf s
    put $ s { benchConf = bs}

headDir :: FilePath -> CM ()
headDir path = do
    let update :: T.BenchConfState -> T.BenchConfState
        update conf =
            conf { headPath = path}
    modBench update

baseCommit :: String -> CM ()
baseCommit commit = do
    let update :: T.ConfState -> T.ConfState
        update conf =
            conf { T.baseCommit = commit}
    modify' update

treeDir :: FilePath -> CM ()
treeDir path =
    modify' (\conf ->
        conf {T.treePath = path})

logDir :: FilePath -> CM ()
logDir path =
    modify' (\conf ->
        conf {T.logDir = path})

patchList :: [T.Patch] -> CM ()
patchList patches =
    modBench (\conf ->
        conf {T.patches = patches})

patch :: FilePath -> T.Patch
patch = T.Patch

namedPatch :: String -> FilePath -> T.Patch
namedPatch = T.NamedPatch

addPatch :: FilePath -> CM ()
addPatch = addPatch' Nothing

addPatch' :: Maybe String -> FilePath -> CM ()
addPatch' name path = do
    conf <- get :: CM ConfState
    let patch = maybe (Patch path) (\n -> NamedPatch n path) name
    let patches = patch : (T.patches . benchConf) conf :: [T.Patch]
    let bc = benchConf conf
    put $ conf {benchConf = bc {patches = patches}}

addPatchWithName :: String -> FilePath -> CM ()
addPatchWithName name path = addPatch' (Just name) path

-- | Run with and without this flag
toggle :: String -> SettingOptions
toggle = ToggleSetting

-- | Switch between all given settings
switch :: [String] -> SettingOptions
switch = ChoiceSetting

always :: String -> SettingOptions
always = AlwaysSetting

paramChoice :: String -> [String] -> SettingOptions
paramChoice name values = ChoiceSetting (map (\v -> name <> "=" <> v) values)

addSetting :: PatchSettings -> CM ()
addSetting setting = do
    conf <- get :: CM ConfState
    let bc = benchConf conf
    let bc' = bc {settings = setting : T.settings bc}
    put $ conf { benchConf = bc' }

forAll :: SettingOptions -> CM ()
forAll option = addSetting $ PatchSettings TargetAll option

forHead :: SettingOptions -> CM ()
forHead option = addSetting $ PatchSettings TargetHead option

forPatches :: SettingOptions -> CM ()
forPatches option = addSetting $ PatchSettings TargetAllPatched option

mkPatch :: String -> Patch
mkPatch = Patch

forPatch :: Patch -> SettingOptions -> CM ()
forPatch patch option = addSetting $ PatchSettings (TargetPatch patch) option



{-
---------------------------------------------------------------------------
                        Combining the options
---------------------------------------------------------------------------
-}

-- | Does a setting apply to the given patch/head
appliesTo :: PatchSettings -> Maybe Patch -> Bool
appliesTo (PatchSettings TargetAll    _)              _ =
    True
appliesTo (PatchSettings TargetHead   _)              Nothing =
    True
appliesTo (PatchSettings (TargetPatch targetPatch) _) (Just patch)
    = patch == targetPatch
appliesTo (PatchSettings TargetAllPatched _)          (Just _)
    = True
appliesTo _ _ = False

buildVariantsFor :: Maybe Patch -> [PatchSettings] -> [[String]]
buildVariantsFor mp settings = do
    --Apply settings specified later later
    mapM (buildOptions . settingOption) $ reverse settings'
    where
        settings' = filter (`appliesTo` mp) settings

buildOptions :: SettingOptions -> [String]
buildOptions (ToggleSetting s) = ["", s]
buildOptions (ChoiceSetting s) = s
buildOptions (AlwaysSetting s) = [s]


{-
---------------------------------------------------------------------------
                        Building a patch
---------------------------------------------------------------------------
-}

addBuild :: BuildInfo -> CM ()
addBuild bi = do
    s <- get
    let bc = T.buildConf s
    put s { buildConf = bi : bc}

buildInfo :: Patch -> PatchSource -> T.BuildSettings -> T.BuildInfo
buildInfo = BuildInfo

-- | From @repo@ use @branch@
fromGithub :: String -> String -> PatchSource
fromGithub repo branch = FromGithub repo branch

mkBuildConfig :: [(String,String)] -> BuildSettings
mkBuildConfig settings =
    unlines $ map (\(setting,value) -> setting <> "=" <> value) settings
