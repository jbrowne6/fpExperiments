library(rerf)
library(data.table)

nTimes <- 2
num_trees <- 32
numCores <- 32
ML <- 32
p <- 32
algName <- "hello"
time <- 0
sampSize <- c(500000,1000000,1500000,2000000,2500000,3000000)

resultData <- data.frame("MNIST",algName,numCores,time,time,time, stringsAsFactors=FALSE)



#####################################################
#########                airine
#####################################################
x <- as.matrix(fread(file="../../res/airline_14col.csv.new", header=FALSE, sep=","))
y <- x[,14]
x <- x[, c(1:13)]
#x <- as.matrix(iris[,1:4])
#y <- as.numeric(iris[,5])-1

for(samples in sampSize){
	for (i in 1:nTimes){
		train_ind <- sort(sample(seq_len(nrow(x)),replace=FALSE,size=samples))
		test_ind <- sample(seq_len(nrow(x)),replace=FALSE,size=100000)


		X <- x[train_ind,,drop=F]
		Y <- as.numeric(y[train_ind])

		Xt <- x[test_ind,,drop=F]
		Yt <- y[test_ind]
		#Xt <- x[-train_ind,]
		#Yt <- y[-train_ind]

		for (algName in c("rfBase","rerf")){
			print(paste("airline ", samples, " , ", i, " , ", algName))
			gc()
			ptm <- proc.time()
			#forest <- fpRerF(X=X, Y=Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p)
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p,nodeSizeToBin=5000, nodeSizeBin=5000)
			ptm_hold <- (proc.time() - ptm)[3]

			predictions <- fpPredict(forest, Xt)
			error <- sum(predictions == Yt)/length(Yt)

			resultData <- rbind(resultData, c("airline",algName,samples,ptm_hold,i,error)) 

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



#####################################################
#########                HIGGS
#####################################################
x <- as.matrix(fread(file="../../res/HIGGS.csv", header=FALSE, sep=","))
y <- x[,1,drop=F]
x <- x[, c(2:ncol(x)),drop=F]

for(samples in sampSize){
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
			forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=num_trees,numCores=p,nodeSizeToBin=5000, nodeSizeBin=5000)
			ptm_hold <- (proc.time() - ptm)[3]

			predictions <- fpPredict(forest, Xt)
			error <- sum(predictions == Yt)/length(Yt)

			resultData <- rbind(resultData, c("Higgs 10M",algName,samples,ptm_hold,i,error)) 

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





