
mi = read.csv("~/CS_SCR/PUKWAC/mis.tsv", sep="\t", header=F, quote='')   
names(mi) <- c("Adverb", "MI")  

pmi = read.csv("~/CS_SCR/PUKWAC/pmis.tsv", sep="\t", header=F, quote='')   
names(pmi) <- c("Adverb", "Verb", "PMI")  

adverbPairs = read.csv("~/CS_SCR/PUKWAC/adverbPairsWithVerb", sep="\t", header=F, quote='')  
names(adverbPairs) <- c("Adverb_1", "Adverb_2", "Verb", "Frequency")    
marginal_adv = read.csv("~/CS_SCR/PUKWAC/marginalPerAdverb", sep="\t", header=F, quote='')
names(marginal_adv) <- c("Adverb", "Frequency")


adverbPairs2 = adverbPairs %>% rename(Adverb_1_=Adverb_2, Adverb_2_=Adverb_1) %>% rename(Adverb_1=Adverb_1_, Adverb_2=Adverb_2_)

adverbPairs = rbind(adverbPairs %>% mutate(Flipped=FALSE), adverbPairs2 %>% mutate(Flipped=TRUE))


data = merge(mi %>% rename(Adverb_1=Adverb), adverbPairs, by=c("Adverb_1"), all.y=TRUE) 
data = merge(mi %>% rename(Adverb_2=Adverb), data, by=c("Adverb_2"), all.y=TRUE) 
data = merge(pmi %>% rename(Adverb_2=Adverb), data, by=c("Adverb_2", "Verb"), all.y=TRUE) 
data = merge(pmi %>% rename(Adverb_1=Adverb), data, by=c("Adverb_1", "Verb"), all.y=TRUE) 


data = data %>% mutate(PMIDiff = PMI.x-PMI.y)
data = data %>% mutate(MIDiff = MI.x-MI.y)
data$PMIDiff.R = resid(lm(PMIDiff~MIDiff, data=data, na.action=na.exclude))

library(lme4)

data2 = data[data$Frequency > 4,] %>% filter(!is.na(MIDiff), !is.na(PMIDiff))

#summary(glmer(Flipped ~ PMIDiff.R + MIDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2, weights=data2$Frequency))

model_mi = (glmer(Flipped ~ MIDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2, weights=data2$Frequency))

model_pmi = (glmer(Flipped ~ PMIDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2, weights=data2$Frequency))

data2$predict_mi = predict(glmer(Flipped ~ MIDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2, weights=data2$Frequency, na.action=na.exclude))
data2$predict_pmi = predict(glmer(Flipped ~ PMIDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2, weights=data2$Frequency, na.action=na.exclude))

data2$LogLik_mi = log(1/(1+exp(ifelse(data2$Flipped, -data2$predict_mi, data2$predict_mi))))
data2$LogLik_pmi = log(1/(1+exp(ifelse(data2$Flipped, -data2$predict_pmi, data2$predict_pmi))))

data2$Improvement = data2$LogLik_pmi - data2$LogLik_mi

(data2[order(-data2$Improvement*data2$Frequency),])[(1:100),]


anova(model_mi, model_pmi)

