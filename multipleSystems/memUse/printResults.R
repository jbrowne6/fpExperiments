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



##############################################################
##############################################################
mydata <- read.csv(file="memUse.txt", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset","memUsed","System","NumCores")
mydata[,2] <- as.integer(mydata[,2])/1000
mydata <- data_summary(mydata,varname="memUsed",groupnames=c("Dataset","System","NumCores"))



png(filename="MemUsed.png")
p <- ggplot(mydata, aes(NumCores, memUsed, color=System)) + geom_line(size=1.5)
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Multithread Effects on Memory Use", x="Number of Threads(log2)", y="Memory Used(MB)", subtitle=paste("128 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + scale_x_continuous(trans="log2")
p <- p + facet_grid(Dataset ~ ., scales="free_y")
print(p)
dev.off()


mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset","System","NumCores","TrainingTime")
mydata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","NumCores"))



png(filename="TrainingTimeUsed.png")
p <- ggplot(mydata, aes(NumCores, TrainingTime, color=System)) + geom_line(size=1.5)
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Multithread Effects on Training Time", x="Number of Threads(log2)", y="Training Time(s)", subtitle=paste("128 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + scale_x_continuous(trans="log2")
p <- p + scale_y_continuous(trans="log10")
p <- p + facet_grid(Dataset ~ ., scales="free_y")
print(p)
dev.off()

