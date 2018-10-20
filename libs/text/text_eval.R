# Process nofib data
#library(dplyr)
#library(rlang)

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
c_allCalls.all.set-operations-set.csv
resultPath <- "ben_1/" 
compiler <- "allCalls"

#get list of files
files <- list.files(resultPath, pattern="*.csv", all.files=FALSE,
                    full.names=FALSE)
files
splitFun <- function(x) strsplit(x, "\\.")
splitNames <- lapply(X = files, FUN = splitFun)
#get list of benchmarks by looking at third component of csv file name (1.2.benchmark.csv)
benchmarks = c()
for(sn in splitNames) {
  benchmarks <- unique(rbind(benchmarks, sn[[1]][3]))
}
#benchmarks = c("set-operations-set")
benchmarks


variants <- c("all",  "vanilla", "some", "none", "head")

csvresults <- list()
for(variant in variants) {
#for(variant in c("aeson_adjusted",  "aeson_allCalls",  "aeson_head",  "aeson_noCalls",  "aeson_someCalls",  "aeson_vanilla")) {

  speedups <- list()
  benchmark <- "aeson-benchmark-typed"
  for (benchmark in benchmarks) {
    print(variant)
    print(benchmark)
    csv <- read.csv(paste(resultPath, compiler, ".", variant, ".", benchmark, ".csv", sep=""), header = TRUE)
    n <- row.names(csv)
    n <- paste(n, csv[n,1], sep="")
    csv <- csv[,-1]
    rownames(csv) <- n
    csvresults[[benchmark]][[variant]] <- csv[,1]
    names(csvresults[[benchmark]][[variant]]) <- rownames(csv)
  }
}
csvresults

speedups <- list()
for(variant in variants) {
  speedups[[variant]] <- list()
  for(benchmark in benchmarks) {
    speedup <- csvresults[[benchmark]][["vanilla"]]/csvresults[[benchmark]][[variant]]
    print(speedup)
    speedups[[variant]][[benchmark]] <- speedup
  }
}

meanSpeedups <- matrix(nrow = length(benchmarks), ncol = length(variants), dimnames = list(bench = benchmarks, algo=variants))
for(vi in 1:length(variants)) {
  variant <- variants[vi]
  for(bi in 1:length(benchmarks)) {
    benchmark <- benchmarks[bi]
    speedup <- csvresults[[benchmark]][["vanilla"]]/csvresults[[benchmark]][[variant]]
    x <- gm_mean(speedup)
    meanSpeedups[bi, vi] <- x
  }
}
geoMean_overall <- apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))

meanSpeedups <- rbind(meanSpeedups, geoMean_overall)

meanSpeedups
heatmap(meanSpeedups)

sort(apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))) * 100


