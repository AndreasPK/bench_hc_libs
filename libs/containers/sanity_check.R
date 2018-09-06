# Compare runs with same settings
#library(dplyr)    
#library(rlang)
library(nortest)

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}


c_allCalls.all.set-operations-set.csv
runs <- c(base = "remoteResults/benchResultsXeon1/", snd = "remoteResults/benchResultsXeon2/")
runs <- c(base = "remoteResults/benchResultsBen2/", snd = "remoteResults/benchResultsBen3/")
runs <- c(base = "remoteResults/benchResultsBen3/", snd = "remoteResults/benchResultsBen4/")
runs <- c(base = "remoteResults/benchResultsBen2/", snd = "remoteResults/benchResultsBen4/")

bn1 <- read.csv("remoteResults/benchResultsBen2/c_allCalls.all.set-operations-set.csv")
bn2 <- read.csv("remoteResults/benchResultsBen3/c_allCalls.all.set-operations-set.csv")
bn3 <- read.csv("remoteResults/benchResultsBen4/c_allCalls.all.set-operations-set.csv")
bn4 <- read.csv("remoteResults/ben1/allCalls.all.set-operations-set.csv")

bv1 <- read.csv("remoteResults/benchResultsBen2/c_allCalls.vanilla.set-operations-set.csv")
bv2 <- read.csv("remoteResults/benchResultsBen3/c_allCalls.vanilla.set-operations-set.csv")
bv3 <- read.csv("remoteResults/benchResultsBen4/c_allCalls.vanilla.set-operations-set.csv")
bv4 <- read.csv("remoteResults/ben1/allCalls.vanilla.set-operations-set.csv")

runs <- list(bv1,bv2,bv3,bv4,bn1,bn2,bn3,bn4)
runs <- list(bv1,bv2,bv3,bn1,bn2,bn3)

names(runs) <- c("van1", "van2", "van3", "van4","all1", "all2", "all3", "all4")[1:length(runs)]

names <- array(dim = c(length(bn1[,1])))
for (i in 1:length(bn1[,1])) {
  names[i] <- paste(i,"_",bn1[i,1],sep="")
}
bn1[,1]
names
mnames <- list(benchmark = names, run = names(runs))
measured <- matrix(ncol = length(runs), nrow = length(bv1[,1]), dimnames = mnames )
for(run in 1:length(runs)) {
  for(bi in length(bv1)) {
    measured[,run] <- runs[[run]][,2]
  }
}

measured

vanilla <- rowMeans(measured[,1:3])
new <- rowMeans(measured[,4:6])
new

plot(vanilla/new)
points(measured[,1]/measured[,4], col=2)

speedup <- measured[,4]/measured[,8]
speedup

sort(speedup)[1:20]

gm_mean(speedup)

plot(log(measured[,1]))
points(log(measured[,2]),col=3)
points(log(measured[,2]),col=4)
points(log(vanilla), col=2)






x <- (bn1[,2] + bn2[,2] + bn3[,2] + bn4[,2])/4
new <- x

names(vanilla)

median(x)
vanilla <- median(x = array(bv1[,2], bv2[,2], bv3[,2], bv4[,2]))
new <-     median(bn1[,2], bn2[,2], bn3[,2], bn4[,2])


compiler <- "c_allCalls"

benchmarks = c("intmap-benchmarks", "intset-benchmarks", "lookupge-intmap", "lookupge-map", "map-benchmarks",
               "sequence-benchmarks", "set-benchmarks", "set-operations-intmap", "set-operations-intset", "set-operations-map",
               "set-operations-set")

variants <- c("all",  "vanilla")
runResults <- list()
for(run in names(runs)) {
  resultPath <- runs[[run]]
  csvresults <- list()
  for(variant in variants) {
    speedups <- list()
    for (benchmark in benchmarks) {
      #print(variant)
      #print(benchmark)
      csv <- read.csv(paste(resultPath, compiler, ".", variant, ".", benchmark, ".csv", sep=""), header = TRUE)
      n <- row.names(csv)
      n <- paste(n, csv[n,1], sep="")
      csv <- csv[,-1]
      rownames(csv) <- n
      csvresults[[benchmark]][[variant]] <- csv[,1]
      names(csvresults[[benchmark]][[variant]]) <- rownames(csv)
    }
  }
  runResults[[run]] <- csvresults
}
#csvresults

x1 <- unlist(recursive = TRUE, x = runResults[["base"]])
x2 <- unlist(recursive = TRUE, x = runResults[["snd"]])
x <- x1/x2
plot(x, ylim = c(0.8,1.2))
title(main= "Runtime1/Runtime2 using same settings")
y <- approx(x, n = length(x)/10)
lines(y, col = "red", lwd = 3)
mean(x)
gm_mean(x)
mean(x[1:length(x)/2])
mean(x[length(x)/2 : length(x)])

qqplot(y = x)
pearson.test(x)

speedups <- list()
for(variant in variants) {
  speedups[[variant]] <- list()
  for(benchmark in benchmarks) {
    speedup <- csvresults[[benchmark]][["vanilla"]]/csvresults[[benchmark]][[variant]]
    print(speedup)
    speedups[[variant]][[benchmark]] <- speedup
  }
}

x <- speedups$all$`set-operations-set`
plot(x)


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

sort(meanSpeedups[,1])
heatmap(meanSpeedups)

sort(apply(FUN = gm_mean, X = meanSpeedups, MARGIN = c(2))) * 100


