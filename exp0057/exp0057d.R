nTimes <- 1

num_trees <- 10
ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)

mydata <- read.csv(file="~/gitrepos/packedForest/res/HIGGS.csv", header=FALSE, sep=",")
#mydata <- read.csv(file="~/gitrepos/packedForest/res/higgs2.csv", header=FALSE, sep=",")
X <- as.matrix(mydata[,2:ncol(mydata)])
Y <- as.numeric(mydata[,1])
mydata <- NA


#Run Rerf on Dataset
library(rerf)
for (p in ML){
	for (i in 1:nTimes){
		print(paste("RerF run ", i, " with ", p, " cores."))
		gc()
		ptm <- proc.time()
		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
		ptm_hold <- (proc.time() - ptm)[3]

		resultData <- rbind(resultData, c("HIGGS", "RerF",p, ptm_hold)) 
	}
}



#create impossible dataset
num_classes <- length(unique(Y))
train <- apply(X,2,as.numeric)
label <- Y
for (p in ML){
	for (i in 1:nTimes){
		print(paste("XGBoost run ", i, " with ", p, " cores."))
		gc()
		ptm <- proc.time()
		forest <- xgboost(data=train, label=label, objective="multi:softprob",nrounds=num_trees, num_class=num_classes, nthread=p)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("HIGGS", "XGBoost",p, ptm_hold)) 
	}
}



library(ranger)
X <- cbind(X,Y)
colnames(X) <- as.character(1:ncol(X))
for (p in ML){
	for (i in 1:nTimes){
		print(paste("Ranger run ", i, " with ", p, " cores."))
		gc()
		ptm <- proc.time()
		forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("HIGGS", "Ranger",p, ptm_hold)) 
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="exp0057.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
