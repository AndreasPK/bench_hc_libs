# Process megaparsec data
#library(dplyr)    
#library(rlang)    
library(stats)
library(nortest)

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}
resultPath <- "remoteResults/ben6/"
compiler <- "allCalls"

benchmarks = c("bench-speed")
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
length(csvresults$`bench-speed`$vanilla)

speedups <- list()
for(variant in variants) {
  speedups[[variant]] <- list()
  for(benchmark in benchmarks) {
    speedup <- csvresults[[benchmark]][["vanilla"]]/csvresults[[benchmark]][[variant]]
    print(speedup)
    speedups[[variant]][[benchmark]] <- speedup
  }
}
x <- unlist(speedups$all)
#ben1 <- x
#ben2 <- x
#xeon1 <- x
xeon2 <- x

plot(ben1, col=2, ylim=c(0.85,1.15))
points(ben2, col=1)
points(xeon1, col=3)
points(xeon2, col=4)

xeon <- (xeon1 + xeon2) / 2
plot(xeon, ylim=c(0.85,1.15))

ben <- (ben1 + ben2)/2
plot(ben, col = 1, ylim=c(0.85,1.15))
points(ben1, col=2)
points(ben2, col=3)
sort(ben)[1:10]
sort(xeon)[1:10]

gm_mean(xeon)
gm_mean(ben)


abline(a = 1, b=0)
y = rnorm(100)
saphiro.te
rev(sort(x))
plot(x)
plot(sort(x))
qqnorm(x)
qqline(x)
pearson.test(x)

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

speedups
meanSpeedups <- rbind(meanSpeedups, geoMean_overall)

meanSpeedups
heatmap(meanSpeedups)

(sort(apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))) * 100) - 100


