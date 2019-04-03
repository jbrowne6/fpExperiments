args = commandArgs()
if (length(args)!=11) {
  stop("At least two arguments must be supplied.")
} else {
  dataset = args[6]
  numThreads = as.integer(args[7])
  nTimes = as.integer(args[8])
  nClass = as.integer(args[9])
  nSamples = as.integer(args[10])
  nfeats = as.integer(args[11])
}

library(xgboost)

nTimes <- 1

num_trees <- 128
ML <- numThreads

algorithm <- "XGBoost"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores,time,time,time,time,time, stringsAsFactors=FALSE)


if(dataset == "mnist"){
  #####################################################
  #########                MNIST
  #####################################################
  X <- as.matrix(read.csv(file="../res/mnist.csv", header=FALSE, sep=","))
  Y <- X[,1]
  X <- X[, (2:785)]
  num_classes <- length(unique(Y))


  for (p in ML){
    for (i in 1:nTimes){
      gc()
      ptm <- proc.time()
      forest <- xgboost(data=X, label=Y, objective="multi:softmax",nrounds=num_trees,colsample_bynode=ceiling(sqrt(ncol(X))), num_class=num_classes, nthread=p)
      ptm_hold <- (proc.time() - ptm)[3]
      resultData <- rbind(resultData, c("MNIST", "XGBoost",p, ptm_hold)) 
    }
  }
}


if(dataset == "Higgs"){
  ####################################################
  ##########              HIGGS1
  ####################################################
  X <- as.matrix(read.csv(file="../res/higgsData.csv", header=FALSE, sep=","))
  Y <- X[,1]-1
  X <- X[, c(2:32)]
  num_classes <- length(unique(Y))

  for (p in ML){
    for (i in 1:nTimes){
      gc()
      ptm <- proc.time()
      forest <- xgboost(data=X, label=Y, objective="multi:softmax",nrounds=num_trees,colsample_bynode=ceiling(sqrt(ncol(X))), num_class=num_classes, nthread=p)
      ptm_hold <- (proc.time() - ptm)[3]
      resultData <- rbind(resultData, c("higgs", "XGBoost",p, ptm_hold)) 
    }
  }


}


if(dataset == "p53"){
  ####################################################
  ##########             P53 
  ####################################################
  X <- as.matrix(read.csv(file="../res/p53.csv", header=TRUE, sep=","))
  Y <- X[,ncol(X)]-1
  X <- X[,1:(ncol(X)-1)]
  num_classes <- length(unique(Y))

  for (p in ML){
    for (i in 1:nTimes){
      gc()
      ptm <- proc.time()
      forest <- xgboost(data=X, label=Y, objective="multi:softmax",nrounds=num_trees,colsample_bynode=ceiling(sqrt(ncol(X))), num_class=num_classes, nthread=p)
      ptm_hold <- (proc.time() - ptm)[3]
      resultData <- rbind(resultData, c("p53", "XGBoost",p, ptm_hold)) 
    }
  }
}



if(dataset == "svhn"){
  ####################################################
  ##########             svhn 
  ####################################################
  X <- as.matrix(read.csv(file="temp_data.csv", header=FALSE, sep=","))
  Y <- read.csv(file="temp_label.csv", header=FALSE, sep=",")$V1
  num_classes <- length(unique(Y))

  gc()
  for (p in ML){
    for (i in 1:nTimes){
      gc()
      ptm <- proc.time()
      forest <- xgboost(data=X, label=Y, objective="multi:softmax",nrounds=num_trees,colsample_bynode=ceiling(sqrt(ncol(X))), num_class=num_classes, nthread=p)
      ptm_hold <- (proc.time() - ptm)[3]
      resultData <- rbind(resultData, c(dataset, "XGBoost",p, ptm_hold,nClass,nSamples,nfeats,i))
      rm(forest)
    }
  }
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
