### Analysis EEG experiment - behavioral data ###

### Loading data ####

require(reshape)
require(data.table)

A = c(301:329)
#A = c(301:308, 310:326, 328, 329) # only including the participants that also enter the EEG analysis

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
  
  setwd(wd3)
  currentFile3 <- as.data.frame(read.delim(infile3, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  for (j in 1:nrow(currentFile3)) {
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile3$Item[j])))
    if (currentFile3$Error[j] == 1) {
      currentFile2$Error[pos] <- NA
      currentFile2$VoiceOnset[pos] <- NA
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

# log-transforming the RTs
post$RTlog <- log(post$VoiceOnset)

# calculating ratio
post$Total <- post$PhonCorr+post$PhonIncorr
post$Ratio <- (post$PhonCorr/post$Total)*100

# subset to only the first round of Final test
post1 <- post[post$Trial_nr<71,]

########## Plots with GGplot ###########
require(plyr)
require(ggplot2)

### Fine-grained error rates ###

# histogram of results 
hist(post$Ratio)

ddply(post, .(Condition, Subject_nr), 
      summarise, N=length(Ratio), 
      mean   = mean(Ratio, na.rm = TRUE), 
      sem = sd(Ratio, na.rm = TRUE)/sqrt(N)) -> aggregatedRatio

aggregated_means_ratio <- ddply(post, .(Condition), 
                                summarise,
                                condition_mean = mean(Ratio,na.rm = T),
                                condition_sem = sd(Ratio,na.rm = T)/sqrt(length(Ratio[!is.na(Ratio)])))

aggregatedRatio <- merge(aggregatedRatio, aggregated_means_ratio, by = c("Condition"))

lineplot <- ggplot(aggregatedRatio, aes(y = mean, x = Condition, group = Subject_nr))
lineplot + geom_point(color="darkgrey") +
  geom_line(color="darkgrey") +
  geom_point(aes(y = condition_mean,
                 color = Condition), color="black") +
  #geom_text(aes(label=Subject_nr)) +
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
  ylab("Percentage correctly recalled words in Spanish") +
  xlab("Interference condition - high vs. low frequency") +
  scale_fill_manual( "Condition", values=c("red4","grey50"),labels=c("Interference","No Interference")) +
  theme_bw()

### Stats on behavioral results ###

require(lme4)
require(lmerTest)

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

# subset data to only the first round during the FinalTest
post1 <- post[post$Trial_nr<71,]

# random intercept model
model <- glmer(cbind(Corr, Incorr) ~ Condition + (1|Subject_nr) + (1|Item), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post1)
summary(model)

# random slope model
model2 <- glmer(cbind(Corr, Incorr) ~ Condition + (1|Subject_nr) + (1|Item) + (1+Condition|Subject_nr), family = binomial, control=glmerControl(optimizer="bobyqa", optCtrl = list(maxfun = 100000)), data = post1)
summary(model2)

# simple Anova for accuracy
anova_ratio <- aov(Ratio ~ Condition, data = post)
summary(anova_ratio)

### RTs
# simple Anova for RTs (log-transformed)
anova_rt <- aov(RTlog ~ Condition, data = post1)
summary(anova_rt)

# random intercept model for RTs (with a log link) --> does not converge though
modelRT <- glmer(VoiceOnset~ Condition + (1|Subject_nr) + (1|Item), family= poisson(link = "log"), data = post1)
summary(modelRT)

# random intercept model for log-transformed RTs 
modelRT <- lmer(RTlog~ Condition + (1|Subject_nr) + (1|Item), data = post1)
summary(modelRT)

# random slope model for RTs
modelRT2 <- lmer(RTlog~ Condition + (1|Subject_nr) + (1|Item) + (1+Condition|Subject_nr), data = post1)
summary(modelRT2)

### Forgetting effect ####
# difference between error rates in interference and no interfernce condition
forgetting <- data.frame(tapply(post1$Ratio, list(post1$Subject_nr, post1$Condition), mean, na.rm = T))
forgetting$Difference <- forgetting$X2 - forgetting$X1
forgetting2 <- data.frame(tapply(post1$VoiceOnset, list(post1$Subject_nr, post1$Condition), mean, na.rm = T))
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