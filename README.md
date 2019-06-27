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

In general the HEAD version of repos is run! If you want to benchmark against a snapshot
over a longer period of time adjust the driver to clone a specific commit instead.

We also instruct cabal to use different caches per `ghc-alias`.
This is important since two compilers built with different settings might end up using the same cache otherwise.

## Contributing

If you end up using this in some fashion let me know.
Knowing people actually use it would go a long way towards me actively maintaining this.

I also welcome contributions if they don't fundamentally change how the setup works.


