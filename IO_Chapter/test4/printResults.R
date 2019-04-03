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


leg <- theme(legend.text = element_text(size = 16), legend.title=element_text(size = 16), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_blank(), axis.text.x = element_blank(), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))
#leg <- theme(legend.text = element_text(size = 16), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))


mydata <- read.csv(file="bench.csv.old", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads","TestingTime","error")
ymin <- min(mydata[,5])-.005
ymax <- max(mydata[,5])+.005
mydata <- data_summary(mydata,varname="error",groupnames=c("Dataset","System"))


png(filename="accAll.png")
p <- ggplot(mydata, aes(x=System,y=error,fill=System)) + geom_bar(position=position_dodge(),stat="identity")
p <- p + geom_errorbar(aes(ymin=error-sd, ymax=error+sd))
p <- p + guides(fill = guide_legend(title=""))
p <- p + leg + labs(title="Accuracy of Various Systems", x="", y="Ratio Correct", subtitle=paste("MNIST, 64 trees"))
#p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
#p <- p + ylim(ymin, ymax)
p <- p + coord_cartesian(ylim=c(ymin, ymax))
print(p)
dev.off()

