library(rerf)
library(randomForest)

nTimes <- 10
num_trees <- 64
numCores <- 32
ML <- numCores
algName <- "hello"
time <- 0

set.seed(130)
resultData <- data.frame("MNIST", numCores, time,time, stringsAsFactors=FALSE)


library(slb)
data <- slb.load.datasets(repositories="uci", task="classification")

datasets <- c("iris","breast_cancer", "chess_krvk")

for(datasetName in datasets){
	x <- data[[datasetName]]$X
	y <- as.numeric(data[[datasetName]]$Y)
					yb <- as.factor(data[[datasetName]]$Y)
	if(min(unique(y)) != 0){
		y <- y -1
	}
	if(min(unique(y)) != 0){
		stop("not all Y values are represented")
	}

	smp_size <- floor(0.80*nrow(x))

	for (algName in c("rfBase")){
		for (p in 10){
				for (i in 1:nTimes){
			for(j in c(100,200,300,400,500)){
					gc()
					train_ind <- sample(seq_len(nrow(x)),size=smp_size)

					X <- x[train_ind,]
					Y <- y[train_ind]

					Xt <- x[-train_ind,]
					Yt <- y[-train_ind]
					forest <- fpRerF(X =X, Y = Y, forestType=algName,minParent=1,numTreesInForest=j,numCores=p)

					predictions <- fpPredict(forest, Xt)


					X <- x[train_ind,]
					Y <- yb[train_ind]

					Xt <- x[-train_ind,]
					Yt <- yb[-train_ind]
					rm(forest)
					forest <- randomForest(x=X, y=Y, nodesize=1,ntree=j)

					predictionsB <- predict(forest, Xt)

					error <- sum(predictionsB==predictions)/length(Yt)

					resultData <- rbind(resultData, c(datasetName,i,j,error )) 

					rm(forest)
				}
			}
		}
	}
}


resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.numeric(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
