# Process nofib data
#library(dplyr)    
#library(rlang)    

results <- list()
for(variant in c("aeson_adjusted",  "aeson_allCalls",  "aeson_head",  "aeson_noCalls",  "aeson_someCalls",  "aeson_vanilla")) {
  
  benchmarks = c("aeson-benchmark-typed", "aeson-benchmark-micro", "aeson-benchmark-map", "aeson-benchmark-foldable",
                 "aeson-benchmark-escape", "aeson-benchmark-dates", "aeson-benchmark-compare-with-json", "aeson-benchmark-compare", "aeson-benchmark-auto-compare")
   
  speedups <- list()
  benchmark <- "aeson-benchmark-typed"
  for (benchmark in benchmarks) {
    print(variant)
    print(benchmark)
    old <- read.csv(paste("aeson_head/", benchmark, ".csv", sep=""), header = TRUE, row.names = 1)
    old_means <- old[,1]
    old_means
    new <- read.csv(paste(variant, "/", benchmark, ".csv", sep=""), header = TRUE, row.names = 1)
    new_means <- new[,1]
    new_means
  
    speedup <- mean(old_means/new_means)
    speedups[[benchmark]] <- speedup
  }
  x <- unlist(speedups)
  results[[variant]] <- x
}

print(results)
x <- x*100
print(x)
print("Speedup avg")
print(mean(x))
print("Speedup med")
print(median(x))

gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

