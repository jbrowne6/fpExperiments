library(rerf)
library(data.table)

nTimes <- 2
num_trees <- 512
numCores <- 16
ML <- 32
algName <- "hello"
#nTree <- c(1,2)
nTree <- c(1,2,4,8,16,32)
time <- 0

resultData <- data.frame("MNIST",algName,numCores,time,time, stringsAsFactors=FALSE)


#for (algName in c("binnedBase","binnedBaseRerF")){
for (algName in c("rfBase","rerf")){
	for (p in ML){
		#####################################################
		#########                MNIST
		#####################################################
		X <- as.matrix(fread(file="../../res/mnist.csv", header=FALSE, sep=","))
		Y <- X[,1]
		X <- X[, (2:785)]


		for (tMult in nTree){
			num_trees <- tMult*numCores
			for (i in 1:nTimes){
				print(paste(algName, " mnist ", tMult, " , ", i, " test4"))
				gc()
				forest <- fpRerF(X =X, Y = Y, forestType=algName,maxDepth=12,minParent=1,numTreesInForest=num_trees,numCores=p)

				ptm <- proc.time()
				predictions <- fpPredict(forest, X)
				ptm_hold <- (proc.time() - ptm)[3]

				resultData <- rbind(resultData, c("MNIST",algName,num_trees,ptm_hold,i)) 

				resultData <- resultData[2:nrow(resultData),]
				#resultData[,1] <- as.factor(resultData[,1])
				#resultData[,2] <- as.factor(resultData[,2])
				resultData[,3] <- as.numeric(resultData[,3])
				resultData[,4] <- as.numeric(resultData[,4])

				write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)

				rm(forest)
			}
		}


		####################################################
		##########              HIGGS1
		####################################################
		X <- as.matrix(fread(file="../../res/higgsData.csv", header=FALSE, sep=","))
		Y <- as.integer(X[,1]-1)
		X <- X[, c(2:32)]


		for (tMult in nTree){
			num_trees <- tMult*numCores
			for (i in 1:nTimes){

				print(paste(algName, " higgs ", tMult, " , ", i, " test4"))
				for (p in ML){
					gc()
					forest <- fpRerF(X =X, Y = Y, forestType=algName,maxDepth=12,minParent=1,numCores=p,numTreesInForest=num_trees)

					ptm <- proc.time()
					predictions <- fpPredict(forest, X)
					ptm_hold <- (proc.time() - ptm)[3]


					resultData <- rbind(resultData, c("higgs", algName,num_trees, ptm_hold,i)) 

					resultData <- resultData[2:nrow(resultData),]
					#resultData[,1] <- as.factor(resultData[,1])
					#resultData[,2] <- as.factor(resultData[,2])
					resultData[,3] <- as.numeric(resultData[,3])
					resultData[,4] <- as.numeric(resultData[,4])

					write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
					rm(forest)
				}
			}
		}

		####################################################
		##########             P53 
		####################################################
		X <- as.matrix(fread(file="../../res/p53.csv", header=TRUE, sep=","))
		Y <- as.integer(X[,ncol(X)]-1)
		X <- as.matrix(X[,1:(ncol(X)-1)])

		for (tMult in nTree){
			num_trees <- tMult*numCores
			for (i in 1:nTimes){
				print(paste(algName, " p53 ", tMult, " , ", i, " test4"))
				for (p in ML){
					gc()
					forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,maxDepth=12,numCores=p,numTreesInForest=num_trees)

					ptm <- proc.time()
					predictions <- fpPredict(forest, X)
					ptm_hold <- (proc.time() - ptm)[3]

					resultData <- rbind(resultData, c("p53", algName,num_trees, ptm_hold,i))  

					resultData <- resultData[2:nrow(resultData),]
					#resultData[,1] <- as.factor(resultData[,1])
					#resultData[,2] <- as.factor(resultData[,2])
					resultData[,3] <- as.numeric(resultData[,3])
					resultData[,4] <- as.numeric(resultData[,4])

					write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
					rm(forest)
				}
			}
		}

	}
}


