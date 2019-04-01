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



#leg <- theme(legend.text = element_text(size = 16), legend.title=element_text(size = 16), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_blank(), axis.text.x = element_blank(), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))
leg <- theme(legend.text = element_text(size = 16), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))


mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "BinSize","TrainingTime","error")
ymin <- min(mydata[,5])-.005
ymax <- max(mydata[,5])+.005
maindataError <- data_summary(mydata,varname="error",groupnames=c("Dataset","System","BinSize"))
maindataTrainTime <- data_summary(mydata,varname="TrainingTime",groupnames=c("Dataset","System","BinSize"))

maindataError[["System"]] <- factor(maindataError[["System"]], levels=c(levels(maindataError[["System"]]),"fastRF","fastRerF"))
maindataTrainTime[["System"]] <- factor(maindataTrainTime[["System"]], levels=c(levels(maindataTrainTime[["System"]]),"fastRF","fastRerF"))

maindataError[nrow(maindataError)+1,] <- list("MNIST", "fastRF", 1, .968)
maindataError[nrow(maindataError)+1,] <- list("higgs", "fastRF", 1, 1)
maindataError[nrow(maindataError)+1,] <- list("p53", "fastRF",1,  .996)
maindataError[nrow(maindataError)+1,] <- list("MNIST", "fastRF", .05, .968)
maindataError[nrow(maindataError)+1,] <- list("higgs", "fastRF", .05, 1)
maindataError[nrow(maindataError)+1,] <- list("p53", "fastRF",.05, .996)

maindataError[nrow(maindataError)+1,] <- list("MNIST", "fastRerF", 1, .966)
maindataError[nrow(maindataError)+1,] <- list("higgs", "fastRerF", 1, 1)
maindataError[nrow(maindataError)+1,] <- list("p53", "fastRerF",1,  .995)
maindataError[nrow(maindataError)+1,] <- list("MNIST", "fastRerF", .05, .966)
maindataError[nrow(maindataError)+1,] <- list("higgs", "fastRerF", .05, 1)
maindataError[nrow(maindataError)+1,] <- list("p53", "fastRerF",.05, .995)

maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("MNIST", "fastRF", 1, 2.73)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("higgs", "fastRF", 1, 1.69)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("p53", "fastRF",1, 4.79)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("MNIST", "fastRF", .05, 2.73)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("higgs", "fastRF", .05, 1.69)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("p53", "fastRF",.05, 4.79)

maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("MNIST", "fastRerF", 1, 17.105)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("higgs", "fastRerF", 1, 4.18)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("p53", "fastRerF",1,  4.91)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("MNIST", "fastRerF", .05, 17.105)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("higgs", "fastRerF", .05, 4.18)
maindataTrainTime[nrow(maindataTrainTime)+1,] <- list("p53", "fastRerF",.05, 4.91)


pdf("binTrainingTime.pdf")
p <- ggplot(maindataTrainTime, aes(x=BinSize,y=TrainingTime,group=System))
p <- p + geom_line(aes(color=System, linetype=System),size=1.5)
#p <- p + scale_color_manual(values=c('blue','red'))
#p <- p + geom_ribbon(data=ribbonRF,aes(ymin=min, ymax=max,x=dfmRF,fill='lightblue'))
p <- p + leg + labs(title="Effects of Bin Size on Training Time", x="Bin Size: Percentage of Number of Observations", y="Training Time")
#p <- p + coord_cartesian(ylim=c(ymin, ymax))
p <- p + facet_grid(Dataset ~ .)
p <- p + theme(legend.position="bottom")
print(p)
dev.off()

pdf("binTrainingError.pdf")
p <- ggplot(maindataError, aes(x=BinSize,y=error,group=System))
p <- p + geom_line(aes(color=System, linetype=System),size=1.5)
#p <- p + scale_color_manual(values=c('blue','red'))
#p <- p + geom_ribbon(data=ribbonRF,aes(ymin=min, ymax=max,x=dfmRF,fill='lightblue'))
p <- p + leg + labs(title="Effects of Bin Size on Training Error", x="Bin Size: Percentage of Number of Observations", y="Ratio of Correct Training Examples")
#p <- p + coord_cartesian(ylim=c(ymin, ymax))
p <- p + facet_grid(Dataset ~ .)
p <- p + theme(legend.position="bottom")
print(p)
dev.off()
