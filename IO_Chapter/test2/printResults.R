# ---
# title: "Accuracy as number of samples grows"
# author: "James Browne"
# date: "May 16 2017"
#output: html_document
# ---

library(ggplot2)

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


leg <- theme(legend.text = element_text(size = 12), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 12),axis.title.x = element_text(size=12), axis.text.x = element_text(size=12), axis.title.y = element_text(size=12), axis.text.y = element_text(size=12))


mydata <- read.csv(file="benchWork.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","RunNum")
levels(mydata$System) <- factor(c(levels(mydata$System),"fastRF","fastRerF","LightGBM"))
mydata$System[mydata$System == "rfBase"] <- "fastRF" 
mydata$System[mydata$System == "rerf"] <- "fastRerF" 
mydata$System[mydata$System == "lightGBM"] <- "LightGBM" 
mydata$Threads <- as.numeric(mydata$Threads)
mydata$TrainingTime <- as.numeric(mydata$TrainingTime)
maindata <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","Threads"))
mydata$System <- factor(mydata$System,c("fastRF","fastRerF","LightGBM","Ranger","XGBoost","RF"))


pdf("benchRF.pdf")
p <- ggplot(mydata, aes(x=Threads))
p <- p + geom_line(aes(y=TrainingTime,color=System,group=interaction(RunNum,System)),size=0.5,alpha=0.5)
p <- p + geom_line(data=maindata, aes(x=Threads, y=TrainingTime, color=System),size=1.0)
p <- p +leg + labs(title="Multithread Training Time", x="Number of Threads", y="Training Time (s)")
p <- p + scale_color_manual(name=" ", values=c("fastRF"="#e41a1c", "fastRerF"="#377eb8", "LightGBM"="#984ea3", "Ranger"="#ff7f00", "XGBoost"="#ffff33", "RF"="#4daf4a"))
p <- p + scale_y_continuous(trans='log10')
p <- p + scale_x_continuous(trans='log2')
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
p <- p + theme(legend.position="bottom")
print(p)
dev.off()
