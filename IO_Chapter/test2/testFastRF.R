args = commandArgs()
if (length(args)!=6) {
	  stop("one argument must be supplied.")
} else {
nTimes = as.integer(args[6])
}
library(rerf)
library(data.table)

nTimes <- 1

num_trees <- 96
ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time,time, stringsAsFactors=FALSE)

for(algName in c("binnedBase","binnedBaseRerF")){

	#####################################################
	#########                MNIST
	#####################################################
	X <- as.matrix(fread(file="../../res/mnist.csv", header=FALSE, sep=","))
	Y <- X[,1]
	X <- X[, (2:785)]


	for (i in 1:nTimes){
		for (p in ML){
			gc()
			ptm <- proc.time()
			#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("MNIST", algName,p, ptm_hold,i)) 
			rm(forest)
		}
	}



	####################################################
	##########              HIGGS1
	####################################################
	X <- as.matrix(fread(file="../../res/higgsData.csv", header=FALSE, sep=","))
	Y <- as.integer(X[,1]-1)
	X <- X[, c(2:32)]

	for (i in 1:nTimes){
		for (p in ML){
			gc()
			ptm <- proc.time()
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees)
			#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("higgs", algName,p, ptm_hold,i)) 
			rm(forest)
		}
	}

	####################################################
	##########             P53 
	####################################################
	X <- as.matrix(fread(file="../../res/p53.csv", header=TRUE, sep=","))
	Y <- as.integer(X[,ncol(X)]-1)
	X <- as.matrix(X[,1:(ncol(X)-1)])

	for (i in 1:nTimes){
		for (p in ML){
			gc()
			ptm <- proc.time()
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("p53", algName,p, ptm_hold,i))  
			rm(forest)
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
