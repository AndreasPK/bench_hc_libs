module Types
where

-- | Settings can apply to all or specific builds
data SettingTarget = TargetAll | TargetHead | TargetPatch Patch | TargetAllPatched deriving (Eq,Show,Ord)

data SettingOptions
    = ToggleSetting String -- ^ Use flag or not
    | ChoiceSetting [String] -- ^ ChoiceSetting [p1,p2,p3] -> Use p1, then p2, then p3, ...
    | AlwaysSetting String -- ^ AlwaysSetting foo -> Always use foo
    deriving (Eq,Ord,Show)

-- Build a patch from scratch

data PatchSource
    = FromGithub
    { repo :: String
    , branch :: String
    } deriving (Eq,Ord,Show)

type BuildSettings = String

data BuildInfo
    = BuildInfo
    { buildPatch :: Patch
    , buildSource :: PatchSource
    , buildConfig :: BuildSettings
    } deriving (Eq,Ord,Show)



-- | Represents a patch/build directory
data Patch
    = Patch String -- ^ patch and path name are are the same
    | NamedPatch String FilePath -- ^ differentiate patch path and name
    deriving (Eq,Show,Ord)

getPatchName :: Patch -> String
getPatchName (Patch n) = n
getPatchName (NamedPatch n _) = n

getPatchFolder :: Patch -> FilePath
getPatchFolder (Patch p) = p
getPatchFolder (NamedPatch _ p) = p


data PatchSettings = PatchSettings
    { settingTarget :: SettingTarget
    , settingOption :: SettingOptions
    } deriving (Eq,Show,Ord)

data ConfState
    = ConfState
    { logDir :: FilePath
    , treePath :: FilePath
    , benchConf :: BenchConfState
    , baseCommit :: String
    , buildConf :: [BuildInfo]
    } deriving (Eq,Ord,Show)

data BenchConfState
    = BenchConfState
    { headPath :: FilePath
    , patches :: [Patch]
    , settings :: [PatchSettings]
    } deriving (Eq,Ord,Show)
