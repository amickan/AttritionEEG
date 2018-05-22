### Analysis EEG experiment - behavioral data ###

### Loading data ####

require(reshape)
require(data.table)

#A = c(301:329)
A = c(301:308, 310:326, 328, 329) # only including the participants that also enter the EEG analysis

data_list <- list()
data_list2 <- list()

for (i in 1:length(A)){
  pNumber = A[i]
  wd1 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_FinalTest", sep="")
  wd2 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day2/",pNumber,"_Posttest_Day2", sep="")
  wd3 <- paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_Familiarization", sep="")
  wd4 <- paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day1/", sep="")
  infile1 <- paste(pNumber,"Posttest_Day2.txt",sep="_")
  infile2 <- paste(pNumber,"Finaltest.txt",sep="_")
  infile3 <- paste(pNumber, "IntFamiliarization.txt", sep="_")
  infile4 <- paste(pNumber, "Familiarization_Day1.txt", sep="_")
  
  behav <- matrix(NA,140,9)
  
  setwd(wd2)
  currentFile <- as.data.frame(read.delim(infile1, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  #as.numeric(gsub(",",".", currentFile$RT_new))
  if (length(currentFile[currentFile$Error == 999,]$Error) > 0){
    currentFile[currentFile$Error == 999,]$Error<-1
  }
  data_list[[i]] <- currentFile
  
  setwd(wd1)
  currentFile2 <- as.data.frame(read.delim(infile2, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  ## marking unlearned words as missing values in posttest ##
  for (j in 1:nrow(currentFile)) {
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile$Item[j])))
    behav[pos,1] <- currentFile2$Trial_nr[pos]
    behav[pos,2]<- currentFile2$Condition[pos]
    behav[pos,3]<- currentFile2$VoiceOnset[pos]
    behav[pos,4]<- currentFile2$TypeError[pos]
    if (currentFile$Error[j] == 1) {
      currentFile2$Error[pos] <- NA
      currentFile2$VoiceOnset[pos] <- NA
      currentFile2$RT_new[pos] <- NA
      currentFile2$PhonCorrect[pos]<- NA
      currentFile2$PhonIncorrect[pos]<-NA
      behav[pos,5]<- 1
      behav[pos,9]<- 0} else {
      behav[pos,5]<- 0
      behav[pos,9]<- 1
      }
  }
  
  if (length(currentFile2[ifelse(is.na(currentFile2$Error),
                                 1,currentFile2$Error) == 999,]$Error) > 0) {
    currentFile2[ifelse(is.na(currentFile2$Error),
                        1,currentFile2$Error) == 999,]$Error<-1
  }
  if (length(currentFile2[ifelse(is.na(currentFile2$Error),
                                 1,currentFile2$Error) == 1,]$VoiceOnset) > 0) {
    currentFile2[ifelse(is.na(currentFile2$Error),
                        1,currentFile2$Error) == 1,]$VoiceOnset <- NA # this excludes words that were produced with errors after interference from RT analysis
    
  }
  
  if (length(currentFile2[ifelse(is.na(currentFile2$Error),
                                 1,currentFile2$Error) == 1,]$RT_new) > 0) {
    currentFile2[ifelse(is.na(currentFile2$Error),
                        1,currentFile2$Error) == 1,]$RT_new <- NA # this excludes words that were produced with errors after interference from RT analysis
    
  }
  
  setwd(wd3)
  currentFile3 <- as.data.frame(read.delim(infile3, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  for (j in 1:nrow(currentFile3)) {
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile3$Item[j])))
    if (currentFile3$Error[j] == 1) {
      currentFile2$Error[pos] <- NA
      currentFile2$VoiceOnset[pos] <- NA
      currentFile2$RT_new[pos] <- NA
      currentFile2$PhonCorrect[pos]<- NA
      currentFile2$PhonIncorrect[pos]<-NA
      behav[pos,6]<-1
      behav[pos,9]<- 0} else{
      behav[pos,6]<-0}
  }
  
  setwd(wd4)
  currentFile4 <- as.data.frame(read.delim(infile4, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  for (j in 1:nrow(currentFile4)) {
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile4$Item[j])))
    if (currentFile4$Known[j] == 1) {
      currentFile2$Error[pos] <- NA
      currentFile2$VoiceOnset[pos] <- NA
      currentFile2$RT_new[pos] <- NA
      currentFile2$PhonCorrect[pos]<- NA
      currentFile2$PhonIncorrect[pos]<-NA
      behav[pos,7]<-1
      behav[pos,9]<- 0} else{
      behav[pos,7]<-0}
  }
  
  data_list2[[i]] <- currentFile2
  
  for (l in 1:nrow(currentFile2)) {
    if (currentFile2$Error[l] == 1 || is.na(currentFile2$Error[l])) {
      currentFile2$ReadIn[l] <- 0
      behav[l,8]<-0
    } else {
      currentFile2$ReadIn[l] <- 1
      behav[l,8]<-1
    }
  }
  
  for (l in 1:nrow(behav)) {
    if (is.na(behav[l,6]) == T) {
      behav[l,6] <- 0
    }
  }
  
  # safe the new Final test file for the NewMarker.m script
  setwd(wd1)
  outfile = paste(pNumber,"Finaltest_new.txt",sep="_")
  write.table(currentFile2, outfile, quote = F, row.names = F, col.names = T, sep = "\t")
  
  # safe the file with the relevant behavioral information as text (for preprocessing script)
  # columns as follows: TrialNr, Condition, VoiceOnset, TypeError, Not learned in Spanish, unknown in English, known in Italian, Read in
  setwd(wd1)
  outfile2 = paste(pNumber,"BehavMatrixFinalTest.txt",sep="_")
  write.table(behav, outfile2, quote = F, row.names = F, col.names = F, sep = "\t")
  
  print(A[i])
  
}

pre <- rbindlist(data_list)
post <- rbindlist(data_list2)

post$Subject_nr <- as.factor(post$Subject_nr)
post$Condition <- as.factor(post$Condition)
post$Item <- as.factor(post$Item)
post$Block <- as.factor(post$Block)

# leaving out RTs under 2000ms
post[post$RT_new < 2000,]$RT_new <- NA
# log-transforming the NEW and OLD RTs
post$RTlog <- log(post$VoiceOnset-2000)
post$RT_new_log <- log(post$RT_new-2000)

# calculating ratio
post$Total <- post$PhonCorr+post$PhonIncorr
post$Ratio <- (post$PhonCorr/post$Total)*100

# subset to only the first round of Final test
post1 <- post[post$Trial_nr<71,]
post2 <- post[post$Trial_nr>70,]

########## Plots with GGplot ###########
require(plyr)
require(ggplot2)

### Fine-grained error rates ###

# histogram of results 
hist(post$Ratio)

ddply(post1, .(Condition, Subject_nr), 
      summarise, N=length(Ratio), 
      mean   = mean(Ratio, na.rm = TRUE), 
      sem = sd(Ratio, na.rm = TRUE)/sqrt(N)) -> aggregatedRatio

aggregated_means_ratio <- ddply(post1, .(Condition), 
                                summarise,
                                condition_mean = mean(Ratio,na.rm = T),
                                condition_sem = sd(Ratio,na.rm = T)/sqrt(length(Ratio[!is.na(Ratio)])))

aggregatedRatio <- merge(aggregatedRatio, aggregated_means_ratio, by = c("Condition"))

lineplot <- ggplot(aggregatedRatio, aes(y = mean, x = Condition, group = Subject_nr))
lineplot + geom_point(color="darkgrey") +
  geom_line(color="darkgrey") +
  geom_point(aes(y = condition_mean,
                 color = Condition), color="black") +
  geom_text(aes(label=Subject_nr)) +
  geom_line(aes(y = condition_mean,color="red")) +
  geom_errorbar(aes(ymin=condition_mean-condition_sem,
                    ymax=condition_mean+condition_sem,
                    color = "red",
                    na.rm = T),
                    width = 0.5) +
  theme(axis.text = element_text(size = 20), axis.title = element_text(size = 20)) + 
  scale_x_discrete(labels=c("Interference", "No interference"), breaks = 1:2, expand = c(0.1,0.1)) +
  ylab("Percentage correctly recalled words in Spanish") +
 # scale_color_manual(guide=F, "Frequency Condition", values=c("dodgerblue4","firebrick"),labels=c("High","Low")) +
  theme_bw()

barplot <- ggplot(aggregated_means_ratio, aes(y = condition_mean, x = Condition, fill = Condition))
barplot + geom_bar(stat="identity", position=position_dodge()) +
  geom_errorbar(aes(ymin=condition_mean-condition_sem,
                    ymax=condition_mean+condition_sem),
                width = 0.5, position=position_dodge(0.9)) +
  theme(axis.text = element_text(size = 20), axis.title = element_text(size = 20)) + 
  coord_cartesian(ylim=c(80,100)) +
  scale_x_discrete(labels=c("Interference", "No Interference"), breaks = 1:2, expand = c(0.1,0.1)) +
  ylab("Percentage correctly recalled words in Italian") +
  scale_fill_grey(labels=c("Interference","No Interference")) +
  theme_bw()

###### Stats on behavioral results ######

require(lme4)
require(lmerTest)
require(lmtest)

setwd("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/")
lenwords <- read.delim("WordsLengths.txt")
post$OrigLen <- NA

for (j in 1:nrow(post)) {
  pos <- which(tolower(as.character(lenwords$English)) == tolower(as.character(post$Item[j])))
  post$OrigLen[j] <- lenwords[pos,3] #}
  print(j)
  rm(pos)
}

post$CorrPer <- round(post$PhonCorrect/post$Total,2)
post$Corr <- round(post$CorrPer*post$OrigLen,0)
#post$Corr <- round(post$CorrPer*post$PhonCorrect,0)
post$Incorr <- post$OrigLen-post$Corr

# setting contrasts to the mean of each condition 
contrasts(post$Condition) <- c(-0.5,0.5)
contrasts(post$Block) <- c(-0.5,0.5)

# turning my factors into numerical factors reflecting a dummy coding 
post$ConditionN <- (-(as.numeric(post$Condition)-2))-0.5
post$BlockN <- (as.numeric(post$Block)-1)-0.5

###### Accuracy after interference #####

## Full model with maximal random effects structure
modelfull1 <- glmer(cbind(Corr, Incorr) ~ ConditionN*BlockN + (1|Item) + (1+BlockN*ConditionN|Subject_nr), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post)
summary(modelfull)
# the model converges with the maximal justifyable random effects structure, and none of the random effects are highly correlated with each other, so we leave it this complex 
# no comparisons needed, you report the beta weights from this model in a table in your paper


## There is no interaction of round and condition in the full model, so we technically we can't analyse rounds seperately, I will still do it below and I think you can still justify looking at the first round seperately based on our hypothesis
## Round 1
modelround1b <- glmer(cbind(Corr, Incorr) ~ ConditionN + (1|Item) + (1+ConditionN|Subject_nr), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post[post$Block==1,])
summary(modelround1b)
## Round 2
modelround2b <- glmer(cbind(Corr, Incorr) ~ ConditionN + (1|Item) + (1+ConditionN|Subject_nr), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post[post$Block==2,])
summary(modelround2b)

## Simple Anova for accuracy
## Arcsine transformed data Anova
post$NewRatio <- asin(sqrt(post$Ratio/100))
anova_ratio <- aov(NewRatio ~ Condition*Block, data = post)
#anova_ratio <- aov(NewRatio ~ Condition, data = post[post$Block==1,]) # this is if you wanna look at one block only
summary(anova_ratio)

## Model reporting - fullest model above
# It is best to report Chi-square p-values for each of the effects serpately 
# First let's take out the main effect for Condition (-Condition below in the code)
modelCondition<- glmer(cbind(Corr, Incorr) ~ ConditionN*BlockN -ConditionN + (1|Item) + (1+ConditionN|Subject_nr), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post)
anova(modelfull, modelCondition)
# The chi-suare p-value from the Anova table is the p-value for the main effect of Condition. This p-value is slightly higher than the one from the model output itself because the distribution against which it is calcualted is different (chi-square vs z-distribution)
# Second, let's take out the main effect for Block
modelBlock<- glmer(cbind(Corr, Incorr) ~ ConditionN*BlockN -BlockN + (1|Item) + (1+ConditionN|Subject_nr), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post)
anova(modelfull, modelBlock)
# The chi-square p-value from the Anova table is the p-value for the main effect of Round/Block
# Finally, let's take out the interaction
modelInteraction<- glmer(cbind(Corr, Incorr) ~ ConditionN*BlockN -ConditionN:BlockN + (1|Item) + (1+ConditionN|Subject_nr), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post)
anova(modelfull, modelInteraction)
#IMPORTANT: the intercept in these models is always the grand mean: the effect over all conditions: mean over the mean of each cell. cells being: Interference condition for Block 1, Interference Block 2, No interference Block 1, No interference Block 2
# So now it is not correct anymore what you say in your methods section: the intercept DOES NOT reflect the no interference condition any longer, it represents the mean of both conditions over both blocks!!! 
# The p-values you get out of these comparisons are what you report in the paper and in the table along with the estimates.  

###### Modelling for RTs #####
# simple Anova for RTs (log-transformed)
anova_rt <- aov(RT_new_log ~ Condition*Block, data = post)
summary(anova_rt)

## Full model on log transformed data 
# Full model with maximum random effects structure 
# We take the log of the reaction times because the distribution is very non-normal, and we subtract 2000ms because that's the lowest value there is currently (due to 2s delay), log transform works better if there are values close to 0 and between 0-1
modelRT2full <- lmer(log(RT_new-2000) ~ ConditionN*BlockN + (1|Item) + (1+BlockN*ConditionN|Subject_nr), control=lmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)),data = post)
summary(modelRT2full)
# we continue simplifying the random effects structure, overall, the random effecst don't take out almost any variation, we leave in the simplest, intercept only
# both main effects are significant, the interaction reached marginal significance

### Seperate models for each round (just out of curiosity)
# Round 1
modelRT2round1 <- lmer(log(RT_new-2000) ~ ConditionN + (1|Item) + (1+ConditionN|Subject_nr), control=lmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)),data = post[post$Block==1,])
summary(modelRT2round1)
# Round 2
modelRT2round2 <- lmer(log(RT_new-2000) ~ ConditionN + (1|Item) + (1+ConditionN|Subject_nr), control=lmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)),data = post[post$Block==2,])
summary(modelRT2round2)

## Model reporting - fullest model above
# Same as above
# First let's take out the main effect for Condition (-Condition below in the code)
modelRT2Condition <- lmer(log(RT_new-2000) ~ ConditionN*BlockN - ConditionN + (1|Item) + (1+BlockN*ConditionN|Subject_nr), control=lmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)),data = post)
anova(modelRT2full, modelRT2Condition)
# Second, let's take out the main effect for Block
modelRT2Block <- lmer(log(RT_new-2000) ~ ConditionN*BlockN - BlockN + (1|Item) + (1+BlockN*ConditionN|Subject_nr), control=lmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)),data = post)
anova(modelRT2full, modelRT2Block)
# The chi-square p-value from the Anova table is the p-value for the main effect of Round/Block
# Finally, let's take out the interaction
modelRT2Interaction <- lmer(log(RT_new) ~ ConditionN*BlockN - ConditionN:BlockN + (1|Item) + (1+BlockN*ConditionN|Subject_nr), control=lmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)),data = post)
anova(modelRT2full, modelRT2Interaction)
# IMPORTANT: the intercept in these models is always the grand mean: the effect over all conditions: mean over the mean of each cell. cells being: Interference condition for Block 1, Interference Block 2, No interference Block 1, No interference Block 2
# So now it is not correct anymore what you say in your methods section: the intercept DOES NOT reflect the no interference condition any longer, it represents the mean of both conditions over both blocks!!! 
# The p-values you get out of these comparisons are what you report in the paper and in the table along with the estimates.  

### Forgetting effect ####
# difference between error rates in interference and no interfernce condition
forgetting <- data.frame(tapply(post2$Ratio, list(post2$Subject_nr, post2$Condition), mean, na.rm = T))
forgetting$Difference <- forgetting$X2 - forgetting$X1
forgetting2 <- data.frame(tapply(post2$VoiceOnset, list(post2$Subject_nr, post2$Condition), mean, na.rm = T))
forgetting2$Difference <- forgetting2$X1 - forgetting2$X2
forgetting$ForgettingRT <- forgetting2$Difference
forgetting$Interference_RT <- forgetting2$X1
forgetting$NoInterference_RT <- forgetting2$X2
colnames(forgetting) <- c("Interference_Error", "NoInterference_Error","Difference_Error", "Difference_RT", "Interference_RT","NoInterference_RT")

# read in the EEG average per condition
eeg <- read.delim("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ConditionAverages.txt", header = F)

# add the EEg data to the forgetting matrix
forgetting$EEG_int <- eeg$V2
forgetting$EEG_noint <- eeg$V3
forgetting$EEG_diff <- eeg$V2-eeg$V3

# calculate correlation of eeg difference and forgetting effect (accuracy and RTs seperately)
library(Hmisc)
rcorr(as.matrix(forgetting), type="pearson")
# plot correlation 
ggplot(forgetting, aes(x=Difference_Error, y=EEG_diff),label=row.names(forgetting)) +
  geom_point() +
  geom_text(aes(label=row.names(forgetting)),hjust=0, vjust=0) +
  geom_smooth(method='lm') +
  xlab("Accuracy difference between interference and no interference condition") +
  ylab("EEG amplitude difference between conditions (averaged between 200-400ms, over Pz,P1,P2,Poz,Po3,Po4)") +
  labs(title="All participants")

ggplot(forgetting, aes(x=Difference_RT, y=EEG_diff), label=row.names(forgetting)) +
  geom_point() +
  geom_text(aes(label=row.names(forgetting)),hjust=0, vjust=0) +
  geom_smooth(method='lm') +
  xlab("RT difference between interference and no interference condition") +
  ylab("EEG amplitude difference between conditions (averaged between 200-400ms, over Pz,P1,P2,Poz,Po3,Po4)") +
  labs(title="All participants")

# leaving out extreme participants, even though those are the ones driving the behavioral effect
forgetting[-c(3,9,10,11,19,20,24),]->forgettingAcc
forgetting[-c(2,10,11,18,22,24,27),]->forgettingRT

rcorr(as.matrix(forgettingAcc), type="pearson")
rcorr(as.matrix(forgettingRT), type="pearson")
# plot correlation 
ggplot(forgettingAcc, aes(x=Difference_Error, y=EEG_diff),label=row.names(forgettingAcc)) +
  geom_point() +
  geom_text(aes(label=row.names(forgettingAcc)),hjust=0, vjust=0) +
  geom_smooth(method='lm') +
  xlab("Accuracy difference between interference and no interference condition") +
  ylab("EEG amplitude difference between conditions (averaged between 200-400ms, over Pz,P1,P2,Poz,Po3,Po4)") +
  labs(title="Leaving out outliers")

ggplot(forgetting, aes(x=Difference_RT, y=EEG_diff), label=row.names(forgetting)) +
  geom_point() +
  geom_text(aes(label=row.names(forgetting)),hjust=0, vjust=0) +
  geom_smooth(method='lm') +
  xlab("RT difference between interference and no interference condition") +
  ylab("EEG amplitude difference between conditions (averaged between 200-400ms, over Pz,P1,P2,Poz,Po3,Po4)") +
  labs(title="Leaving out outliers")


#### Adaptive learning task ####
# count number of exposure and learning success after the frist two rounds of this test
data_list <- list()
for (i in 1:length(A)){
  pNumber = A[i]
  wd1 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day2/",pNumber,"_AdapPicNaming", sep="")
  setwd(wd1)
  infile1 <- paste(pNumber,"AdapPicNamingDay2.txt",sep="_")
  
  currentFile <- as.data.frame(read.delim(infile1, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  if (length(currentFile[currentFile$Error == 999,]$Error) > 0){
    currentFile[currentFile$Error == 999,]$Error<-1
  }
  
  data_list[[i]] <- currentFile
  
  print(A[i])
}
adap <- rbindlist(data_list)
blocks <- data.frame(tapply(adap$Block_nr, adap$Subject_nr,max)) # how many blocks did the pp go through

#### Exposure per item/pp ####
exposures<-data.frame(table(adap$Item, adap$Condition))
#exposures <- exposures[exposures$Freq != 0,]
exposures$Freq <- exposures$Freq + 11
exposures2<-data.frame(table(adap$Subject, adap$Condition))
exposures2[exposures2$Var2==2,]$Freq <- exposures2[exposures2$Var2==2,]$Freq +8
cond1 <- exposures2[exposures2$Var2==1,]$Freq
cond2 <- exposures2[exposures2$Var2==2,]$Freq
t.test(cond1,cond2)
reshape(exposures2, idvar = "Var1", timevar = "Var2", direction = "wide")


#### Check coherence of errors from round 1 to round 2 ####

