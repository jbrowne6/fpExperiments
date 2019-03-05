args = commandArgs()
if (length(args)!=8) {
	    stop("At least two arguments must be supplied.")
} else {
	classes = as.integer(args[6])
	samples = as.integer(args[7])
	features = as.integer(args[8])
}


make_data <- function(numClass=5, numSamples=60000, feats=1024){
	X <- as.matrix(read.csv(file = "../../res/streetview/svhn_training_data.csv", header=FALSE,sep=","))
	Y <- read.csv(file = "../../res/streetview/svhn_training_label.csv", header=FALSE,sep=",")

	classPriority <- c(8,9,6,7,10,5,4,3,2,1)
	classToUse <- classPriority[1:numClass]

	subX <- Y %in% classToUse

	X <- X[subX, 1:feats]
	Y <- Y[subX]

	sampLength <- nrow(X)
	subX <- sample(1:sampLength, numSamples, replace=FALSE)

	X <- X[subX,]
	Y <- Y[subX,]

	write.table(X, "temp_data.csv", sep=",", row.names=FALSE, col.names=FALSE)
	write.table(Y, "temp_label.csv", sep=",", row.names=FALSE, col.names=FALSE)
}


if(classes == -1){
	classes =5
}
if(samples== -1){
	samples=60000
}
if(features == -1){
	features = 1024
}

make_data(classes, samples, features)
