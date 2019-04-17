library(rerf)

nTimes <- 3
trees <- c(64,128,256,512,1024)
ML <- c(16)


numCores <- 0
time <- 0

resultData <- data.frame("MNIST","binnedBaseRerF", numCores,time,time,time, stringsAsFactors=FALSE)


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



for (i in 1:nTimes){
	for (p in ML){
		for(num_trees in trees){
			for (alg in c("binnedBase","rfBase")){
				gc()
				ptm <- proc.time()
				forest <- fpRerF(X =X, Y = Y, forestType=alg,minParent=1,numTreesInForest=num_trees,numCores=p)
				ptm_hold <- (proc.time() - ptm)[3]

				ptm <- proc.time()
				predictions <- fpPredict(forest, Xt)
				error <- sum(predictions==Yt)/length(Yt)
				ptm_hold_error <- (proc.time() - ptm)[3]

				resultData <- rbind(resultData, c("MNIST",alg,num_trees,ptm_hold,ptm_hold_error,i)) 
				resultData <- resultData[2:nrow(resultData),]

				write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
				rm(forest)
			}
		}
	}
}


####################################################
##########              HIGGS1
####################################################
X <- as.matrix(fread(file="../../res/higgsData.csv", header=FALSE, sep=","))
Y <- as.integer(X[,1]-1)
X <- X[, c(2:32)]

for (i in 1:nTimes){
	for (p in ML){
		for(num_trees in trees){
			for (algName in c("binnedBase","rfBase")){
				gc()
				ptm <- proc.time()
				forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees)
				#		forest <- RerF(X,Y, trees=num_trees, bagging=.3, min.parent=1, max.depth=0, store.oob=TRUE, stratify=TRUE, num.cores=p, seed=sample(1:100000,1))
				ptm_hold <- (proc.time() - ptm)[3]

				predictions <- fpPredict(forest, X)
				error <- sum(predictions==Y)/length(Y)
				ptm_hold_error <- (proc.time() - ptm)[3]



				resultData <- rbind(resultData, c("higgs", algName,num_trees, ptm_hold,ptm_hold_error,,i)) 

				resultData <- resultData[2:nrow(resultData),]

				write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
				rm(forest)


				rm(forest)
			}
		}
	}
}
####################################################
##########             P53 
####################################################
X <- as.matrix(fread(file="../../res/p53.csv", header=TRUE, sep=","))
Y <- as.integer(X[,ncol(X)]-1)
X <- as.matrix(X[,1:(ncol(X)-1)])

for (i in 1:nTimes){
	for (p in ML){
		for(num_trees in trees){
			for (algName in c("binnedBase","rfBase")){
				gc()
				ptm <- proc.time()
				forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numCores=p,numTreesInForest=num_trees)
				ptm_hold <- (proc.time() - ptm)[3]
				resultData <- rbind(resultData, c("p53", algName,num_trees, ptm_hold,ptm_hold_error,,i))  

				predictions <- fpPredict(forest, X)
				error <- sum(predictions==Y)/length(Y)
				ptm_hold_error <- (proc.time() - ptm)[3]

				resultData <- resultData[2:nrow(resultData),]

				write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
				rm(forest)


				rm(forest)
			}
		}
	}
}

