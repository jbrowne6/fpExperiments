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



mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "featurePercent", "trainingTime")
mydata <- data_summary(mydata,varname="trainingTime",groupnames=c("Dataset","System","featurePercent"))

#mydata[mydata$Dataset=="p53",4] <- mydata[mydata$Dataset=="p53",4]/mydata[mydata$Dataset=="p53" & mydata$System=="binnedBase" ,4]
#cols <- c("Ideal"="#000000", "RerF"="#009E73", "XGBoost"="#E69F00", "Ranger"="#0072B2", "RF"="#CC79A7")

pdf("trainingIncreaseP.pdf")
p <- ggplot(mydata, aes(x=featurePercent, y=trainingTime))
p <- p + geom_line()
p <- p + leg + labs(title="Training Time Increase with P", x="Percent Features Tried at Each Node", y="Training Time (s)")
p <- p + scale_x_continuous(labels = scales::percent_format(accuracy=1))
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
print(p)
dev.off()

