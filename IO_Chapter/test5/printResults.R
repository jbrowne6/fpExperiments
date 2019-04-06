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
mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Exper", "NumCores","TrainingTime","NumClasses","NumObs","NumFeats","RunNum")

levels(mydata$System) <- factor(c(levels(mydata$System),"fastRF","fastRerF"))
mydata$System[mydata$System == "rfBase"] <- "fastRF"
mydata$System[mydata$System == "rerf"] <- "fastRerF"

maindataTC <- data_summary(mydata[mydata$Exper=="classes",],varname="TrainingTime",groupnames=c("Dataset","System","NumClasses"))
maindataTO <- data_summary(mydata[mydata$Exper=="observations",],varname="TrainingTime",groupnames=c("Dataset","System","NumObs"))
maindataTF <- data_summary(mydata[mydata$Exper=="features",],varname="TrainingTime",groupnames=c("Dataset","System","NumFeats"))

mydata$System <- factor(mydata$System,c("fastRF","fastRerF","LightGBM","Ranger","XGBoost","RF"))


pdf("GrowingClasses.pdf")
p <- ggplot()
p <- p + geom_line(data=mydata[mydata$Exper=="classes",],aes(x=NumClasses,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p <- p + geom_line(data=maindataTC, aes(x=NumClasses, y=TrainingTime, color=System),size=1.0)
p <- p +leg + labs(title="Num Class Effects on Training Time", x="Number of Classes", y="Training Time (s)")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p <- p + scale_y_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
p <- p + theme(legend.position="bottom")
print(p)
dev.off()



pdf("GrowingObs.pdf")
p <- ggplot()
p <- p + geom_line(data=mydata[mydata$Exper=="observations",],aes(x=NumObs,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p <- p + geom_line(data=maindataTO, aes(x=NumObs, y=TrainingTime, color=System),size=1.0)
p <- p +leg + labs(title="Num Obs Effects on Training Time", x="Number of Observations", y="Training Time (s)")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p <- p + scale_y_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
p <- p + theme(legend.position="bottom")
print(p)
dev.off()


pdf("GrowingFeatures.pdf")
p <- ggplot()
p <- p + geom_line(data=mydata[mydata$Exper=="features",],aes(x=NumFeats,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p <- p + geom_line(data=maindataTF, aes(x=NumFeats, y=TrainingTime, color=System),size=1.0)
p <- p +leg + labs(title="Num Features Effects on Training Time", x="Number of Features", y="Training Time (s)")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p <- p + scale_y_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
p <- p + theme(legend.position="bottom")
print(p)
dev.off()
