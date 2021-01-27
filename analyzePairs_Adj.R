
mi = read.csv("~/CS_SCR/PUKWAC/adj_mis.tsv", sep="\t", header=F, quote='')   
names(mi) <- c("Adjective", "MI")  

pmi = read.csv("~/CS_SCR/PUKWAC/adj_pmis.tsv", sep="\t", header=F, quote='')   
names(pmi) <- c("Adjective", "Noun", "PMI")  

adjectivePairs = read.csv("~/CS_SCR/PUKWAC/adjectivePairsWithNoun", sep="\t", header=F, quote='')  
names(adjectivePairs) <- c("Adjective_1", "Adjective_2", "Noun", "Frequency")    
marginal_adv = read.csv("~/CS_SCR/PUKWAC/marginalPerAdjective", sep="\t", header=F, quote='')
names(marginal_adv) <- c("Adjective", "Frequency")


adjectivePairs2 = adjectivePairs %>% rename(Adjective_1_=Adjective_2, Adjective_2_=Adjective_1) %>% rename(Adjective_1=Adjective_1_, Adjective_2=Adjective_2_)

adjectivePairs = rbind(adjectivePairs %>% mutate(Flipped=FALSE), adjectivePairs2 %>% mutate(Flipped=TRUE))


data = merge(mi %>% rename(Adjective_1=Adjective), adjectivePairs, by=c("Adjective_1"), all.y=TRUE) 
data = merge(mi %>% rename(Adjective_2=Adjective), data, by=c("Adjective_2"), all.y=TRUE) 
data = merge(pmi %>% rename(Adjective_2=Adjective), data, by=c("Adjective_2", "Noun"), all.y=TRUE) 
data = merge(pmi %>% rename(Adjective_1=Adjective), data, by=c("Adjective_1", "Noun"), all.y=TRUE) 


data = data %>% mutate(PMIDiff = PMI.x-PMI.y)
data = data %>% mutate(MIDiff = MI.x-MI.y)
data$PMIDiff.R = resid(lm(PMIDiff~MIDiff, data=data, na.action=na.exclude))

library(lme4)

data2 = data[data$Frequency > 4,] %>% filter(!is.na(MIDiff), !is.na(PMIDiff))

#summary(glmer(Flipped ~ PMIDiff.R + MIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency))

model_mi = (glmer(Flipped ~ MIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency))

model_pmi = (glmer(Flipped ~ PMIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency))

data2$predict_mi = predict(glmer(Flipped ~ MIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency, na.action=na.exclude))
data2$predict_pmi = predict(glmer(Flipped ~ PMIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency, na.action=na.exclude))

data2$LogLik_mi = log(1/(1+exp(ifelse(data2$Flipped, -data2$predict_mi, data2$predict_mi))))
data2$LogLik_pmi = log(1/(1+exp(ifelse(data2$Flipped, -data2$predict_pmi, data2$predict_pmi))))

data2$Improvement = data2$LogLik_pmi - data2$LogLik_mi

(data2[order(-data2$Improvement*data2$Frequency),])[(1:100),]


anova(model_mi, model_pmi)

