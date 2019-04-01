library(xgboost)

nTimes <- 1

num_trees <- 96 
#ML <- c(32,48)
ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)



#####################################################
#########                MNIST
#####################################################
X <- as.matrix(read.csv(file="../../res/mnist.csv", header=FALSE, sep=","))
Y <- X[,1]
X <- X[, (2:785)]
num_classes <- length(unique(Y))


for (p in ML){
	for (i in 1:nTimes){
print(paste("XGBoost run ", i, " with ", p, " cores."))
		gc()
		ptm <- proc.time()
		forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("MNIST", "XGBoost",p, ptm_hold)) 
			}
}



####################################################
##########              HIGGS1
####################################################
X <- as.matrix(read.csv(file="../../res/higgsData.csv", header=FALSE, sep=","))
Y <- X[,1]-1
X <- X[, c(2:32)]
num_classes <- length(unique(Y))

for (p in ML){
	for (i in 1:nTimes){
		print(paste("XGBoost run ", i, " with ", p, " cores."))
		gc()
		ptm <- proc.time()
		forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("higgs", "XGBoost",p, ptm_hold)) 
	}
}


####################################################
##########             P53 
####################################################
X <- as.matrix(read.csv(file="../../res/p53.csv", header=TRUE, sep=","))
Y <- X[,ncol(X)]-1
X <- X[,1:(ncol(X)-1)]
num_classes <- length(unique(Y))

for (p in ML){
	for (i in 1:nTimes){
print(paste("XGBoost run ", i, " with ", p, " cores."))
		gc()
		ptm <- proc.time()
		forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("p53", "XGBoost",p, ptm_hold)) 
	}
}



resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
