library(rerf)

nTimes <- 1
num_trees <- 128
ML <- c(1,2,4,8,16,32,64)


numCores <- 0
time <- 0

resultData <- data.frame("MNIST","binnedBaseRerF", numCores, time,time,time,time, stringsAsFactors=FALSE)


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



#for (alg in c("rerf", "rfBase")){
for (alg in c( "rfBase")){
	for (p in ML){
		for (binSize in c(0,300,3000,30000)){
			for (i in 1:nTimes){
				gc()
				ptm <- proc.time()
				#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
				forest <- fpRerF(X =X, Y = Y, forestType=alg,minParent=1,numTreesInForest=num_trees,numCores=p,nodeSizeToBin=binSize, nodeSizeBin=binSize )
				ptm_hold <- (proc.time() - ptm)[3]

				predictions <- fpPredict(forest, Xt)
				error <- sum(predictions==Yt)/length(Yt)

				resultData <- rbind(resultData, c("MNIST", alg,p, ptm_hold,error, binSize,binSize)) 

				forest$printParameters()
				rm(forest)
			}
		}
	}
}

resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="coreGrow.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
