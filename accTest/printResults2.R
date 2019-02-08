# ---
# title: "Accuracy as number of samples grows"
# author: "James Browne"
# date: "May 16 2017"
#output: html_document
# ---

library(ggplot2)

leg <- theme(legend.text = element_text(size = 12), legend.title=element_blank(), plot.title = element_text(size = 16,  face="bold"), plot.subtitle = element_text(size = 12),axis.title.x = element_text(size=12), axis.text.x = element_text(size=12), axis.title.y = element_text(size=12), axis.text.y = element_text(size=12))



mydata <- read.csv(file="bench.csv", header=FALSE, sep=",")
colnames(mydata) <- c("Dataset", "System", "Threads", "RelativeSpeed")

mydata[mydata$Dataset=="MNIST",4] <- mydata[mydata$Dataset=="MNIST",4]/mydata[mydata$Dataset=="MNIST" & mydata$System=="binnedBase" ,4][1]

mydata[mydata$Dataset=="higgs",4] <- mydata[mydata$Dataset=="higgs",4]/mydata[mydata$Dataset=="higgs" & mydata$System=="binnedBase" ,4][1]

mydata[mydata$Dataset=="p53",4] <- mydata[mydata$Dataset=="p53",4]/mydata[mydata$Dataset=="p53" & mydata$System=="binnedBase" ,4][1]


#cols <- c("Ideal"="#000000", "RerF"="#009E73", "XGBoost"="#E69F00", "Ranger"="#0072B2", "RF"="#CC79A7")

png(filename="benchRF.png")

p <- ggplot(mydata, aes(System, RelativeSpeed,color = System, group=System))
p <- p + geom_point(position="jitter")
#p <- p + geom_bar(stat="identity",position=position_dodge())
p <- p +leg + labs(title="Training Times Single Core", x="", y="Relative Training Time", subtitle=paste(""))
p <- p + theme(axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank())
p <- p + facet_grid(Dataset ~ ., scales = "free_y")
print(p)
dev.off()
