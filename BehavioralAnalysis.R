### Analysis EEG experiment - behavioral data ###

### Loading data ####

require(reshape)
require(data.table)

A = c(301:329)

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
    if (currentFile$Error[j] == 1) {
      currentFile2$Error[pos] <- NA
      currentFile2$VoiceOnset[pos] <- NA
      currentFile2$PhonCorrect[pos]<- NA
      currentFile2$PhonIncorrect[pos]<-NA}
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
      currentFile2$PhonIncorrect[pos]<-NA}
  }
  
  setwd(wd4)
  currentFile4 <- as.data.frame(read.delim(infile4, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  for (j in 1:nrow(currentFile4)) {
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile4$Item[j])))
    if (currentFile4$Known[j] == 1) {
      currentFile2$Error[pos] <- NA
      currentFile2$VoiceOnset[pos] <- NA
      currentFile2$PhonCorrect[pos]<- NA
      currentFile2$PhonIncorrect[pos]<-NA}
  }
  
  data_list2[[i]] <- currentFile2
  
  for (l in 1:nrow(currentFile2)) {
    if (currentFile2$Error[l] == 1 || is.na(currentFile2$Error[l])) {
      currentFile2$ReadIn[l] <- 0
    } else {
      currentFile2$ReadIn[l] <- 1
    }
  }
  
  # safe the new Final test file for the NewMarker.m script
  setwd(wd1)
  outfile = paste(pNumber,"Finaltest_new.txt",sep="_")
  write.table(currentFile2, outfile, row.names = F, col.names = T, sep = "\t")
  
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
