# ---
# title: "Accuracy as number of samples grows"
# author: "James Browne"
# date: "May 16 2017"
#output: html_document
# ---

library(ggplot2)

leg <- theme(legend.text = element_text(size = 16), legend.title=element_text(size = 16), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))
#leg <- theme(legend.text = element_text(size = 16), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 16),axis.title.x = element_text(size=16), axis.text.x = element_text(size=16), axis.title.y = element_text(size=16), axis.text.y = element_text(size=16))


##############################################################
##############################################################
mydata <- read.csv(file="coreGrow.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "TrainingTime","error","BinThreshold","BinSize")
mydata[,7] <- as.character(mydata[,7])
mydata[,7][mydata[,7]=="0"] <- "No Bin"
mydata[,7] <- as.factor(mydata[,7])

png(filename="coreGrow.png")
p <- ggplot(mydata, aes(Threads, TrainingTime, color=BinSize)) + geom_line()
p <- p + guides(fill = guide_legend(title="Bin\nSize"))
p <- p +leg + labs(title="Bin Parameter Effects on Multicore Training Time", x="Number of Threads (log2)", y="Training Time(s)", subtitle=paste("MNIST, 128 trees"))
p <- p + theme(axis.text.x = element_text(angle = 45, hjust = .5))
p <- p + scale_x_continuous(trans="log2")
p <- p + facet_grid(System ~ .)
print(p)
dev.off()

