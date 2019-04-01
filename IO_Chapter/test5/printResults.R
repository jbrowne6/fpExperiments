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
mydataAll <- read.csv(file="memUse.txt", header=FALSE, sep=",")
colnames(mydataAll) <- c("Dataset","memUsed","TestType","System","NumCores","NumClasses","NumObservations","NumFeatures")
mydataAll[,2] <- as.integer(mydataAll[,2])/1000000
mydataAll[,5] <- as.integer(mydataAll[,5])
mydataAll[,6] <- as.integer(mydataAll[,6])
mydataAll[,7] <- as.integer(mydataAll[,7])
mydataAll[,8] <- as.integer(mydataAll[,8])
mydataAll[,4] <- revalue(mydataAll[,4], c("binnedBase"="RF", "binnedBaseRerF"="RerF","rfBase"="fastRF","rerf"="fastRerF"))


mydata <- mydataAll[mydataAll[,3]=="cores",]
mydata <- data_summary(mydata,varname="memUsed",groupnames=c("System","NumCores"))
#png(filename="MemUsedThread.png")
p <- ggplot(mydata, aes(NumCores, memUsed, color=System)) + geom_line(size=1.5)
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Multithread Effects on Training Memory", x="Number of Threads(log2)", y="Training Memory(GB)", subtitle=paste("SVHN, 128 trees, 5 Classes,\n60000 Observations, 1024 Features"))
#p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + scale_x_continuous(trans="log2")
#p <- p + facet_grid(Dataset ~ ., scales="free_y")
#print(p)
ggsave("MemeUsedThread.pdf")
#dev.off()


mydata <- mydataAll[mydataAll[,3]=="classes",]
mydata <- data_summary(mydata,varname="memUsed",groupnames=c("System","NumClasses"))
#png(filename="MemUsedClass.png")
p <- ggplot(mydata, aes(NumClasses, memUsed, color=System)) + geom_line(size=1.5)
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Number of Classes Effects on Training Memory", x="Number of Classes", y="Training Memory(GB)", subtitle=paste("SVHN, 128 trees, 16 Threads,\n60000 Observations, 1024 Features"))
#p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
#p <- p + scale_x_continuous(trans="log2")
#p <- p + scale_y_continuous(trans="log10")
#p <- p + facet_grid(Dataset ~ ., scales="free_y")
#print(p)
ggsave("MemeUsedClass.pdf")
#dev.off()

mydata <- mydataAll[mydataAll[,3]=="observations",]
mydata <- data_summary(mydata,varname="memUsed",groupnames=c("System","NumObservations"))
#png(filename="MemUsedObservations.png")
p <- ggplot(mydata, aes(NumObservations, memUsed, color=System)) + geom_line(size=1.5)
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Number of Observations Effects on Training Memory", x="Number of Observations", y="Training Memory(GB)", subtitle=paste("SVHN, 128 trees, 16 Threads,\n5 Classes, 1024 Features"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
#p <- p + scale_x_continuous(trans="log2")
#p <- p + scale_y_continuous(trans="log10")
#p <- p + facet_grid(Dataset ~ ., scales="free_y")
#print(p)
ggsave("MemeUsedObservations.pdf")
#dev.off()


mydata <- mydataAll[mydataAll[,3]=="features",]
mydata <- data_summary(mydata,varname="memUsed",groupnames=c("System","NumFeatures"))
#png(filename="MemUsedFeatures.png")
p <- ggplot(mydata, aes(NumFeatures, memUsed, color=System)) + geom_line(size=1.5)
p <- p + guides(fill = guide_legend(title="System"))
p <- p +leg + labs(title="Number of Features Effects on Training Memory", x="Number of Features", y="Training Memory(GB)", subtitle=paste("SVHN, 128 trees, 16 Threads,\n5 Classes, 60000 Observations"))
#p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
#p <- p + scale_x_continuous(trans="log2")
#p <- p + scale_y_continuous(trans="log10")
#p <- p + facet_grid(Dataset ~ ., scales="free_y")
ggsave("MemUsedFeatures.pdf")
#print(p)
#dev.off()

