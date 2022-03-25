library(tidyr)
library(dplyr)


subjectivity1 = read.csv("subjectivity-trials.csv")
subjectivity2 = read.csv("subjectivity-expanded_results.csv")

subjectivity = rbind(subjectivity1 %>% select(predicate, response), subjectivity2 %>% select(predicate, response)) %>% group_by(predicate) %>% summarise(Subjectivity = mean(response, na.rm=TRUE)) %>% rename(Adjective = predicate)

#data2 = merge(data2, subjectivity %>% rename(Adjective_1=Adjective, Subjectivity_1=subjectivity), by=c("Adjective_1"), all=TRUE)
#data2 = merge(data2, subjectivity %>% rename(Adjective_2=Adjective, Subjectivity_2=subjectivity), by=c("Adjective_2"), all=TRUE)



mi = read.csv("~/scr/PUKWAC/adj_mis.tsv", sep="\t", header=F, quote='')   
names(mi) <- c("Adjective", "MI")  


mi = merge(mi, subjectivity, by=c("Adjective"), all=TRUE)

pmi = read.csv("~/scr/PUKWAC/adj_pmis.tsv", sep="\t", header=F, quote='')   
names(pmi) <- c("Adjective", "Noun", "PMI")  

adjectivePairs = read.csv("~/scr/PUKWAC/adjectivePairsWithNoun", sep="\t", header=F, quote='')  
names(adjectivePairs) <- c("Adjective_1", "Adjective_2", "Noun", "Frequency")    
marginal_adv = read.csv("~/scr/PUKWAC/marginalPerAdjective", sep="\t", header=F, quote='')
names(marginal_adv) <- c("Adjective", "Frequency")


adjectivePairs2 = adjectivePairs %>% rename(Adjective_1_=Adjective_2, Adjective_2_=Adjective_1) %>% rename(Adjective_1=Adjective_1_, Adjective_2=Adjective_2_)

adjectivePairs = rbind(adjectivePairs %>% mutate(Flipped=FALSE), adjectivePairs2 %>% mutate(Flipped=TRUE))


data = merge(mi %>% rename(Adjective_1=Adjective, MI_1=MI, Subjectivity_1=Subjectivity), adjectivePairs, by=c("Adjective_1"), all.y=TRUE) 
data = merge(mi %>% rename(Adjective_2=Adjective, MI_2=MI, Subjectivity_2=Subjectivity), data, by=c("Adjective_2"), all.y=TRUE) 
data = merge(pmi %>% rename(Adjective_2=Adjective, PMI_2=PMI), data, by=c("Adjective_2", "Noun"), all.y=TRUE) 
data = merge(pmi %>% rename(Adjective_1=Adjective, PMI_1=PMI), data, by=c("Adjective_1", "Noun"), all.y=TRUE) 


data = data %>% mutate(PMIDiff = PMI_1-PMI_2)
data = data %>% mutate(MIDiff = MI_1-MI_2)
data = data %>% mutate(SubjDiff = Subjectivity_1-Subjectivity_2)
data$PMIDiff.R = resid(lm(PMIDiff~MIDiff, data=data, na.action=na.exclude))

library(lme4)

data2 = data[data$Frequency > 7,] %>% filter(!is.na(MIDiff), !is.na(PMIDiff))

#summary(glmer(Flipped ~ PMIDiff.R + MIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency))

model_mi = (glmer(Flipped ~ MIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency, na.action=na.exclude))

model_pmi = (glmer(Flipped ~ PMIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=data2, weights=data2$Frequency, na.action=na.exclude))


dataSubj = data2 %>% filter(!is.na(SubjDiff ))

model_subj_2 = (glmer(Flipped ~ SubjDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=dataSubj, weights=dataSubj$Frequency, na.action=na.exclude))
model_pmi_2 = (glmer(Flipped ~ PMIDiff + (1|Adjective_1) + (1|Adjective_2), family="binomial", data=dataSubj, weights=dataSubj$Frequency, na.action=na.exclude))


dataPMIBetter = data %>% filter(!Flipped, SubjDiff < 0, PMIDiff < 0)



data2$predict_mi = predict(model_mi)
data2$predict_pmi = predict(model_pmi)

anova(model_mi, model_pmi)


data2$LogLik_mi = log(1/(1+exp(ifelse(data2$Flipped, -data2$predict_mi, data2$predict_mi))))
data2$LogLik_pmi = log(1/(1+exp(ifelse(data2$Flipped, -data2$predict_pmi, data2$predict_pmi))))

data2$Improvement = data2$LogLik_pmi - data2$LogLik_mi

(data2[order(-data2$Improvement*data2$Frequency),])[(1:100),]



