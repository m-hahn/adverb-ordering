

mi = read.csv("~/CS_SCR/PUKWAC/mis.tsv", sep="\t", header=F, quote='')   
names(mi) <- c("Adverb", "MI")  
avgLogDist = read.csv("~/CS_SCR/PUKWAC/avgLogDistancePerAdverb", sep="\t", header=F, quote='')  
names(avgLogDist) <- c("Adverb", "AvgLogDist")    
marginal_adv = read.csv("~/CS_SCR/PUKWAC/marginalPerAdverb", sep="\t", header=F, quote='')
names(marginal_adv) <- c("Adverb", "Frequency")

data = merge(mi, avgLogDist, by=c("Adverb"))  
data = merge(data, marginal_adv, by=c("Adverb")) 

cor(data$MI, data$AvgLogDist)   

library(ggplot2)
library(tidyr)
library(dplyr)

plot = ggplot(data %>% filter(Frequency > 500), aes(x=MI, y=AvgLogDist)) + geom_text(aes(label=Adverb))


cinque = c("frankly", "fortunately", "allegedly", "probably", "once", "then", "perhaps", "wisely", "usually", "already", "always", "completely", "well")

plot = ggplot(data %>% filter(Frequency > 1000) %>% mutate(Cinque = (Adverb %in% cinque)), aes(x=MI, y=AvgLogDist, color=Cinque)) + geom_text(aes(label=Adverb)) + theme_bw() + theme(legend.position="none")




