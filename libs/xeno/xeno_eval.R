# Process nofib data
#library(dplyr)
#library(rlang)

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
resultPath <- "ben_1/" 
compiler <- "allCalls"

#get list of files
files <- list.files(resultPath, pattern="*.csv", all.files=FALSE,
                    full.names=FALSE, ignore.case = TRUE)
files
splitFun <- function(x) strsplit(x, "\\.")
splitNames <- lapply(X = files, FUN = splitFun)
splitNames
#get list of benchmarks by looking at third component of csv file name (1.2.benchmark.csv)
benchmarks = c()
for(sn in splitNames) {
  benchmarks <- unique(rbind(benchmarks, sn[[1]][3]))
}
#benchmarks = c("set-operations-set")
benchmarks


variants <- c("all",  "vanilla", "some", "none", "head")
vanillaVariant <- match(x = c("vanilla"), table = variants)
csv <- read.csv(paste(resultPath, compiler, ".", variants[[1]], ".", benchmarks[[1]], ".csv", sep=""), header = TRUE)
benchNames <- csv[,1]

resultNames <- list(variants = variants, executables = benchmarks, benchmarks = benchNames)

csvresults <- array(dim = c(length(variants), length(benchmarks), length(benchNames)), dimnames = resultNames)
for(vi in 1:length(variants)) {
  for (bi in 1:length(benchmarks)) {
    variant <- variants[vi]
    benchmark <- benchmarks[bi]
    csv <- read.csv(paste(resultPath, compiler, ".", variant, ".", benchmark, ".csv", sep=""), header = TRUE)
    csvresults[vi,bi,] <- csv[,2]
  }
}
csvresults[,1,]

speedupDim <- dim(csvresults)
speedups <- array(dim = dim(csvresults))
vanillaVariant[[1]]

for(vi in 1:length(variants)) {
  for (bi in 1:length(benchmarks)) {
    variant <- variants[vi]
    benchmark <- benchmarks[bi]
    
    speedup <- csvresults[vanillaVariant[[1]],bi,]/csvresults[vi,bi,]
    print(speedup)
    speedups[vi,bi,] <- speedup
  }
}

speedups[1,1,]

meanSpeedups <- matrix(nrow = length(benchmarks), ncol = length(variants), dimnames = list(bench = benchmarks, algo=variants))
for(vi in 1:length(variants)) {
  variant <- variants[vi]
  for(bi in 1:length(benchmarks)) {
    benchmark <- benchmarks[bi]
    speedup <- csvresults[vanillaVariant,bi,]/csvresults[vi,bi,]
    x <- gm_mean(speedup)
    meanSpeedups[bi, vi] <- x
  }
}
geoMean_overall <- apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))

meanSpeedups <- rbind(meanSpeedups, geoMean_overall)

meanSpeedups
heatmap(meanSpeedups)

(sort(apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))) * 100) - 100


