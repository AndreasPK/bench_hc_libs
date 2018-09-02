# Process nofib data
#library(dplyr)    
#library(rlang)    

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
#c_allCalls.all.set-operations-set.csv
resultPath <- "results/xeon1_r7/"
#Use _c prefix for older result sets:
#compiler <- "c_allCalls"
compiler <- "allCalls"
benchmarks = c("intmap-benchmarks", "intset-benchmarks", "lookupge-intmap", "lookupge-map", "map-benchmarks",
               "sequence-benchmarks", "set-benchmarks", "set-operations-intmap", "set-operations-intset", "set-operations-map",
               "set-operations-set")

variants <- c("all",  "vanilla", "some", "none", "head")
#variants <- c("all",  "vanilla", "none")

h1 <- read.csv("results/xeon2_r3/head.lookupge-intmap.csv", header = TRUE)
v1 <- read.csv("results/xeon2_r3/allCalls.none.lookupge-intmap.csv", header = TRUE)

gm_mean((h1/v1)[,2])

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

withSummary <- rbind(meanSpeedups, geoMean_overall)
withSummary
heatmap(withSummary)

withSummary * 100 - 100

x <- (sort(apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))) * 100) - 100
n3 <- withSummary[1,1]
gm_mean(c(n1,n2,n3))
