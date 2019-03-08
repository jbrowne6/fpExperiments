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
colnames(mydata) <- c("Dataset", "System","numCores","TrainingTime","prefetchSize","preFlag")

mydata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","prefetchSize"))
mydata <- mydata[mydata$prefetchSize < 1000,]
mydata[,2] <- revalue(mydata[,2], c("binnedBase"="RF", "binnedBaseRerF"="RerF"))



png(filename="prefetch.png")
p <- ggplot(mydata, aes(prefetchSize, TrainingTime, color=System)) + geom_line()
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Prefetching Distance Effects on Training Time", x="Prefetch Distance", y="Training Time", subtitle=paste("SVHN, N=60000, d=1024, C=5"))
p <- p + expand_limits(x = 0, y = 0)
#p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
#p <- p + scale_x_continuous(trans="log2")
#p <- p + facet_grid(System ~ .)
print(p)
dev.off()
