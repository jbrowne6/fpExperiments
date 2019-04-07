library(xgboost)
library(data.table)

nTimes <- 2
num_trees <- 32
numCores <- 32
ML <- 32
p <- 32
algName <- "XGBoost"
time <- 0
sampSize <- c(250000,500000,750000,1000000,1250000,1500000)
#sampSize <- c(2500,5000,7500,10000)

resultData <- data.frame("MNIST",algName,numCores,time,time,time, stringsAsFactors=FALSE)


#####################################################
#########                airine
#####################################################
x <- as.matrix(fread(file="../../res/airline_14col.csv.new", header=FALSE, sep=","))
y <- x[,14]
x <- x[,c(1:13)]
num_classes <- length(unique(y))

for(samples in sampSize){

  for (i in 1:nTimes){
			print(paste("airline ", samples, " , ", i, " , XGBoost "))
  train_ind <- sort(sample(seq_len(nrow(x)),size=samples))
  test_ind <- sort(sample(seq_len(nrow(x)),size=100000))

  X <- x[train_ind,]
  Y <- y[train_ind]

  Xt <- x[test_ind,]
  Yt <- y[test_ind]

    gc()

    ptm <- proc.time()
    forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)
    ptm_hold <- (proc.time() - ptm)[3]

    pred <- predict(forest, Xt) 
    pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
    pred_labels <- max.col(pred) - 1
    error <- sum(pred_labels == Yt)/length(Yt)

    resultData <- rbind(resultData, c("airline",algName,samples,ptm_hold,i,error)) 

resultData <- resultData[2:nrow(resultData),]
#resultData[,1] <- as.factor(resultData[,1])
#resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
    rm(forest)
  }
}


#####################################################
#########                HIGGS
#####################################################
x <- as.matrix(fread(file="../../res/HIGGS.csv", header=FALSE, sep=","))
y <- x[,1]
x <- x[, (2:ncol(x))]
num_classes <- length(unique(y))

for(samples in sampSize){
  for (i in 1:nTimes){
			print(paste("higgs ", samples, " , ", i, " , XGBoost "))
  train_ind <- sort(sample(seq_len(nrow(x)),size=samples))
  test_ind <- sort(sample(seq_len(nrow(x)),size=100000))

  X <- x[train_ind,]
  Y <- y[train_ind]

  Xt <- x[test_ind,]
  Yt <- y[test_ind]

    gc()

    ptm <- proc.time()
    forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)
    ptm_hold <- (proc.time() - ptm)[3]

    pred <- predict(forest, Xt) 
    pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
    pred_labels <- max.col(pred) - 1
    error <- sum(pred_labels == Yt)/length(Yt)

    resultData <- rbind(resultData, c("Higgs 10M",algName,samples,ptm_hold,i,error)) 

resultData <- resultData[2:nrow(resultData),]
#resultData[,1] <- as.factor(resultData[,1])
#resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
    rm(forest)
  }
}



