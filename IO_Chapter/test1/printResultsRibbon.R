library(ggplot2)
library(plyr)

data_summary <- function(data, varname, groupnames){
	      require(plyr)
  summary_func <- function(x, col){
		          c(mean = mean(x[[col]], na.rm=TRUE),
								                  sd = sd(x[[col]], na.rm=TRUE))
	    }
	    data_sum<-ddply(data, groupnames, .fun=summary_func,
											                                      varname)
	    data_sum <- rename(data_sum, c("mean" = varname))
			     return(data_sum)
}


data_min <- function(data, varname, groupnames){
	      require(plyr)
  summary_func <- function(x, col){
		          c(mean = min(x[[col]], na.rm=TRUE),
								                  sd = sd(x[[col]], na.rm=TRUE))
	    }
	    data_sum<-ddply(data, groupnames, .fun=summary_func,
											                                      varname)
	    data_sum <- rename(data_sum, c("mean" = varname))
			     return(data_sum)
}


data_max <- function(data, varname, groupnames){
	      require(plyr)
  summary_func <- function(x, col){
		          c(mean = max(x[[col]], na.rm=TRUE),
								                  sd = sd(x[[col]], na.rm=TRUE))
	    }
	    data_sum<-ddply(data, groupnames, .fun=summary_func,
											                                      varname)
	    data_sum <- rename(data_sum, c("mean" = varname))
			     return(data_sum)
}


#leg <- theme(legend.text = element_text(size = 16), legend.title=element_text(size = 16), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_blank(), axis.text.x = element_blank(), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))
leg <- theme(legend.text = element_text(size = 16), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))


mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Trees","TestingTime","error")
ymin <- min(mydata[,5])-.005
ymax <- max(mydata[,5])+.005
maindata <- data_summary(mydata,varname="error",groupnames=c("Dataset","System","Trees"))
mindata <- data_min(mydata,varname="error",groupnames=c("Dataset","System","Trees"))
maxdata <- data_max(mydata,varname="error",groupnames=c("Dataset","System","Trees"))

dfmFast <- maindata[maindata$System=="fastRF",]
df1Fast <- mindata[maindata$System=="fastRF",]
df2Fast <- maxdata[maindata$System=="fastRF",]
ribbonFast <- data.frame(dfmFast,df1Fast$error,df2Fast$error)
names(ribbonFast) <- c('Dataset','System','Trees','error','sd','min','max')

dfmRF <- maindata[maindata$System!="fastRF",]
df1RF <- mindata[maindata$System!="fastRF",]
df2RF <- maxdata[maindata$System!="fastRF",]
ribbonRF <- data.frame(dfmRF,df1RF$error,df2RF$error)
names(ribbonRF) <- c('Dataset','System','Trees','error','sd','min','max')

pdf("BreimanTest.pdf")
p <- ggplot(maindata, aes(x=Trees,y=error,group=System))
p <- p + geom_ribbon(data=ribbonFast,aes(ymin=min, ymax=max,x=Trees),fill='blue',alpha=0.3)
p <- p + geom_ribbon(data=ribbonRF,aes(ymin=min, ymax=max,x=Trees),fill='red',alpha=0.3)
p <- p + geom_line(aes(color=System, linetype=System),size=1.5)
p <- p + scale_color_manual(values=c('blue','red'))
#p <- p + geom_ribbon(data=ribbonRF,aes(ymin=min, ymax=max,x=dfmRF,fill='lightblue'))
p <- p + leg + labs(title="Correctness of fastRF", x="Number of Trees", y="Ratio Correct")
p <- p + coord_cartesian(ylim=c(ymin, ymax))
p <- p + facet_grid(Dataset ~ .)
p <- p + theme(legend.position="bottom")
print(p)
dev.off()
