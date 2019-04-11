args = commandArgs()
if (length(args)!=6) {
	  stop("one argument must be supplied.")
} else {
nTimes = as.integer(args[6])
}

library(ranger)
library(data.table)

#nTimes <- 2

num_trees <- 96
ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time,time, stringsAsFactors=FALSE)



#####################################################
#########                MNIST
#####################################################
X <- as.matrix(fread(file="../../res/mnist.csv", header=FALSE, sep=","))
X <- X[, c(2:785, 1)]
colnames(X) <- as.character(1:ncol(X))


for (i in 1:nTimes){
	for (p in ML){
		gc()
		ptm <- proc.time()
		forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("MNIST", "Ranger",p, ptm_hold,i)) 
	}
}



####################################################
##########              HIGGS1
####################################################
X <- as.matrix(fread(file="../../res/higgsData.csv", header=FALSE, sep=","))
X <- X[, c(2:32, 1)]
colnames(X) <- as.character(1:ncol(X))

for (i in 1:nTimes){
	for (p in ML){
		gc()
		ptm <- proc.time()
		forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("higgs", "Ranger",p, ptm_hold,i)) 
	}
}

####################################################
##########             P53 
####################################################
X <- as.matrix(fread(file="../../res/p53.csv", header=TRUE, sep=","))
colnames(X) <- as.character(1:ncol(X))

for (i in 1:nTimes){
	for (p in ML){
		gc()
		ptm <- proc.time()
		forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("p53", "Ranger",p, ptm_hold,i)) 
	}
}



resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])
resultData[,5] <- as.numeric(resultData[,5])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
