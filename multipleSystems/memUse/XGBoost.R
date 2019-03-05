args = commandArgs()
if (length(args)!=7) {
	stop("At least two arguments must be supplied.")
} else {
	dataset = args[6]
	numThreads = as.integer(args[7])
}

library(xgboost)

nTimes <- 1

num_trees <- 128
ML <- numThreads

algorithm <- "Ranger"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)


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
			forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees, num_class=num_classes, nthread=p)
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
			forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees, num_class=num_classes, nthread=p)
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
			forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees, num_class=num_classes, nthread=p)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("p53", "XGBoost",p, ptm_hold)) 
		}
	}


}

resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
