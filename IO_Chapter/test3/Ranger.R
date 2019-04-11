library(ranger)
library(data.table)

nTimes <- 2
num_trees <- 32
numCores <- 32
ML <- 32
p <- 32
algName <- "Ranger"
time <- 0
sampSize <- c(500000,1000000,1500000,2000000,2500000,3000000)

resultData <- data.frame("MNIST",algName,numCores,time,time,time, stringsAsFactors=FALSE)



#####################################################
#########                airine
#####################################################
x <- as.matrix(fread(file="../../res/airline_14col.csv.new", header=FALSE, sep=","))
y <- x[,ncol(x)]
colnames(x) <- as.character(1:ncol(x))


for(samples in sampSize){
	for (i in 1:nTimes){
		print(paste("airline ", samples, " , ", i, " , Ranger"))
		train_ind <- sort(sample(seq_len(nrow(x)),size=samples))
		test_ind <- sort(sample(seq_len(nrow(x)),size=100000))

		X <- x[train_ind,]

		Xt <- x[test_ind,c(1:(ncol(x)-1))]
		Yt <- y[test_ind]


		gc()

		ptm <- proc.time()
		forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
		ptm_hold <- (proc.time() - ptm)[3]

		predictions <- predict(forest, Xt)
		error <- sum(predictions$predictions == Yt)/length(Yt)

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



#####################################################
#########               HIGGS 
#####################################################
x <- as.matrix(fread(file="../../res/HIGGS.csv", header=FALSE, sep=","))
y <- x[,1]
x <- x[, c(2:ncol(x), 1)]
colnames(x) <- as.character(1:ncol(x))


for(samples in sampSize){
	for (i in 1:nTimes){
		print(paste("higgs ", samples, " , ", i, " , Ranger "))
		train_ind <- sort(sample(seq_len(nrow(x)),size=samples))
		test_ind <- sort(sample(seq_len(nrow(x)),size=100000))

		X <- x[train_ind,]

		Xt <- x[test_ind,c(1:(ncol(x)-1))]
		Yt <- y[test_ind]

		gc()

		ptm <- proc.time()
		forest <- ranger(dependent.variable.name = as.character(ncol(X)), data = X, num.trees = num_trees, num.threads = p, classification=TRUE)
		ptm_hold <- (proc.time() - ptm)[3]

		predictions <- predict(forest, Xt)
		error <- sum(predictions$predictions == Yt)/length(Yt)

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




