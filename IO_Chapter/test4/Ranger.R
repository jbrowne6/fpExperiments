library(ranger)
library(data.table)

nTimes <- 2
num_trees <- 512
numCores <- 16
ML <- numCores
algName <- "hello"
nTree <- c(1,2)
nTree <- c(1,2,4,8,16,32)
time <- 0

resultData <- data.frame("MNIST",algName, numCores, time, time, stringsAsFactors=FALSE)


#####################################################
#########                MNIST
#####################################################
X <- as.matrix(fread(file="../../res/mnist.csv", header=FALSE, sep=","))
X <- X[, c(2:785, 1)]
colnames(X) <- as.character(1:ncol(X))

for (tMult in nTree){
  num_trees <- tMult*numCores
  for (i in 1:nTimes){
				print(paste("Ranger mnist ", tMult, " , ", i, " test4"))
    for (p in ML){
      gc()
      forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)

      ptm <- proc.time()
      pred <- predict(forest,X, num.threads=p)
      ptm_hold <- (proc.time() - ptm)[3]

      resultData <- rbind(resultData, c("MNIST", "Ranger",num_trees, ptm_hold,i)) 

resultData <- resultData[2:nrow(resultData),]
#resultData[,1] <- as.factor(resultData[,1])
#resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
    }
  }
}


####################################################
##########              HIGGS1
####################################################
X <- as.matrix(fread(file="../../res/higgsData.csv", header=FALSE, sep=","))
X <- X[, c(2:32, 1)]
colnames(X) <- as.character(1:ncol(X))

for (tMult in nTree){
  num_trees <- tMult*numCores
  for (i in 1:nTimes){
				print(paste("Ranger higgs ", tMult, " , ", i, " test4"))
    for (p in ML){
      gc()
      forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)

      ptm <- proc.time()
      pred <- predict(forest,X, num.threads=p)
      ptm_hold <- (proc.time() - ptm)[3]

      resultData <- rbind(resultData, c("higgs", "Ranger",num_trees, ptm_hold,i)) 
resultData <- resultData[2:nrow(resultData),]
#resultData[,1] <- as.factor(resultData[,1])
#resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
    }
  }
}


####################################################
##########             P53 
####################################################
X <- as.matrix(fread(file="../../res/p53.csv", header=TRUE, sep=","))
colnames(X) <- as.character(1:ncol(X))

for (tMult in nTree){
  num_trees <- tMult*numCores
  for (i in 1:nTimes){
				print(paste("Ranger p53 ", tMult, " , ", i, " test4"))
    for (p in ML){
      gc()
      forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)

      ptm <- proc.time()
      pred <- predict(forest,X, num.threads=p)
      ptm_hold <- (proc.time() - ptm)[3]

      resultData <- rbind(resultData, c("p53", "Ranger",num_trees, ptm_hold,i)) 
resultData <- resultData[2:nrow(resultData),]
#resultData[,1] <- as.factor(resultData[,1])
#resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)

    }
  }
}



