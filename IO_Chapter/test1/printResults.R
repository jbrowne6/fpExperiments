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



leg <- theme(legend.text = element_text(size = 16), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))

if(FALSE){
mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Trees","error")
maindata <- data_summary(mydata,varname="error",groupnames=c("Dataset","Trees"))


pdf("BreimanTest.pdf")
p <- ggplot(mydata, aes(x=Trees))
p <- p + geom_line(aes(y=error,color="All Simulations",group=System),size=0.25,alpha=.25)
p <- p + geom_line(data=maindata, aes(x=Trees, y=error,color="Median Simulation"),size=1.0)
p <- p + leg + labs(title="Correctness of fastRF", x="Number of Trees", y="Ratio Matching Predictions")
p <- p + facet_grid(Dataset ~ .)
p <- p + theme(legend.position="bottom")
print(p)
dev.off()
}


mydata <- read.csv(file="benchBB.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Trees","error")
maindata <- data_summary(mydata,varname="error",groupnames=c("Dataset","Trees"))



pdf("BreimanSelfTest.pdf")
p <- ggplot(mydata, aes(x=Trees))
p <- p + geom_line(aes(y=error,color="All Simulations",group=System),size=0.25,alpha=.25)
p <- p + geom_line(data=maindata, aes(x=Trees, y=error,color="Median Simulation"),size=1.0)
p <- p + leg + labs(title="Correctness of fastRF", x="Number of Trees", y="Ratio Matching Predictions")
p <- p + facet_grid(Dataset ~ .)
p <- p + theme(legend.position="bottom")
print(p)
dev.off()
