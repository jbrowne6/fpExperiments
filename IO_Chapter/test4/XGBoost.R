library(xgboost)
library(data.table)


nTimes <- 1
num_trees <- 512
numCores <- 32
ML <- numCores
algName <- "hello"
time <- 0

resultData <- data.frame("MNIST",algName, numCores, time, time, stringsAsFactors=FALSE)


#####################################################
#########                MNIST
#####################################################
X <- as.matrix(fread(file="../../res/mnist.csv", header=FALSE, sep=","))
Y <- X[,1]
X <- X[, (2:785)]
num_classes <- length(unique(Y))


for (i in 1:nTimes){
	for (p in ML){
		print(paste("XGBoost run ", i, " with ", p, " cores."))
		gc()
		forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)

		ptm <- proc.time()
		pred <- predict(forest, X) 
		pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
		pred_labels <- max.col(pred) - 1
		ptm_hold <- (proc.time() - ptm)[3]

		resultData <- rbind(resultData, c("MNIST", "XGBoost",p, ptm_hold,i)) 
	}
}



####################################################
##########              HIGGS1
####################################################
X <- as.matrix(fread(file="../../res/higgsData.csv", header=FALSE, sep=","))
Y <- X[,1]-1
X <- X[, c(2:32)]
num_classes <- length(unique(Y))

for (i in 1:nTimes){
	for (p in ML){
		print(paste("XGBoost run ", i, " with ", p, " cores."))
		gc()
		forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)

		ptm <- proc.time()
		pred <- predict(forest, X) 
		pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
		pred_labels <- max.col(pred) - 1
		ptm_hold <- (proc.time() - ptm)[3]

		resultData <- rbind(resultData, c("higgs", "XGBoost",p, ptm_hold,i)) 
	}
}


####################################################
##########             P53 
####################################################
X <- as.matrix(fread(file="../../res/p53.csv", header=TRUE, sep=","))
Y <- X[,ncol(X)]-1
X <- X[,1:(ncol(X)-1)]
num_classes <- length(unique(Y))

for (i in 1:nTimes){
	for (p in ML){
		print(paste("XGBoost run ", i, " with ", p, " cores."))
		gc()
		forest <- xgboost(data=X, label=Y, objective="multi:softprob",nrounds=num_trees,colsample_bynode=sqrt(nrow(X))/nrow(X), num_class=num_classes, nthread=p)

		ptm <- proc.time()
		pred <- predict(forest, X) 
		pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
		pred_labels <- max.col(pred) - 1
		ptm_hold <- (proc.time() - ptm)[3]

		resultData <- rbind(resultData, c("p53", "XGBoost",p, ptm_hold,i)) 
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)