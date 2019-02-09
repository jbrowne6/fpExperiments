library(rerf)

nTimes <- 10
num_trees <- 128
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



for (algName in c("rfBase","rerf")){
	for (p in 32){
		for (i in 1:nTimes){
			gc()
			#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)

			ptm <- proc.time()
			predictions <- fpPredict(forest, Xt)
			ptm_hold <- (proc.time() - ptm)[3]

			error <- sum(predictions==Yt)/length(Yt)

			resultData <- rbind(resultData, c("MNIST",algName,p, ptm_hold,error )) 

			forest$printParameters()
			rm(forest)
		}
	}
}




resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
