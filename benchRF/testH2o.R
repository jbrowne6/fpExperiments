library(h2o)

nTimes <- 10

num_trees <- 10
ML <- c(1)
#ML <- c(1,2,4,8,16,32,48)

dataset <- "temp"
algorithm <- "temp"
numCores <- 0
time <- 0

resultData <- data.frame(as.character(dataset), algorithm, numCores, time, stringsAsFactors=FALSE)

## Create an H2O cloud 
h2o.init(
				 nthreads=ML,            ## -1: use all available threads
				 max_mem_size = "10G")    ## specify the memory size for the H2O cloud



#####################################################
#########                MNIST
#####################################################
h2o.removeAll() # Clean slate - just in case the cluster was already running
df <- h2o.importFile(path = normalizePath("../res/mnist.csv"))
splits <- h2o.splitFrame(
												 df,           ##  splitting the H2O frame we read above
												 c(.99,0.0),   ##  create splits of 60% and 20%; 
												 ##  H2O will create one more split of 1-(sum of these parameters)
												 ##  so we will get 0.6 / 0.2 / 1 - (0.6+0.2) = 0.6/0.2/0.2
												 seed=1234)    ##  setting a seed will ensure reproducible results (not R's seed)

train <- h2o.assign(splits[[1]], "train.hex")   

for (p in ML){
	for (i in 1:nTimes){
		gc()
		ptm <- proc.time()
		rf1 <- h2o.randomForest(        
														training_frame = train,      
														x=2:785,                    
														y=1,                       
														ntrees = 10,              
														stopping_rounds = 10,  
														score_each_iteration = F,
														seed = 1000000)

		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("MNIST", "H2o.ai",p, ptm_hold)) 
	}
}



####################################################
##########              HIGGS1
####################################################
h2o.removeAll() # Clean slate - just in case the cluster was already running
df <- h2o.importFile(path = normalizePath("../res/higgsData.csv"))
splits <- h2o.splitFrame(
												 df,           ##  splitting the H2O frame we read above
												 c(.99,0.0),   ##  create splits of 60% and 20%; 
												 ##  H2O will create one more split of 1-(sum of these parameters)
												 ##  so we will get 0.6 / 0.2 / 1 - (0.6+0.2) = 0.6/0.2/0.2
												 seed=1234)    ##  setting a seed will ensure reproducible results (not R's seed)

train <- h2o.assign(splits[[1]], "train.hex")   

for (p in ML){
	for (i in 1:nTimes){
		gc()
		ptm <- proc.time()
		rf1 <- h2o.randomForest(        
														training_frame = train,      
														x=2:32,                    
														y=1,                       
														ntrees = 10,              
														stopping_rounds = 10,  
														score_each_iteration = F,
														seed = 1000000)

		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("higgs", "H2o.ai",p, ptm_hold)) 
	}
}


####################################################
##########             P53 
####################################################
h2o.removeAll() # Clean slate - just in case the cluster was already running
df <- h2o.importFile(path = normalizePath("../res/p53.csv"))
splits <- h2o.splitFrame(
												 df,           ##  splitting the H2O frame we read above
												 c(.99,0.0),   ##  create splits of 60% and 20%; 
												 ##  H2O will create one more split of 1-(sum of these parameters)
												 ##  so we will get 0.6 / 0.2 / 1 - (0.6+0.2) = 0.6/0.2/0.2
												 seed=1234)    ##  setting a seed will ensure reproducible results (not R's seed)

train <- h2o.assign(splits[[1]], "train.hex")   

for (p in ML){
	for (i in 1:nTimes){
		gc()
		ptm <- proc.time()
		rf1 <- h2o.randomForest(        
														training_frame = train,      
														x=2:(ncol(train)-1),                    
														y=ncol(train),                       
														ntrees = 10,              
														stopping_rounds = 10,  
														score_each_iteration = F,
														seed = 1000000)

		ptm_hold <- (proc.time() - ptm)[3]
		resultData <- rbind(resultData, c("p53", "H2o.ai",p, ptm_hold)) 
	}
}



resultData <- resultData[2:nrow(resultData),]
resultData[,1] <- as.factor(resultData[,1])
resultData[,2] <- as.factor(resultData[,2])
resultData[,3] <- as.numeric(resultData[,3])
resultData[,4] <- as.numeric(resultData[,4])

write.table(resultData, file="bench.csv", col.names=FALSE, row.names=FALSE, append=TRUE, sep=",", quote=FALSE)
h2o.shutdown(prompt=FALSE)
