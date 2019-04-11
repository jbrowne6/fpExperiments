library(rerf)
library(data.table)

nTimes <- 2
num_trees <- 32
numCores <- 32
ML <- 32
p <- 32
algName <- "hello"
time <- 0
sampSize <- 1000000
subSamps <- c(500,2500,5000,7500,10000)
mtries <- 1:5
resultData <- data.frame("MNIST",algName,numCores,time,time,time,time,time, stringsAsFactors=FALSE)





#####################################################
#########                HIGGS
#####################################################
x <- as.matrix(fread(file="../../res/HIGGS.csv", header=FALSE, sep=","))
y <- x[,1,drop=F]
x <- x[, c(2:ncol(x)),drop=F]

for(samples in sampSize){
	for(subSampSize in subSamps){
		for(currMtry in mtries){
			for (i in 1:nTimes){
				train_ind <- sample(seq_len(nrow(x)),size=samples)
				test_ind <- sample(seq_len(nrow(x)),size=100000)

				X <- x[train_ind,,drop=F]
				Y <- y[train_ind]

				Xt <- x[test_ind,,drop=F]
				Yt <- y[test_ind]

				for (algName in c("rfBase","rerf")){
					print(paste("higgs ", samples, " , ", i, " , ", algName))
					gc()

					ptm <- proc.time()
					#forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
					forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,mtry=5*currMtry,numTreesInForest=num_trees,numCores=p,nodeSizeToBin=subSampSize, nodeSizeBin=subSampSize)
					ptm_hold <- (proc.time() - ptm)[3]

					predictions <- fpPredict(forest, Xt)
					error <- sum(predictions == Yt)/length(Yt)

					resultData <- rbind(resultData, c("Higgs 10M",algName,samples,ptm_hold,i,error,subSampSize, currMtry*5)) 

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



#####################################################
#########                HIGGS
#####################################################

for (i in 1:nTimes){
	train_ind <- sample(seq_len(nrow(x)),size=sampSize)
	test_ind <- sample(seq_len(nrow(x)),size=100000)

	X <- x[train_ind,,drop=F]
	Y <- y[train_ind]

	Xt <- x[test_ind,,drop=F]
	Yt <- y[test_ind]

	for (algName in c("rfBase","rerf")){
		print(paste("higgs ", sampsSize, " , ", i, " , ", algName))
		gc()

		ptm <- proc.time()
		#forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
		forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
		ptm_hold <- (proc.time() - ptm)[3]

		predictions <- fpPredict(forest, Xt)
		error <- sum(predictions == Yt)/length(Yt)

		resultData <- rbind(resultData, c("Higgs 10M",algName,sampSize,ptm_hold,i,error,0,5)) 

		resultData <- resultData[2:nrow(resultData),]
		#resultData[,1] <- as.factor(resultData[,1])
		#resultData[,2] <- as.factor(resultData[,2])
		resultData[,3] <- as.numeric(resultData[,3])
		resultData[,4] <- as.numeric(resultData[,4])

		write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)


		resultData <- rbind(resultData, c("Higgs 10M",algName,samples,ptm_hold,i,error,0,max(mtries)*5)) 

		resultData <- resultData[2:nrow(resultData),]
		#resultData[,1] <- as.factor(resultData[,1])
		#resultData[,2] <- as.factor(resultData[,2])
		resultData[,3] <- as.numeric(resultData[,3])
		resultData[,4] <- as.numeric(resultData[,4])

		write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)


		rm(forest)
	}
}




