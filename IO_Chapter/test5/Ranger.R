args = commandArgs()
if (length(args)!=12) {
	stop("At least two arguments must be supplied.")
} else {
	dataset = args[6]
	numThreads = as.integer(args[7])
nTimes = as.integer(args[8])
nClass = as.integer(args[9])
nSamples = as.integer(args[10])
nfeats = as.integer(args[11])
testName = as.character(args[12])
}

library(ranger)
library(data.table)

nTimes <- 1

num_trees <- 128
ML <- numThreads

algorithm <- "Ranger"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time,time,time,time,time, stringsAsFactors=FALSE)


if(dataset=="mnist"){
	#####################################################
	#########                MNIST
	#####################################################
	X <- read.csv(file="../res/mnist.csv", header=FALSE, sep=",")
	X <- X[, c(2:785, 1)]
	colnames(X) <- as.character(1:ncol(X))


	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("MNIST", "Ranger",p, ptm_hold)) 
		}
	}
}

if(dataset=="Higgs"){

	####################################################
	##########              HIGGS1
	####################################################
	X <- read.csv(file="../res/higgsData.csv", header=FALSE, sep=",")
	X <- X[, c(2:32, 1)]
	colnames(X) <- as.character(1:ncol(X))

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("higgs", "Ranger",p, ptm_hold)) 
		}
	}

}


if(dataset=="p53"){
	####################################################
	##########             P53 
	####################################################
	X <- read.csv(file="../res/p53.csv", header=TRUE, sep=",")
	colnames(X) <- as.character(1:ncol(X))

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("p53", "Ranger",p, ptm_hold)) 
		}
	}
}


if(dataset == "svhn"){
	####################################################
	##########             svhn 
	####################################################
	X <- as.matrix(fread(file="temp_data.csv", header=FALSE, sep=","))
	Y <- fread(file="temp_label.csv", header=FALSE, sep=",")$V1
if(min(Y) != 0){
    Y <- Y -1
  }
  if(min(Y) != 0){
    stop("dataset does not contain 0, fastRF")
  }
	X <- cbind(X,Y)
	colnames(X) <- as.character(1:ncol(X))
	rm(Y)

	gc()
	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c(dataset,"Ranger",testName,p, ptm_hold,nClass,nSamples,nfeats,i))
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
