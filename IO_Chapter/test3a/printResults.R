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
colnames(mydata) <- c("Dataset", "System", "NumObs","TrainingTime","RunNum","error","binSize")


levels(mydata$System) <- factor(c(levels(mydata$System),"fastRF","fastRerF"))
mydata$System[mydata$System == "rfBase"] <- "fastRF"
mydata$System[mydata$System == "rerf"] <- "fastRerF"

maindataTT <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","NumObs","binSize"))
maindataTE <- data_summary(mydata,varname="error",groupnames=c("Dataset","System","NumObs","binSize"))

mydata$System <- factor(mydata$System,c("fastRF","fastRerF","LightGBM","Ranger","XGBoost","RF"))



pdf("3abigNumObsTT.pdf")
p <- ggplot(mydata, aes(x=binSize))
p <- p + geom_line(aes(y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p <- p + geom_line(data=maindataTT, aes(x=binSize, y=TrainingTime, color=System),size=1.0)
p <- p +leg + labs(title="Large Num Obs Training Time", x="Subsample Size / Training Observations", y="Training Time (s)")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p <- p + scale_y_continuous(trans='log10')
p <- p + scale_x_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
p <- p + theme(legend.position="bottom")
print(p)
dev.off()



pdf("3abigNumObsTE.pdf")
p <- ggplot(mydata, aes(x=binSize))
p <- p + geom_line(aes(y=error,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p <- p + geom_line(data=maindataTE, aes(x=binSize, y=error, color=System),size=1.0)
p <- p +leg + labs(title="Large Num Obs Training Accuracy", x="Subsample Size / Training Observations", y="Ratio Correct")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p <- p + scale_y_continuous(trans='log10')
p <- p + scale_x_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
p <- p + theme(legend.position="bottom")
print(p)
dev.off()

