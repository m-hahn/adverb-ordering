
mi = read.csv("~/scr/PUKWAC/mis.tsv", sep="\t", header=F, quote='')   
names(mi) <- c("Adverb", "MI")  

pmi = read.csv("~/scr/PUKWAC/pmis.tsv", sep="\t", header=F, quote='')   
names(pmi) <- c("Adverb", "Verb", "PMI")  

adverbPairs = read.csv("~/scr/PUKWAC/adverbPairsWithVerb", sep="\t", header=F, quote='')  
names(adverbPairs) <- c("Adverb_1", "Adverb_2", "Verb", "Frequency")    
marginal_adv = read.csv("~/scr/PUKWAC/marginalPerAdverb", sep="\t", header=F, quote='')
names(marginal_adv) <- c("Adverb", "Frequency")


adverbPairs2 = adverbPairs %>% rename(Adverb_1_=Adverb_2, Adverb_2_=Adverb_1) %>% rename(Adverb_1=Adverb_1_, Adverb_2=Adverb_2_)

adverbPairs = rbind(adverbPairs %>% mutate(Flipped=FALSE), adverbPairs2 %>% mutate(Flipped=TRUE))


data = merge(mi %>% rename(Adverb_1=Adverb, MI_1=MI), adverbPairs, by=c("Adverb_1"), all.y=TRUE) 
data = merge(mi %>% rename(Adverb_2=Adverb, MI_2=MI), data, by=c("Adverb_2"), all.y=TRUE) 
data = merge(pmi %>% rename(Adverb_2=Adverb, PMI_1=PMI), data, by=c("Adverb_2", "Verb"), all.y=TRUE) 
data = merge(pmi %>% rename(Adverb_1=Adverb, PMI_2=PMI), data, by=c("Adverb_1", "Verb"), all.y=TRUE) 


data = data %>% mutate(PMIDiff = PMI_1-PMI_2)
data = data %>% mutate(MIDiff = MI_1-MI_2)
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


cinque = c("frankly", "fortunately", "allegedly", "probably", "once", "then", "perhaps", "wisely", "usually", "already", "always", "completely", "well")
cinque_rank = (1:13)

dataCinque = data.frame(Adverb = cinque, Rank = cinque_rank)

data2_C = merge(data, dataCinque %>% rename(Adverb_1=Adverb, Rank_1=Rank))
data2_C = merge(data2_C, dataCinque %>% rename(Adverb_2=Adverb, Rank_2=Rank))
data2_C = data2_C %>% mutate(RankDiff = sign(Rank_1-Rank_2))
data2_C = data2_C %>% filter(!is.na(PMIDiff), !is.na(RankDiff))

model_pmi = (glmer(Flipped ~ PMIDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2_C, weights=data2_C$Frequency))
model_rank = (glmer(Flipped ~ RankDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2_C, weights=data2_C$Frequency))
model_joint = (glmer(Flipped ~ PMIDiff + RankDiff + (1|Adverb_1) + (1|Adverb_2), family="binomial", data=data2_C, weights=data2_C$Frequency))

data2_C$predict_rank = predict(model_rank)
data2_C$predict_pmi = predict(model_pmi)

data2_C$LogLik_pmi = log(1/(1+exp(ifelse(data2_C$Flipped, -data2_C$predict_pmi, data2_C$predict_pmi))))
data2_C$LogLik_rank = log(1/(1+exp(ifelse(data2_C$Flipped, -data2_C$predict_rank, data2_C$predict_rank))))

anova(model_rank, model_pmi)

data2_C$Improvement = data2_C$LogLik_pmi - data2_C$LogLik_rank

(data2_C[order(-data2_C$Improvement*data2_C$Frequency),])[(1:100),]



