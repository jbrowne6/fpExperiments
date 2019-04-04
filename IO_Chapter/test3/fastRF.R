library(rerf)
library(data.table)

nTimes <- 10
num_trees <- 32
numCores <- 32
ML <- 32
p <- 32
algName <- "hello"
time <- 0
#sampSize <- c(250000,500000,750000,1000000,1250000,1500000)
sampSize <- c(2500,5000,7500,10000)

resultData <- data.frame("MNIST",algName,numCores,time,time,time, stringsAsFactors=FALSE)



#####################################################
#########                airine
#####################################################
x <- as.matrix(fread(file="../../res/airline_14col.csv.new", header=FALSE, sep=","))
y <- x[,14]
x <- x[, c(1:13)]
#x <- as.matrix(iris[,1:4])
#y <- as.numeric(iris[,5])

for (algName in c("rfBase","rerf")){
  for(samples in sampSize){
    train_ind <- sort(sample(seq_len(nrow(x)),replace=FALSE,size=samples))
    test_ind <- sort(sample(seq_len(nrow(x)),replace=FALSE,size=100000))

    # train_ind <- sort(sample(seq_len(150),replace=FALSE,size = samples))

    X <- as.matrix(x[train_ind,])
    Y <- as.numeric(y[train_ind])

    Xt <- x[test_ind,]
    Yt <- y[test_ind]
    #Xt <- x[-train_ind,]
    #Yt <- y[-train_ind]

    for (i in 1:nTimes){
      gc()
      ptm <- proc.time()
      #forest <- fpRerF(X=X, Y=Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
      forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p,nodeSizeToBin=500, nodeSizeBin=500)
      ptm_hold <- (proc.time() - ptm)[3]

      predictions <- fpPredict(forest, Xt)
      error <- sum(predictions == Yt)/length(Yt)

      resultData <- rbind(resultData, c("airline",algName,samples,ptm_hold,i,error)) 

      rm(forest)
    }
  }
}


#####################################################
#########                HIGGS
#####################################################
x <- as.matrix(fread(file="../../res/HIGGS.csv", header=FALSE, sep=","))
y <- x[,1]
x <- x[, c(2:ncol(x))]

for (algName in c("rfBase","rerf")){
  for(samples in sampSize){
    train_ind <- sort(sample(seq_len(nrow(x)),size=samples))
    test_ind <- sort(sample(seq_len(nrow(x)),size=100000))

    X <- x[train_ind,]
    Y <- y[train_ind]

    Xt <- x[test_ind,]
    Yt <- y[test_ind]

    for (i in 1:nTimes){
      gc()

      ptm <- proc.time()
      #forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
      forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p,nodeSizeToBin=500, nodeSizeBin=500)
      ptm_hold <- (proc.time() - ptm)[3]

      predictions <- fpPredict(forest, Xt)
      error <- sum(predictions == Yt)/length(Yt)

      resultData <- rbind(resultData, c("Higgs 10M",algName,samples,ptm_hold,i,error)) 

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
