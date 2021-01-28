

mi = read.csv("~/CS_SCR/PUKWAC/adj_mis.tsv", sep="\t", header=F, quote='')   
names(mi) <- c("Adjective", "MI")  
avgLogDist = read.csv("~/CS_SCR/PUKWAC/avgLogDistancePerAdjective", sep="\t", header=F, quote='')  
names(avgLogDist) <- c("Adjective", "AvgLogDist")    
marginal_adj = read.csv("~/CS_SCR/PUKWAC/marginalPerAdjective", sep="\t", header=F, quote='')
names(marginal_adj) <- c("Adjective", "Frequency")

data = merge(mi, avgLogDist, by=c("Adjective"))  
data = merge(data, marginal_adj, by=c("Adjective")) 

cor(data$MI, data$AvgLogDist)   

library(ggplot2)
library(tidyr)
library(dplyr)

plot = ggplot(data %>% filter(Frequency > 500), aes(x=MI, y=AvgLogDist)) + geom_text(aes(label=Adjective))




plot = ggplot(data %>% filter(Frequency > 5000), aes(x=MI, y=AvgLogDist)) + geom_text(aes(label=Adjective)) + theme_bw() + theme(legend.position="none", axis.text = element_text(size=20))

plot = ggplot(data %>% filter(Frequency > 20000), aes(x=MI, y=AvgLogDist)) + geom_text(aes(label=Adjective)) + theme_bw() + theme(legend.position="none", axis.text = element_text(size=20))


cor(data$MI, data$AvgLogDist, method="spearman")

