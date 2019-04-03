library(lightgbm)
library(data.table)

nTimes <- 2

num_trees <- 512
#ML <- c(32,48)
ML <- c(32)
nTree <- c(1,2)
#nTree <- c(1,2,4,8,16,32)
algorithm <- "lightGBM"
numCores <- 32
time <- 0

resultData <- data.frame("MNIST", algorithm, numCores, time,time, stringsAsFactors=FALSE)

if(FALSE){
  #####################################################
  #########                MNIST
  #####################################################
  X <- as.matrix(fread(file="../../res/mnist.csv", header=FALSE, sep=","))
  Y <- X[,1]
  X <- X[, (2:785)]
  num_classes <- length(unique(Y))

  dtrain <- lgb.Dataset(data=X,label=Y)
  num_classes <- length(unique(Y))

  for (tMult in nTree){
    num_trees <- tMult*numCores
    for (i in 1:nTimes){
      for (p in ML){
        gc()
        ptm <- proc.time()
        forest <- lgb.train(data=dtrain, objective="multiclass",num_class=num_classes,learning_rate=1,nrounds=num_trees, nthread=p,early_stopping_rounds=0)
        ptm_hold <- (proc.time() - ptm)[3]

        ptm <- proc.time()
        pred <- predict(forest, X) 
        #pred <- predict(forest, X, reshape=TRUE) 
        #pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
        #pred_labels <- max.col(pred) - 1
        ptm_hold <- (proc.time() - ptm)[3]

        resultData <- rbind(resultData, c("MNIST", algorithm,p, ptm_hold,i)) 
      }
    }
  }
}

####################################################
##########              HIGGS1
####################################################
X <- as.matrix(fread(file="../../res/higgsData.csv", header=FALSE, sep=","))
Y <- X[,1]-1
X <- X[, c(2:32)]
dtrain <- lgb.Dataset(data=X,label=Y)
num_classes <- length(unique(Y))


for (tMult in nTree){
  num_trees <- tMult*numCores
  for (i in 1:nTimes){
    for (p in ML){
      gc()
      forest <- lgb.train(data=dtrain, objective="multiclass",min_data_in_leaf = 1, num_class=num_classes,learning_rate=1,nrounds=num_trees, nthread=p)

      ptm <- proc.time()
      pred <- predict(forest, X, reshape=TRUE) 
      pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
      pred_labels <- max.col(pred) - 1
      ptm_hold <- (proc.time() - ptm)[3]

      resultData <- rbind(resultData, c("higgs",algorithm,p, ptm_hold,i)) 
    }
  }
}


####################################################
##########             P53 
####################################################
X <- as.matrix(fread(file="../../res/p53.csv", header=TRUE, sep=","))
Y <- X[,ncol(X)]-1
X <- X[,1:(ncol(X)-1)]
dtrain <- lgb.Dataset(data=X,label=Y)
num_classes <- length(unique(Y))

for (tMult in nTree){
  num_trees <- tMult*numCores
  for (i in 1:nTimes){
    for (p in ML){
      gc()
      forest <- lgb.train(data=dtrain, objective="multiclass",num_class=num_classes,learning_rate=1,nrounds=num_trees, nthread=p)

      ptm <- proc.time()
      pred <- predict(forest, X, reshape=TRUE) 
      pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
      pred_labels <- max.col(pred) - 1
      ptm_hold <- (proc.time() - ptm)[3]


      resultData <- rbind(resultData, c("p53",algorithm,p, ptm_hold,i)) 
    }
  }
}





if(FALSE){
  ####################################################
  ##########             svhn 
  ####################################################
  dtrain <- lgb.Dataset(data=as.matrix(read.csv(file="temp_data.csv", header=FALSE, sep=",")),
                        label=read.csv(file="temp_label.csv", header=FALSE, sep=",")$V1)
  num_classes <- length(unique(read.csv(file="temp_label.csv", header=FALSE, sep=",")$V1))

  gc()
  for (p in ML){
    for (i in 1:nTimes){
      gc()
      ptm <- proc.time()
      forest <- lgb.train(data=dtrain, objective="multiclass",nrounds=num_trees, num_class=num_classes, nthread=p)
      ptm_hold <- (proc.time() - ptm)[3]
      resultData <- rbind(resultData, c(dataset, algName,p, ptm_hold),nClass,nSamples,nfeats)  
      rm(forest)
    }
  }
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
