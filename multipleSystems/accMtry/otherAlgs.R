library(lightgbm)

nTimes <- 1
num_trees <- 16
numCores <- 16
ML <- numCores
algName <- "hello"
time <- 0

resultData <- data.frame("MNIST",algName, numCores,time,time, time, time, stringsAsFactors=FALSE)


#####################################################
#########                MNIST
#####################################################
X <- as.matrix(read.csv(file="../../res/mnist.csv", header=FALSE, sep=","))
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
#X <- as.matrix(iris[,1:4])
#Y <- as.numeric(iris[,5])-1


dtrain <- lgb.Dataset(data=X,label=Y)
num_classes <- length(unique(Y))


mtry <- as.integer(sqrt(ncol(X)))
mtryMult <- c(1,1.5,2,2.5,3,3.5,4)

for (algName in c("lgbm")){
	for (p in 32){
		for (numTrees in c(500)){
		#for (numTrees in c(1,2,4,8,16,32,64,128)){
				for (i in 1:nTimes){
					gc()
					ptm <- proc.time()
			forest <- lgb.train(data=dtrain, objective="multiclass",nrounds=numTrees, num_class=num_classes,learning_rate=.1,n_estimators=500, nthread=p)
					ptm_hold_train <- (proc.time() - ptm)[3]

					ptm <- proc.time()
					predictions <- predict(forest, X,reshape=TRUE)
					#predictions <- predict(forest, Xt,reshape=TRUE)
					ptm_hold <- (proc.time() - ptm)[3]
					preds <- NA
					for (n in 1:nrow(predictions)){
preds[n] <- match(max(predictions[n,]), predictions[n,])
					}

					error <- sum((preds-1)==Y)/length(Y)
					#error <- sum(preds==Yt)/length(Yt)

					resultData <- rbind(resultData, c("MNIST",algName,p,ptm_hold_train,ptm_hold,error,numTrees)) 
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

write.table(resultData, file="benchlgbm.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
