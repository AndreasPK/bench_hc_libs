# Process nofib data
#library(dplyr)    
#library(rlang)    

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
c_allCalls.all.set-operations-set.csv
resultPath <- "remoteResults/benchResultsBen4/"
compiler <- "c_allCalls"

benchmarks = c("intmap-benchmarks", "intset-benchmarks", "lookupge-intmap", "lookupge-map", "map-benchmarks",
               "sequence-benchmarks", "set-benchmarks", "set-operations-intmap", "set-operations-intset", "set-operations-map",
               "set-operations-set")

variants <- c("all",  "vanilla", "some", "none")

csvresults <- list()
for(variant in variants) {
  speedups <- list()
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


