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
colnames(mydata) <- c("Dataset","System","NumCores","TrainingTime","InferTime","RunNum")

levels(mydata$System) <- factor(c(levels(mydata$System),"fastRF","fastRF(Binned)"))
mydata$System[mydata$System == "binnedBase"] <- "fastRF(Binned)"
mydata$System[mydata$System == "rfBase"] <- "fastRF"

maindataTrain <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","NumCores"))

maindataInfer <- data_summary(mydata,varname="InferTime",groupnames=c("Dataset","System","NumCores"))

p1 <- ggplot()
p1 <- p1 + geom_line(data=mydata,aes(x=NumCores,y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p1 <- p1 + geom_line(data=maindataTrain, aes(x=NumCores, y=TrainingTime, color=System),size=1.0)
p1 <- p1 +leg + labs(x="Number of Threads", y="Training Time (s, log10)")
p1 <- p1 + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRF(Binned)"="#377eb8"))
p1 <- p1 + scale_y_continuous(trans='log10')
p1 <- p1 + theme(legend.position="bottom")


p2 <- ggplot()
p2 <- p2 + geom_line(data=mydata,aes(x=NumCores,y=InferTime,color=System,group=interaction(RunNum,System)),size=0.30,alpha=0.30)
p2 <- p2 + geom_line(data=maindataInfer, aes(x=NumCores, y=InferTime, color=System),size=1.0)
p2 <- p2 +leg + labs(x="Number of Threads", y="Inference Time (s, log10)")
p2 <- p2 + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRF(Binned)"="#377eb8"))
p2 <- p2 + scale_y_continuous(trans='log10')
p2 <- p2 + theme(legend.position="bottom")




g_legend<-function(a.gplot){
	  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	  legend <- tmp$grobs[[leg]]
	  return(legend)}

mylegend<-g_legend(p1)

pdf("test7Combined.pdf", height=5, width=10)
grid.arrange(arrangeGrob(p1 + theme(legend.position="none"), p2 + theme(legend.position="none"),nrow=1), mylegend, nrow=2,heights=c(5, 1))
dev.off()


pdf("test7TrainTime.pdf")
print(p1)
dev.off()



pdf("test7InferTime.pdf")
print(p2)
dev.off()


