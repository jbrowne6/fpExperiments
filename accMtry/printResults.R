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



mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","TestingTime","error","Mtry","MtryMult")

mydata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","Threads","Mtry", "MtryMult"))

png(filename="mtryGrowTime.png")
p <- ggplot(mydata, aes(MtryMult, Mtry, fill=TrainingTime)) + geom_raster()
p <- p + guides(fill = guide_legend(title="Training\nTime(s)"))
p <- p +leg + labs(title="Mtry Growing Effects on Training Times", x="Mtry Multiplier", y="Mtry", subtitle=paste("16 Core, MNIST, 16 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + scale_y_continuous(breaks=c(28,56,84,112,140))
print(p)
dev.off()


mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","TestingTime","error","Mtry","MtryMult")
mydata <- data_summary(mydata,varname="error",groupnames=c("Dataset","System","Threads","Mtry", "MtryMult"))


png(filename="mtryGrowAcc.png")
p <- ggplot(mydata, aes(MtryMult, Mtry, fill=error)) + geom_raster()
p <- p + guides(fill = guide_legend(title="Ratio\nCorrect"))
p <- p +leg + labs(title="Mtry Growing Effects on Accuracy", x="Mtry Multiplier", y="Mtry", subtitle=paste("16 Core, MNIST, 16 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + scale_y_continuous(breaks=c(28,56,84,112,140))
print(p)
dev.off()
