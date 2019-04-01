library(rerf)
library(data.table)

nTimes <- 1

num_trees <- 1 
#ML <- c(32,48)
ML <- c(1)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0
maxPercent <- .95
binSizePercent <- c(seq(.05,maxPercent,.05),1)
binSizePercent <- .00005

resultData <- data.frame(as.character(dataset), algorithm, numCores, time,time, stringsAsFactors=FALSE)

##############################
#########  Now test with binning
#############################
for(algName in c("rfBase")){

	####################################################
	##########              HIGGS1
	####################################################
	x <- as.matrix(fread(file="../../res/HIGGS.csv", header=FALSE, sep=","))
	y <- as.integer(x[,1])
	x <- as.matrix(x[, -1])
smp_size <- floor(0.80*nrow(x))
				gc()
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
				resultData <- rbind(resultData, c("higgs 10M", "fastRF(Bin)",j, ptm_hold,error)) 
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
