library(xgboost)


nTimes <- 1
num_trees <- 128
numCores <- 32
ML <- numCores
algName <- "hello"
time <- 0

resultData <- data.frame("MNIST",algName, numCores, time, time, stringsAsFactors=FALSE)




######################################################
##########   MNIST ###################################
X <- read.csv(file="../res/mnist.csv", header=FALSE, sep=",")
Y <- X[,1]
X <- X[, (2:785)]

image_block <- file("../res/t10k-images-idx3-ubyte", "rb")
q <- readBin(image_block, integer(), n=1, endian="big")
num_images <- readBin(image_block, integer(), n=1, endian="big")
num_col <- readBin(image_block, integer(), n=1, endian="big")
num_row <- readBin(image_block, integer(), n=1, endian="big")

#Open and position the label file
label_block = file("../res/t10k-labels-idx1-ubyte", "rb")
q <- readBin(label_block, integer(), n=1, endian="big")
num_labels <- readBin(label_block, integer(), n=1, endian="big")

Xt <- readBin(image_block, integer(), n=num_images*num_col*num_row, size=1, signed=FALSE)
Xt <- matrix(Xt, ncol=num_col*num_row, byrow=TRUE)

Yt <- as.numeric(readBin(label_block, integer(), n=num_labels, size=1, signed=FALSE))

close(image_block)
close(label_block)

gc()
##########################################################
num_classes <- length(unique(Y))
X <- apply(X,2,as.numeric)
ptm_hold <- NA
for (i in 1:nTimes){
	gc()
	forest <- xgboost(data=X, label=Y, objective="multi:softprob", nrounds=num_trees,num_class=num_classes, nthread=32)
	testS <- apply(Xt,2,as.numeric)

	ptm <- proc.time()
	pred <- predict(forest, testS) 
	ptm_hold <- (proc.time() - ptm)[3]

	pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
	pred_labels <- max.col(pred) - 1
	error.rate <- mean(pred_labels == Yt)

	resultData <- rbind(resultData, c("MNIST","XGBoost",96, ptm_hold,error.rate )) 
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
