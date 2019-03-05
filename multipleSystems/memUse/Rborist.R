args = commandArgs()
if (length(args)!=7) {
	stop("At least two arguments must be supplied.")
} else {
	dataset = args[6]
	numThreads = as.integer(args[7])
}

library(Rborist)

nTimes <- 1

num_trees <- 128
ML <- numThreads

algorithm <- "Rborist"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)


if(dataset=="mnist"){
	#####################################################
	#########                MNIST
	#####################################################
	X <- read.csv(file="../../res/mnist.csv", header=FALSE, sep=",")
	Y <- X[, 1]
	X <- X[,-1]

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- Rborist(X,Y, nTree = num_trees)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("MNIST", algorithm,p, ptm_hold)) 
		}
	}
}

if(dataset=="Higgs"){

	####################################################
	##########              HIGGS1
	####################################################
	X <- read.csv(file="../../res/higgsData.csv", header=FALSE, sep=",")
	Y <- X[, 1]
	X <- X[, -1]

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- Rborist(X,Y, nTree = num_trees)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("higgs", algorithm,p, ptm_hold)) 
		}
	}

}


if(dataset=="p53"){
	####################################################
	##########             P53 
	####################################################
	X <- read.csv(file="../../res/p53.csv", header=TRUE, sep=",")
	Y <- X[,nrow(X)]
	X <- X[,-nrow(X)]

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- ranger(X,Y, nTree = num_trees)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("p53", algorithm,p, ptm_hold)) 
		}
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
