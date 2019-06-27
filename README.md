# Repo for semi automatic benchmarking of ghc branches making use of hackage-head

Usage: The various (supported) libraries can be found under lib.

Each library has a driver script (driver.sh) which will try to setup and run the packages benchmarks.
This is an eternal catchup game so often some will be broken, PRs welcome!

## Running the benchmarks

All the drivers take a bunch of flags:

`driver.sh [<ghc-exec> [<ghc-alias> [<ghc-flags> [<flag-alias>]]]]`

* ghc-exec is the compiler used
* ghc-alias is a name to reference it by in file names and the like
* ghc-flags are compilation options to be passed to ghc if any 
* flag-alias is again a name to reference these with.

All of these have defaults which are:  
* ghc-exec: ghc
* ghc-alias: vanilla
* ghc-flags: ""
* ghc-flags: `<ghc-alias>`

The benchmark results will be written in the criterion-created csv format
under lib/<library>/benchResults/<ghc-alias>.<flag-alias>.csv

## Other important information

Some of the packages use Symlinks, so if you use windows make sure you set up your system correctly.
See here for details: https://www.joshkel.com/2018/01/18/symlinks-in-windows/

In general things should work at the bleeding edge but I don't actively maintain this.
If you want to benchmark against a snapshot over a longer period of time
then I suggest to adjust the driver to clone a specific commit instead.

The drivers also instruct cabal to use different caches per `ghc-alias`.
This is important since two compilers built with different settings might end up using the same cache otherwise.

## Other stuff.

If you end up using this in some fashion let me know.
Knowing people actually use it would go a long way towards me actively maintaining this.

I also welcome contributions if they don't fundamentally change how the setup works,
or maybe even if depending on the change.


