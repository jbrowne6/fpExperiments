# ---
# title: "Accuracy as number of samples grows"
# author: "James Browne"
# date: "May 16 2017"
#output: html_document
# ---

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

plotText <- 16
leg <- theme(legend.text = element_text(size = 10), legend.title=element_text(size = plotText), plot.title = element_text(size = plotText,  face="bold"), plot.subtitle = element_text(size = plotText),axis.title.x = element_text(size=12), axis.text.x = element_text(size=plotText), axis.title.y = element_text(size=plotText), axis.text.y = element_text(size=plotText))


mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","RunNum")
levels(mydata$System) <- factor(c(levels(mydata$System),"fastRF","fastRerF","LightGBM"))
mydata <- mydata[mydata$System != "rfBase",]
mydata <- mydata[mydata$System != "rerf",]
mydata$System[mydata$System == "binnedBase"] <- "fastRF" 
mydata$System[mydata$System == "binnedBaseRerF"] <- "fastRerF" 
mydata$System[mydata$System == "lightGBM"] <- "LightGBM" 
mydata$Threads <- as.numeric(mydata$Threads)
mydata$TrainingTime <- as.numeric(mydata$TrainingTime)
maindata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","Threads"))
mydata$System <- factor(mydata$System,c("fastRF","fastRerF","LightGBM","Ranger","XGBoost","RF"))


p1 <- ggplot(mydata, aes(x=Threads))
p1 <- p1 + geom_line(aes(y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.5,alpha=0.5)
p1 <- p1 + geom_line(data=maindata, aes(x=Threads, y=TrainingTime, color=System),size=1.0)
p1 <- p1 +leg + labs(x="Number of Threads (log2)", y="Training Time (s, log10)")
#p1 <- p1 +leg + labs(title="Multithread Training Time", x="Number of Threads", y="Training Time (s)")
p1 <- p1 + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8", "LightGBM"="#984ea3", "Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p1 <- p1 + scale_y_continuous(trans='log10')
p1 <- p1 + scale_x_continuous(trans='log2')
p1 <- p1 + facet_grid(Dataset ~ ., scales = "free_y")
p1 <- p1 + theme(legend.position="bottom")





data_speedUp <- function(data, varnameTimes, varnameCores, groupnames){
	      require(plyr)
  summary_func <- function(x, col1, col2){
		    oneCoreTime <- x[[col1]][x[[col2]]==1]
	           x[[col1]] = oneCoreTime/x[[col1]]
	    x
			    }
	    data_sum<-ddply(data, groupnames, .fun=summary_func, varnameTimes, varnameCores)
	    #data_sum <- rename(data_sum, c("su" = varnameTimes))
	     return(data_sum)
}


mydata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","Threads"))
mydata <- data_speedUp(mydata,varnameTimes="TrainingTime",varnameCores="Threads",groupnames=c("Dataset","System"))

#add ideal line
levels(mydata$System) <- factor(c(levels(mydata$System),"Ideal"))
for(i in unique(mydata$Threads)){
	for(j in unique(mydata$Dataset)){
		mydata <- rbind(mydata, c(j,"Ideal", i, i,NA))
	}
}
mydata$TrainingTime <- as.numeric(mydata$TrainingTime)
mydata$Threads <- as.numeric(mydata$Threads)

p2 <- ggplot(mydata, aes(x=Threads, y=TrainingTime, group=System, color=System)) + geom_line(size=1)
#p2 <- p2 + theme_minimal()
p2 <- p2 + guides(fill=FALSE)
p2 <- p2 + labs(x = "Number of Threads", y = "Speed Up")
p2 <- p2 + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8", "LightGBM"="#984ea3", "Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a", "Ideal"="black"))
p2 <- p2 + leg
p2 <- p2 + scale_y_continuous(breaks=c(10,20,30,40))
p2 <- p2 + scale_x_continuous(breaks=c(10,20,30,40))
p2 <- p2 + facet_grid(Dataset ~ .)
p2 <- p2 + theme(legend.position="bottom")


g_legend<-function(a.gplot){
	  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	  legend <- tmp$grobs[[leg]]
	  return(legend)}

mylegend<-g_legend(p1)

pdf("test2Combined.pdf", height=5, width=5)
grid.arrange(arrangeGrob(p1 + theme(legend.position="none"), p2 + theme(legend.position="none"), nrow=1), mylegend, nrow=2,heights=c(10, 1))
dev.off()


pdf("Test2ThreadPerf.pdf")
print(p1)
dev.off()

pdf("Test2SpeedUp.pdf")
print(p2)
dev.off()
