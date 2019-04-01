library(rerf)

nTimes <- 10
num_trees <- 64
numCores <- 32
ML <- numCores
algName <- "hello"
time <- 0

set.seed(130)
resultData <- data.frame("MNIST",algName, numCores, time, time, stringsAsFactors=FALSE)


library(slb)
data <- slb.load.datasets(repositories="uci", task="classification")

datasets <- c("iris","breast_cancer", "chess_krvk")

for(datasetName in datasets){
	x <- data[[datasetName]]$X
	y <- as.numeric(data[[datasetName]]$Y)
	if(min(unique(y)) != 0){
		y <- y -1
	}
	if(min(unique(y)) != 0){
		stop("not all Y values are represented")
	}

	smp_size <- floor(0.80*nrow(x))

	for (algName in c("rfBase")){
		for (p in 10){
			for(j in c(5,10,25,50,100)){
				for (i in 1:nTimes){
					gc()
					train_ind <- sample(seq_len(nrow(x)),size=smp_size)

					X <- x[train_ind,]
					Y <- y[train_ind]

					Xt <- x[-train_ind,]
					Yt <- y[-train_ind]
					forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=j,numCores=p)

					ptm <- proc.time()
					predictions <- fpPredict(forest, Xt)
					ptm_hold <- (proc.time() - ptm)[3]

					error <- sum(predictions==Yt)/length(Yt)

					resultData <- rbind(resultData, c(datasetName,"fastRF",j, ptm_hold,error )) 

					forest$printParameters()
					rm(forest)
				}
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
