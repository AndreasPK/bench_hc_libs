# Process nofib data
#library(dplyr)
#library(rlang)

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
resultPath <- "results/sky1/" 
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

benchmarks


variants <- c("all",  "vanilla", "some", "none")
vanillaVariant <- match(x = c("vanilla"), table = variants)
csv <- read.csv(paste(resultPath, compiler, ".", variants[[1]], ".", benchmarks[[1]], ".csv", sep=""), header = TRUE)
benchNames <- csv[,1]

resultNames <- list(variants = variants, executables = benchmarks, benchmarks = benchNames)
resultNames
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
dimnames(speedups) <- dimnames(csvresults)

x <- speedups[,1,]
x
speedup_none <- x[4,]
names(speedup_none)
speedup_none
gm_mean(speedup_none)
y <- 100*speedup_none-100

names(y) <- names(speedup_none)
y

barplot(y, ylim=c(-20,20))
x <- (speedups[,1,] - 1) * 100

apply(X = x, FUN = gm_mean, MARGIN = c(2))

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
meanSpeedups
dimnames(meanSpeedups)
dimnames(meanSpeedups) <- c(dimnames(csvresults)[2], dimnames(csvresults)[1] )

geoMean_overall <- apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))

meanSpeedups <- rbind(meanSpeedups, geoMean_overall)

meanSpeedups
heatmap(meanSpeedups)

(sort(apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))) * 100) - 100


