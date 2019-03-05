args = commandArgs()
if (length(args)!=7) {
	stop("At least two arguments must be supplied.")
} else {
	dataset = args[6]
	numCores = as.integer(args[7])
}



library(rerf)

nTimes <- 1

num_trees <- 128
ML <- numCores

algorithm <- "temp"
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)



if(dataset == "mnist"){
	#####################################################
	#########                MNIST
	#####################################################
	X <- as.matrix(read.csv(file="../res/mnist.csv", header=FALSE, sep=","))
	Y <- X[,1]
	X <- X[, (2:785)]


	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=FALSE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("MNIST", "R-RerF",p, ptm_hold)) 
		}
	}
}


if(dataset == "Higgs"){
	####################################################
	##########              HIGGS1
	####################################################
	X <- as.matrix(read.csv(file="../res/higgsData.csv", header=FALSE, sep=","))
	Y <- X[,1]
	X <- X[, c(2:32)]

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=FALSE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("higgs", "R-RerF",p, ptm_hold)) 
		}
	}
}


if(dataset == "p53"){
	####################################################
	##########             P53 
	####################################################
	X <- as.matrix(read.csv(file="../res/p53.csv", header=TRUE, sep=","))
	Y <- as.numeric(X[,ncol(X)])
	X <- X[,1:(ncol(X)-1)]

	for (p in ML){
		for (i in 1:nTimes){
			gc()
			ptm <- proc.time()
			forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=FALSE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			ptm_hold <- (proc.time() - ptm)[3]
			resultData <- rbind(resultData, c("p53", "R-RerF",p, ptm_hold))  
		}
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
