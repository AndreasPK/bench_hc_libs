# Process nofib data
#library(dplyr)    
#library(rlang)    

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

resultPath <- "ben_1/"
compiler <- "allCalls"

benchmarks = c("aeson-benchmark-typed", "aeson-benchmark-micro", "aeson-benchmark-map", "aeson-benchmark-foldable",
               "aeson-benchmark-escape", "aeson-benchmark-dates", "aeson-benchmark-compare-with-json", "aeson-benchmark-compare", "aeson-benchmark-auto-compare")

variants <- c("all",  "vanilla", "none", "head", "some")

csvresults <- list()
for(variant in variants) {
#for(variant in c("aeson_adjusted",  "aeson_allCalls",  "aeson_head",  "aeson_noCalls",  "aeson_someCalls",  "aeson_vanilla")) {
   
  speedups <- list()
  benchmark <- "aeson-benchmark-typed"
  for (benchmark in benchmarks) {
    print(variant)
    print(benchmark)
    csv <- read.csv(paste(resultPath, compiler, ".", variant, ".", benchmark, ".csv", sep=""), header = TRUE, row.names = 1)
    csvresults[[benchmark]][[variant]] <- csv[,1]
    names(csvresults[[benchmark]][[variant]]) <- rownames(csv)
  }
}

speedups <- list()
for(variant in variants) {
  speedups[[variant]] <- list()
  for(benchmark in benchmarks) {
    speedup <- csvresults[[benchmark]][["head"]]/csvresults[[benchmark]][[variant]]
    print(speedup)
    speedups[[variant]][[benchmark]] <- speedup
  }
}

sort(speedups$none$`aeson-benchmark-typed`)


meanSpeedups <- matrix(nrow = length(benchmarks), ncol = length(variants), dimnames = list(bench = benchmarks, algo=variants))
for(vi in 1:length(variants)) {
  variant <- variants[vi]
  for(bi in 1:length(benchmarks)) {
    benchmark <- benchmarks[bi]
    speedup <- csvresults[[benchmark]][["head"]]/csvresults[[benchmark]][[variant]]
    x <- gm_mean(speedup)
    meanSpeedups[bi, vi] <- x
  }
}
geoMean_overall <- apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))

meanSpeedups <- rbind(meanSpeedups, geoMean_overall)

meanSpeedups
heatmap(meanSpeedups)

sort(apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))) * 100 - 100


