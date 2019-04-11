library(lightgbm)
library(data.table)

nTimes <- 2
num_trees <- 32
numCores <- 32
ML <- 32
p <- 32
algName <- "LightGBM"
time <- 0
sampSize <- c(500000,1000000,1500000,2000000,2500000,3000000)

resultData <- data.frame("MNIST",algName,numCores,time,time,time, stringsAsFactors=FALSE)




#####################################################
#########                HIGGS
#####################################################
x <- as.matrix(fread(file="../../res/HIGGS.csv", header=FALSE, sep=","))
y <- x[,1]
x <- x[, c(2:ncol(x))]
num_classes <- length(unique(y))

for(samples in sampSize){
	for (i in 1:nTimes){
		print(paste("higgs ", samples, " , ", i, " , LightGBM "))
		train_ind <- sort(sample(seq_len(nrow(x)),size=samples))
		test_ind <- sort(sample(seq_len(nrow(x)),size=100000))

		X <- x[train_ind,]
		Y <- y[train_ind]

		Xt <- x[test_ind,]
		Yt <- y[test_ind]

		dtrain <- lgb.Dataset(data=X,label=Y)
		gc()

		ptm <- proc.time()
		forest <- lgb.train(data=dtrain, objective="multiclass",num_class=num_classes,learning_rate=.1,nrounds=num_trees, nthread=p,early_stopping_rounds=0, num_leaves= 2^(10))
		ptm_hold <- (proc.time() - ptm)[3]

		pred <- predict(forest, Xt, reshape=TRUE) 
		pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
		pred_labels <- max.col(pred) - 1
		error <- sum(pred_labels == Yt)/length(Yt)

		resultData <- rbind(resultData, c("Higgs 10M",algName,samples,ptm_hold,i,error)) 


		resultData <- resultData[2:nrow(resultData),]
	#	resultData[,1] <- as.factor(resultData[,1])
	#	resultData[,2] <- as.factor(resultData[,2])
		resultData[,3] <- as.numeric(resultData[,3])
		resultData[,4] <- as.numeric(resultData[,4])
		resultData[,4] <- as.numeric(resultData[,4])

		write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
		rm(forest)
	}
}





#####################################################
#########                airine
#####################################################
x <- as.matrix(fread(file="../../res/airline_14col.csv.new", header=FALSE, sep=","))
y <- x[,14]
x <- x[,c(1:13)]
num_classes <- length(unique(y))


for(samples in sampSize){
	for (i in 1:nTimes){
		print(paste("airline ", samples, " , ", i, " , LightGBM "))
		train_ind <- sample(seq_len(nrow(x)),size=samples)
		test_ind <- sample(seq_len(nrow(x)),size=100000)

		X <- x[train_ind,]
		Y <- y[train_ind]

		Xt <- x[test_ind,]
		Yt <- y[test_ind]

		dtrain <- lgb.Dataset(data=X,label=Y)
		gc()

		ptm <- proc.time()
		forest <- lgb.train(data=dtrain, objective="multiclass",num_class=num_classes,learning_rate=.1,nrounds=num_trees, nthread=p,early_stopping_rounds=0, num_leaves= 2^(10))
		ptm_hold <- (proc.time() - ptm)[3]

		pred <- predict(forest, Xt, reshape=TRUE) 
		pred <- matrix(pred, ncol=num_classes, byrow=TRUE) 
		pred_labels <- max.col(pred) - 1
		error <- sum(pred_labels == Yt)/length(Yt)

		resultData <- rbind(resultData, c("airline",algName,samples,ptm_hold,i,error)) 


		resultData <- resultData[2:nrow(resultData),]
	#	resultData[,1] <- as.factor(resultData[,1])
	#	resultData[,2] <- as.factor(resultData[,2])
		resultData[,3] <- as.numeric(resultData[,3])
		resultData[,4] <- as.numeric(resultData[,4])
		resultData[,4] <- as.numeric(resultData[,4])

		write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
		rm(forest)
	}
}


