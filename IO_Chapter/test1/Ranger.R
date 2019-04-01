library(ranger)

nTimes <- 10
num_trees <- 64
numCores <- 32
ML <- numCores
algName <- "hello"
time <- 0

resultData <- data.frame("MNIST",algName, numCores, time, time, stringsAsFactors=FALSE)


#####################################################
#########                MNIST
#####################################################
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


X <- cbind(X,Y)
colnames(X) <- as.character(1:ncol(X))
colnames(Xt) <- as.character(1:ncol(Xt))

ptm_hold <- NA
for (i in 1:nTimes){
	gc()
	forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = 32, classification=TRUE)
	for(j in c(32)){
	ptm <- proc.time()
	pred <- predict(forest,Xt, num.threads=j)
	ptm_hold <- (proc.time() - ptm)[3]
	error <- mean(pred$predictions == Yt)

	resultData <- rbind(resultData, c("MNIST","Ranger",j, ptm_hold,error )) 
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
