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


mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Trees","error")
#ymin <- min(mydata[,5])-.005
#ymax <- max(mydata[,5])+.005
maindata <- data_summary(mydata,varname="error",groupnames=c("Dataset","Trees"))


pdf("BreimanTest.pdf")
p <- ggplot(mydata, aes(x=Trees))
p <- p + geom_line(aes(y=error,color="All Runs",group=System),size=0.25,alpha=.25)
p <- p + geom_line(data=maindata, aes(x=Trees, y=error,color="Median"),size=1.0)
#p <- p + geom_ribbon(data=ribbonRF,aes(ymin=min, ymax=max,x=dfmRF,fill='lightblue'))
p <- p + leg + labs(title="Correctness of fastRF", x="Number of Trees", y="Ratio Matching Predictions")
#p <- p + coord_cartesian(ylim=c(ymin, ymax))
p <- p + facet_grid(Dataset ~ .)
p <- p + theme(legend.position="bottom")
print(p)
dev.off()
