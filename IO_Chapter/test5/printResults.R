# ---
# title: "Accuracy as number of samples grows"
# author: "James Browne"
# date: "May 16 2017"
#output: html_document
# ---

library(ggplot2)
library(gridExtra)
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
plotText <- 22


leg <- theme(legend.text = element_text(size = plotText), legend.title=element_text(size = plotText), plot.title = element_text(size = plotText,  face="bold"), plot.subtitle = element_text(size = plotText),axis.title.x = element_text(size=plotText), axis.text.x = element_text(size=plotText), axis.title.y = element_text(size=plotText), axis.text.y = element_text(size=plotText))



##############################################################
##############################################################
mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Exper", "NumCores","TrainingTime","NumClasses","NumObs","NumFeats","RunNum")

levels(mydata$System) <- factor(c(levels(mydata$System),"fastRF","fastRerF"))
mydata$System[mydata$System == "binnedBase"] <- "fastRF"
mydata$System[mydata$System == "binnedBaseRerF"] <- "fastRerF"

maindataTC <- data_summary(mydata[mydata$Exper=="classes",],varname="TrainingTime",groupnames=c("Dataset","System","NumClasses"))
maindataTO <- data_summary(mydata[mydata$Exper=="observations",],varname="TrainingTime",groupnames=c("Dataset","System","NumObs"))
maindataTF <- data_summary(mydata[mydata$Exper=="features",],varname="TrainingTime",groupnames=c("Dataset","System","NumFeats"))

mydata$System <- factor(mydata$System,c("fastRF","fastRerF","LightGBM","Ranger","XGBoost","RF"))




combined <- FALSE
if(combined){
p <- ggplot()
p <- p + geom_line(data=mydata[mydata$Exper=="classes",],aes(x=NumClasses,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p <- p + geom_line(data=maindataTC, aes(x=NumClasses, y=TrainingTime, color=System),size=1.0)
theme(axis.title.x=element_blank(),
			        axis.text.x=element_blank(),
							        axis.ticks.x=element_blank())
p <- p +leg + labs(x="Number of Classes", y="Training Time (s, log10)")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p <- p + scale_y_continuous(trans='log10')
p <- p + theme(legend.position="none")


q <- ggplot()
q <- q + geom_line(data=mydata[mydata$Exper=="observations",],aes(x=NumObs,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
q <- q + geom_line(data=maindataTO, aes(x=NumObs, y=TrainingTime, color=System),size=1.0)
q <- q +leg + labs(x="Number of Observations", y="Training Time (s, log10)")
q <- q + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
q <- q + scale_y_continuous(trans='log10')
q <- q + theme(legend.position="bottom",axis.title.y=element_blank())


s <- ggplot()
s <- s + geom_line(data=mydata[mydata$Exper=="features",],aes(x=NumFeats,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
s <- s + geom_line(data=maindataTF, aes(x=NumFeats, y=TrainingTime, color=System),size=1.0)
s <- s +leg + labs(x="Number of Features", y="Training Time (s, log10)")
#p <- p +leg + labs(title="Num Features Effects on Training Time", x="Number of Features", y="Training Time (s,log10)")
s <- s + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
s <- s + scale_y_continuous(trans='log10')
s <- s + theme(legend.position="none",axis.title.y=element_blank())



g_legend<-function(a.gplot){
	  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	  legend <- tmp$grobs[[leg]]
	  return(legend)}

mylegend<-g_legend(q)



pdf("test5Combined.pdf", height=5, width=15)
grid.arrange(arrangeGrob(p, q + theme(legend.position="none"), s, nrow=1), mylegend, nrow=2,heights=c(10, 1))
dev.off()

}else{

plotText <- 20


leg <- theme(legend.text = element_text(size = 13), legend.title=element_text(size = plotText), plot.title = element_text(size = plotText,  face="bold"), plot.subtitle = element_text(size = plotText),axis.title.x = element_text(size=plotText), axis.text.x = element_text(size=plotText), axis.title.y = element_text(size=plotText), axis.text.y = element_text(size=plotText))





pdf("test5GrowingClasses.pdf")
p <- ggplot()
p <- p + geom_line(data=mydata[mydata$Exper=="classes",],aes(x=NumClasses,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p <- p + geom_line(data=maindataTC, aes(x=NumClasses, y=TrainingTime, color=System),size=1.0)
p <- p +leg + labs(x="Number of Classes", y="Training Time (s)")
#p <- p +leg + labs(title="Num Class Effects on Training Time", x="Number of Classes", y="Training Time (s,log10)")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
#p <- p + scale_y_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
#p <- p + facet_grid(Dataset ~ ., scales = "free_y")
p <- p + theme(legend.position="bottom")
print(p)
dev.off()



pdf("test5GrowingObs.pdf")
q <- ggplot()
q <- q + geom_line(data=mydata[mydata$Exper=="observations",],aes(x=NumObs,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
q <- q + geom_line(data=maindataTO, aes(x=NumObs, y=TrainingTime, color=System),size=1.0)
#p <- p +leg + labs(title="Num Obs Effects on Training Time", x="Number of Observations", y="Training Time (s,log10)")
q <- q +leg + labs(x="Number of Observations", y="Training Time (s)")
q <- q + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
#q <- q + scale_y_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
#p <- p + facet_grid(Dataset ~ ., scales = "free_y")
q <- q + theme(legend.position="bottom")
print(q)
dev.off()


pdf("test5GrowingFeatures.pdf")
s <- ggplot()
s <- s + geom_line(data=mydata[mydata$Exper=="features",],aes(x=NumFeats,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
s <- s + geom_line(data=maindataTF, aes(x=NumFeats, y=TrainingTime, color=System),size=1.0)
s <- s +leg + labs(x="Number of Features", y="Training Time (s)")
#p <- p +leg + labs(title="Num Features Effects on Training Time", x="Number of Features", y="Training Time (s,log10)")
s <- s + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8","LightGBM"="#984ea3","Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
#s <- s + scale_y_continuous(trans='log10')
#p <- p + scale_x_continuous(trans='log2')
#p <- p + facet_grid(Dataset ~ ., scales = "free_y")
s <- s + theme(legend.position="bottom")
print(s)
dev.off()
}
