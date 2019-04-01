library(rerf)

nTimes <- 1

num_trees <- 64 
#ML <- c(32,48)
ML <- c(32)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0
maxPercent <- .95
#binSizePercent <- c(seq(.05,maxPercent,.05),1)
binSizePercent <- c(seq(.70,maxPercent,.05))
binSizePercent <- .005

resultData <- data.frame(as.character(dataset), algorithm, numCores, time,time, stringsAsFactors=FALSE)

##############################
#########  Now test with binning
#############################
for(algName in c("rerf")){

	#####################################################
	#########                MNIST
	#####################################################
	X <- read.csv(file="../../res/mnist.csv", header=FALSE, sep=",")
	Y <- X[,1]
	X <- X[, (2:785)]

	image_block <- file("../../res/t10k-images-idx3-ubyte", "rb")
	q <- readBin(image_block, integer(), n=1, endian="big")
	num_images <- readBin(image_block, integer(), n=1, endian="big")
	num_col <- readBin(image_block, integer(), n=1, endian="big")
	num_row <- readBin(image_block, integer(), n=1, endian="big")

	#Open and position the label file
	label_block = file("../../res/t10k-labels-idx1-ubyte", "rb")
	q <- readBin(label_block, integer(), n=1, endian="big")
	num_labels <- readBin(label_block, integer(), n=1, endian="big")

	Xt <- readBin(image_block, integer(), n=num_images*num_col*num_row, size=1, signed=FALSE)
	Xt <- matrix(Xt, ncol=num_col*num_row, byrow=TRUE)

	Yt <- as.numeric(readBin(label_block, integer(), n=num_labels, size=1, signed=FALSE))

	close(image_block)
	close(label_block)




	for (p in ML){
		for(j in binSizePercent){
			binSize <- j*nrow(X)
			for (i in 1:nTimes){
				gc()
				ptm <- proc.time()

				#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
				forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees,nodeSizeToBin=binSize, nodeSizeBin=binSize)
				ptm_hold <- (proc.time() - ptm)[3]

				predictions <- fpPredict(forest, Xt)
				error <- sum(predictions==Yt)/length(Yt)

				resultData <- rbind(resultData, c("MNIST", "fastRerF(Bin)",j, ptm_hold,error)) 
				rm(forest)
			}
		}
	}



	####################################################
	##########              HIGGS1
	####################################################
	x <- read.csv(file="../../res/higgsData.csv", header=FALSE, sep=",")
	y <- as.integer(x[,1]-1)
	x <- x[, c(2:32)]
smp_size <- floor(0.80*nrow(x))

	for (p in ML){
		for(j in binSizePercent){
			binSize <- j*nrow(x)
			for (i in 1:nTimes){
				train_ind <- sample(seq_len(nrow(x)),size=smp_size)

				X <- x[train_ind,]
				Y <- y[train_ind]

				Xt <- x[-train_ind,]
				Yt <- y[-train_ind]

				gc()
				ptm <- proc.time()
				forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees,nodeSizeToBin=binSize, nodeSizeBin=binSize)
				#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
				predictions <- fpPredict(forest, Xt)
				error <- sum(predictions==Yt)/length(Yt)

				ptm_hold <- (proc.time() - ptm)[3]
				resultData <- rbind(resultData, c("higgs", "fastRerF(Bin)",j, ptm_hold,error)) 
				rm(forest)
			}
		}
	}

	####################################################
	##########             P53 
	####################################################
	x <- read.csv(file="../../res/p53.csv", header=TRUE, sep=",")
	y <- as.integer(x[,ncol(x)]-1)
	x <- as.matrix(x[,1:(ncol(x)-1)])

smp_size <- floor(0.80*nrow(x))
	for (p in ML){
		for(j in binSizePercent){
			binSize <- j*nrow(x)
			for (i in 1:nTimes){
				train_ind <- sample(seq_len(nrow(x)),size=smp_size)

				X <- x[train_ind,]
				Y <- y[train_ind]

				Xt <- x[-train_ind,]
				Yt <- y[-train_ind]


				gc()
				ptm <- proc.time()
				forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees,nodeSizeToBin=binSize, nodeSizeBin=binSize)
				predictions <- fpPredict(forest, Xt)
				error <- sum(predictions==Yt)/length(Yt)
				ptm_hold <- (proc.time() - ptm)[3]
				resultData <- rbind(resultData, c("p53", "fastRerF(Bin)",j, ptm_hold,error))  
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

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
