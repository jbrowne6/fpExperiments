library(rerf)
library(randomForest)

nTimes <- 10
num_trees <- 64
numCores <- 32
ML <- numCores
algName <- "hello"
time <- 0

set.seed(13)
resultData <- data.frame("MNIST","FvB",numCores,time,time, stringsAsFactors=FALSE)


library(slb)
data <- slb.load.datasets(repositories="uci", task="classification")

datasets <- c("iris","breast_cancer", "chess_krvk")

for(datasetName in datasets){
  x <- data[[datasetName]]$X
  y <- as.numeric(data[[datasetName]]$Y)
  yb <- as.factor(data[[datasetName]]$Y)
  if(min(unique(y)) != 0){
    y <- y -1
  }
  if(min(unique(y)) != 0){
    stop("not all Y values are represented")
  }

  smp_size <- floor(0.80*nrow(x))

  for (algName in c("rfBase")){
    for (p in 10){
      for (i in 1:nTimes){
        print(paste(datasetName," --- ", i))
        train_ind <- sort(sample(seq_len(nrow(x)),size=smp_size))
        for(j in c(100,200,300,400,500)){
          gc()

          X <- x[train_ind,]
          Y <- y[train_ind]

          Xt <- x[-train_ind,]
          Yt <- y[-train_ind]
          forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=j,numCores=p)

          predictions <- fpPredict(forest, Xt)


          X <- x[train_ind,]
          Y <- yb[train_ind]

          Xt <- x[-train_ind,]
          Yt <- yb[-train_ind]
          rm(forest)
          forest <- randomForest(x=X, y=Y, nodesize=1,ntree=j)

          predictionsB <- predict(forest, Xt)

          error <- sum((as.numeric(predictionsB)-1)==predictions)/length(Yt)
          resultData <- rbind(resultData, c(datasetName,"FvB",i,j,error)) 

          rm(forest)

          forest <- randomForest(x=X, y=Y, nodesize=1,ntree=j)

          predictionsC <- predict(forest, Xt)

          errorB <- sum(predictionsB==predictionsC)/length(Yt)

          resultData <- rbind(resultData, c(datasetName,"BvB",i,j,errorB )) 

          rm(forest)
        }
      }
    }
  }
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])
resultData[,5] <- as.numeric(resultData[,5])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
