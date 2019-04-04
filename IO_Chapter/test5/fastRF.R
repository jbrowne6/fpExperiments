args = commandArgs()
if (length(args)!=13) {
	  stop("At least two arguments must be supplied.")
} else {
algName = args[6]
dataset = args[7]
numCores = as.integer(args[8])
nTimes = as.integer(args[9])
nClass = as.integer(args[10])
nSamples = as.integer(args[11])
nfeats = as.integer(args[12])
testName = as.character(args[13])
}

library(rerf)
library(data.table)

algorithm=algName
num_trees <- 128
ML <- numCores
	#ML <- c(1,2,4,8,16,32,48)
time <- 0

resultData <- data.frame(as.character(dataset),testName, algorithm,numCores, time,time,time,time,time, stringsAsFactors=FALSE)


if(dataset == "mnist"){
	#####################################################
	#########                MNIST
	#####################################################
	X <- as.matrix(fread(file="../../res/mnist.csv", header=FALSE, sep=","))
	Y <- X[,1]
	X <- X[, (2:785)]


	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("MNIST", algName,p, ptm_hold,i)) 
			rm(forest)
		}
	}
}


if(dataset == "Higgs"){
	####################################################
	##########              HIGGS1
	####################################################
	X <- read.csv(file="../../res/higgsData.csv", header=FALSE, sep=",")
	Y <- as.integer(X[,1]-1)
	X <- X[, c(2:32)]

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
			#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("higgs", algName,p, ptm_hold)) 
			rm(forest)
		}
	}
}




if(dataset == "p53"){
	####################################################
	##########             P53 
	####################################################
	X <- read.csv(file="../../res/p53.csv", header=TRUE, sep=",")
	Y <- as.integer(X[,ncol(X)]-1)
	X <- as.matrix(X[,1:(ncol(X)-1)])

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
			#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("p53", algName,p, ptm_hold))  
			rm(forest)
		}
	}
}


if(dataset == "svhn"){
	####################################################
	##########             svhn 
  ####################################################
  X <- as.matrix(fread(file="temp_data.csv", header=FALSE, sep=","))
  Y <- as.numeric(fread(file="temp_label.csv", header=FALSE, sep=",")$V1)
  if(min(Y) != 0){
    Y <- Y -1
  }
  if(min(Y) != 0){
    stop("dataset does not contain 0, fastRF")
  }

	gc()
	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
			ptm_hold <- (proc.time() - ptm)[3]

			resultData <- rbind(resultData, c("svhn", algName,testName,p,ptm_hold,nClass,nSamples,nfeats,i))
			rm(forest)
		}
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.factor(resultData[,3])
resultData[,5] <- as.numeric(resultData[,5])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
