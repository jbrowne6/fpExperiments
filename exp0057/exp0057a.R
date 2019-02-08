nTimes <- 10

num_trees <- 10
ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)



#Size of the labels is 1 whereas everything else is 4
#Open and position the image file
image_block <- file("../../data/ubyte/train-images-idx3-ubyte", "rb")
q <- readBin(image_block, integer(), n=1, endian="big")
num_images <- readBin(image_block, integer(), n=1, endian="big")
num_col <- readBin(image_block, integer(), n=1, endian="big")
num_row <- readBin(image_block, integer(), n=1, endian="big")

#Open and position the label file
label_block = file("../../data/ubyte/train-labels-idx1-ubyte", "rb")
q <- readBin(label_block, integer(), n=1, endian="big")
num_labels <- readBin(label_block, integer(), n=1, endian="big")

X <- readBin(image_block, integer(), n=num_images*num_col*num_row, size=1, signed=FALSE)
X <- matrix(X, ncol=num_col*num_row, byrow=TRUE)

Y <- as.numeric(readBin(label_block, integer(), n=num_labels, size=1, signed=FALSE)+1)

close(image_block)
close(label_block)
gc()
data_size_curr <- (object.size(X)+object.size(Y))/1000000


#Run Rerf on Dataset
library(rerf)
for (p in ML){
	for (i in 1:nTimes){
		gc()
		ptm <- proc.time()
		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
		ptm_hold <- (proc.time() - ptm)[3]

		resultData <- rbind(resultData, c("MNIST", "RerF",p, ptm_hold)) 
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
		resultData <- rbind(resultData, c("MNIST", "XGBoost",p, ptm_hold)) 
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
		resultData <- rbind(resultData, c("MNIST", "Ranger",p, ptm_hold)) 
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="exp0057.csv", col.names=FALSE, row.names=FALSE, append=FALSE, sep=",", quote=FALSE)
