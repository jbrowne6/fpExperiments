# ---
# title: "Accuracy as number of samples grows"
# author: "James Browne"
# date: "May 16 2017"
#output: html_document
# ---

library(ggplot2)
library(plyr)

data_summary <- function(data, varname, groupnames){
	      require(plyr)
  summary_func <- function(x, col){
		          c(mean = median(x[[col]], na.rm=TRUE),
								                  sd = sd(x[[col]], na.rm=TRUE))
	    }
	    data_sum<-ddply(data, groupnames, .fun=summary_func,
											                                      varname)
	    data_sum <- rename(data_sum, c("mean" = varname))
			     return(data_sum)
}


leg <- theme(legend.text = element_text(size = 16), legend.title=element_text(size = 16), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))
#leg <- theme(legend.text = element_text(size = 16), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))



mydata <- read.csv(file="benchBig.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","error","BinThreshold","BinSize")
mydata[,7] <- mydata[,7]/mydata[,6]
mydata[,7] <- as.factor(as.integer(mydata[,7]*100))
mydata[,6] <- as.factor(mydata[,6])
mydata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","BinThreshold", "BinSize"))

png(filename="benchBigTTime.png")
p <- ggplot(mydata, aes(BinSize, BinThreshold, fill=TrainingTime)) + geom_raster()
p <- p + guides(fill = guide_legend(title="Training\nTime(s)"))
p <- p +leg + labs(title="Bin Parameter Effects on Training Times", x="Bin Size(%threshold)", y="Bin Threshold", subtitle=paste("Single Core, MNIST, 16 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + facet_grid(System ~ .)
print(p)
dev.off()


mydata <- read.csv(file="smallBench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","error","BinThreshold","BinSize")
mydata[,7] <- mydata[,7]/mydata[,6]
mydata[,7] <- as.factor(as.integer(mydata[,7]*100))
mydata[,6] <- as.factor(mydata[,6])
mydata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","BinThreshold", "BinSize"))

png(filename="benchSmallTTime.png")
p <- ggplot(mydata, aes(BinSize, BinThreshold, fill=TrainingTime)) + geom_raster()
p <- p + guides(fill = guide_legend(title="Training\nTime(s)"))
p <- p +leg + labs(title="Bin Parameter Effects on Training Times", x="Bin Size(%threshold)", y="Bin Threshold", subtitle=paste("Single Core, MNIST, 16 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + facet_grid(System ~ .)
print(p)
dev.off()

##################################################################
##################################################################

mydata <- read.csv(file="benchBig.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","error","BinThreshold","BinSize")
mydata[,7] <- mydata[,7]/mydata[,6]
mydata[,7] <- as.factor(as.integer(mydata[,7]*100))
mydata[,6] <- as.factor(mydata[,6])
mydata[,5] <- mydata[,5]
mydata <- data_summary(mydata,varname="error",groupnames=c("Dataset","System","BinThreshold", "BinSize"))

png(filename="benchBigError.png")
p <- ggplot(mydata, aes(BinSize, BinThreshold, fill=error)) + geom_raster()
p <- p + guides(fill = guide_legend(title="Training\nError"))
p <- p +leg + labs(title="Bin Parameter Effects on Training Error", x="Bin Size(%threshold)", y="Bin Threshold", subtitle=paste("Single Core, MNIST, 16 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + facet_grid(System ~ .)
print(p)
dev.off()


mydata <- read.csv(file="smallBench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","error","BinThreshold","BinSize")
mydata[,7] <- mydata[,7]/mydata[,6]
mydata[,7] <- as.factor(as.integer(mydata[,7]*100))
mydata[,6] <- as.factor(mydata[,6])
mydata[,5] <- mydata[,5]
mydata <- data_summary(mydata,varname="error",groupnames=c("Dataset","System","BinThreshold", "BinSize"))

png(filename="benchSmallError.png")
p <- ggplot(mydata, aes(BinSize, BinThreshold, fill=error)) + geom_raster()
p <- p + guides(fill = guide_legend(title="Training\nError"))
p <- p +leg + labs(title="Bin Parameter Effects on Training Error", x="Bin Size(%threshold)", y="Bin Threshold", subtitle=paste("Single Core, MNIST, 16 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + facet_grid(System ~ .)
print(p)
dev.off()

