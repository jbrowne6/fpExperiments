nTimes <- 10

num_trees <- 10
ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)


mydata <- read.csv(file="../../data/p53.csv", header=TRUE, sep=",")
X <- as.matrix(mydata[,1:(ncol(mydata)-1)])
Y <- as.numeric(mydata[,ncol(mydata)])
mydata <- NA


#Run Rerf on Dataset
library(rerf)
for (p in ML){
	for (i in 1:nTimes){
		gc()
		ptm <- proc.time()
		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
		ptm_hold <- (proc.time() - ptm)[3]

		resultData <- rbind(resultData, c("p53", "RerF",p, ptm_hold)) 
	}
}



#create impossible dataset
library(xgboost)
num_classes <- length(unique(Y))
train <- apply(X,2,as.numeric)
label <- Y-1
for (p in ML){
	for (i in 1:nTimes){
		gc()
		ptm <- proc.time()
		forest <- xgboost(data=train, label=label, objective="multi:softprob",nrounds=num_trees, num_class=num_classes, nthread=p)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("p53", "XGBoost",p, ptm_hold)) 
	}
}



library(ranger)
X <- cbind(X,Y)
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

write.table(resultData, file="exp0057.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
