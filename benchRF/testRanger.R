library(ranger)

nTimes <- 10

num_trees <- 10
ML <- c(1)
#ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)



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



resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
