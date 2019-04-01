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




##############################################################
##############################################################
mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System","numCores","TrainingTime","TestingTime","Accuracy", "NumTrees")

#mydata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","numCores","NumTrees"))
mydata[,2] <- revalue(mydata[,2], c("binnedBase"="RF", "binnedBaseRerF"="RerF"))



#png(filename="prefetch.png")
p <- ggplot(mydata, aes(TrainingTime,Accuracy, color=System)) + geom_line(size=1.5)
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Accuracy Vs Training Time", x="Training Time (s)", y="Accuracy", subtitle=paste("MNIST, 1 Thread, 10 Classes,\n60000 Observations, 784 Features"))
p <- p + expand_limits(x = 0, y = 0)
ggsave("accVtime.pdf")
