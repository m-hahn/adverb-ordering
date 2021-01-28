library(tidyr)
library(dplyr)

mi = read.csv("~/CS_SCR/PUKWAC/adj_mis.tsv", sep="\t", header=F, quote='')   
names(mi) <- c("Adjective", "MI")  

adjectivePairs = read.csv("~/CS_SCR/PUKWAC/adjectivePairsWithNoun", sep="\t", header=F, quote='')  
names(adjectivePairs) <- c("Adjective_1", "Adjective_2", "Noun", "Frequency")    
marginal_adv = read.csv("~/CS_SCR/PUKWAC/marginalPerAdjective", sep="\t", header=F, quote='')
names(marginal_adv) <- c("Adjective", "Frequency")


adjectivePairs2 = adjectivePairs %>% rename(Adjective_1_=Adjective_2, Adjective_2_=Adjective_1) %>% rename(Adjective_1=Adjective_1_, Adjective_2=Adjective_2_)

adjectivePairs = rbind(adjectivePairs %>% mutate(Flipped=FALSE), adjectivePairs2 %>% mutate(Flipped=TRUE))


data = merge(mi %>% rename(Adjective_1=Adjective), adjectivePairs, by=c("Adjective_1"), all.y=TRUE) 
data = merge(mi %>% rename(Adjective_2=Adjective), data, by=c("Adjective_2"), all.y=TRUE) 


data2 = data %>% group_by(Adjective_1) %>% summarise(MI = mean(MI.y, na.rm=TRUE), First = 1-sum(Frequency*Flipped)/sum(Frequency), Overall = sum(Frequency)) %>% filter(Adjective_1 != "blah")

library(ggplot2)
plot = ggplot(data2 %>% filter(Overall > 500), aes(x=MI, y=First)) + geom_text(aes(label=Adjective_1)) + geom_smooth(method="glm", method.args=list(family="binomial")) + theme_bw() + theme(legend.position="none", axis.text = element_text(size=20))
plot = ggplot(data2 %>% filter(Overall > 1000), aes(x=MI, y=First)) + geom_text(aes(label=Adjective_1)) + geom_smooth(method="glm", method.args=list(family="binomial")) + theme_bw() + theme(legend.position="none", axis.text = element_text(size=20))

data3 = data2 %>% filter(Overall > 500)
cor(data3$MI, data3$First)

cor(data3$MI, data3$First, method="spearman")


