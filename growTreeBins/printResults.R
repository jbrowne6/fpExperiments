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
mydata <- read.csv(file="treeGrow.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System","TrainingTime","error","BinThreshold","BinSize","NumTrees")
mydata[,6] <- as.character(mydata[,6])
mydata[,6][mydata[,6]=="0"] <- "No Bin"
mydata[,6] <- as.factor(mydata[,6])
mydata <- data_summary(mydata,varname="error",groupnames=c("Dataset","System","BinSize","NumTrees"))



png(filename="treeGrow.png")
p <- ggplot(mydata, aes(NumTrees, error, color=BinSize)) + geom_line()
p <- p + guides(fill = guide_legend(title="Bin\nSize"))
p <- p +leg + labs(title="Bin Parameter Effects on Error", x="Number of Trees (log2)", y="Training Error", subtitle=paste("MNIST"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + scale_x_continuous(trans="log2")
p <- p + facet_grid(System ~ .)
print(p)
dev.off()
