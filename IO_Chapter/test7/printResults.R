library(ggplot2)
library(gridExtra)
library(scales)

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

plotText <- 20
leg <- theme(legend.text = element_text(size = 12), legend.title=element_text(size = 18), plot.title = element_text(size = plotText,  face="bold"), plot.subtitle = element_text(size = plotText),axis.title.x = element_text(size=plotText), axis.text.x = element_text(size=plotText), axis.title.y = element_text(size=plotText), axis.text.y = element_text(size=plotText))


mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","error","binSize","binSize2","RunNum") 


maindataTT <- mydata[mydata$binSize %in% c(0,10,50,100,200),]
maindataTT$binSize <- as.factor(maindataTT$binSize)
levels(maindataTT$binSize) <- factor(c(levels(maindataTT$binSize),"Full Sample"))
maindataTT$binSize[maindataTT$binSize == 0] <- "Full Sample" 
maindataTTSummary <- data_summary(maindataTT,varname="TrainingTime",groupnames=c("Threads","binSize"))


p1 <- ggplot(maindataTT, aes(x=Threads))
p1 <- p1 + geom_line(aes(y=TrainingTime,color=binSize,group=interaction(RunNum,binSize)),size=0.5,alpha=0.5)
p1 <- p1 + geom_line(data=maindataTTSummary, aes(x=Threads, y=TrainingTime, color=binSize),size=1.0)
p1 <- p1 +leg + labs(x="Number of Threads (log2)", y="Training Time (s, log10)")
p1 <- p1 + scale_y_continuous(trans='log10')
p1 <- p1 + scale_x_continuous(trans='log2')
#p1 <- p1 + facet_grid(Dataset ~ ., scales = "free_y")
p1 <- p1 + theme(legend.position="bottom")
p1 <- p1 + guides(color=guide_legend(title="Subsample Size",title.position = "top"))



maindataTE <- mydata[mydata$Threads %in% c(2,4),]


BinData <- maindataTE[maindataTE$binSize != 0,] 
currNames <- colnames(BinData)
BinData <- cbind(BinData, "Subsampled")
colnames(BinData) <- c(currNames, "BinType") 
BinDataSummary <- data_summary(BinData,varname="error",groupnames=c("binSize","BinType"))


noBinData <- maindataTE[maindataTE$binSize == 0,] 
noBinData <- rbind(noBinData,noBinData)
noBinData$binSize[1:(nrow(noBinData)/2)] <- min(BinData$binSize)
noBinData$binSize[(1+nrow(noBinData)/2):nrow(noBinData)] <- max(BinData$binSize)
currNames <- colnames(noBinData)
noBinData <- cbind(noBinData, "Full Sample")
colnames(noBinData) <- c(currNames, "BinType") 
noBinDataSummary <- data_summary(noBinData,varname="error",groupnames=c("binSize","BinType"))

DataSummaryTE <- rbind(BinDataSummary, noBinDataSummary)
DataTE <- rbind(BinData, noBinData)


p2 <- ggplot()
p2 <- p2 + geom_line(data=DataSummaryTE, aes(x=binSize, y=error,color=BinType),size=1.0)
p2 <- p2 + geom_line(data=DataTE, aes(x=binSize,y=error,color=BinType,group=interaction(RunNum,Threads,BinType)),size=0.3,alpha=0.3)
p2 <- p2 + guides(fill=FALSE)
p2 <- p2 + labs(x = "Subsample Size", y = "Test Set Accuracy")
p2 <- p2 + theme(legend.position="bottom")
p2 <- p2 +guides(colour = guide_legend(title.position = "top"))
#p2 <- p2 + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8", "LightGBM"="#984ea3", "Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a", "Ideal"="black"))
p2 <- p2 + leg


combined <- TRUE

if(combined){

g_legend<-function(a.gplot){
	  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	  legend <- tmp$grobs[[leg]]
	  return(legend)
}


pdf("test3Combined.pdf", height=5, width=10)
grid.arrange(arrangeGrob(p1,p2,nrow=1))
dev.off()


}else{
pdf("Test3ThreadPerf.pdf")
print(p1)
dev.off()

pdf("Test3Error.pdf")
print(p2)
dev.off()
}
