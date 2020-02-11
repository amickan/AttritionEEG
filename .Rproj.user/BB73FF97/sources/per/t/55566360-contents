## RTs from interference phase tasks split by RTs on final test in Italian

require(reshape)
require(data.table)
library("Hmisc")

A = c(301:308, 310:326, 328, 329) # only including the participants that also enter the EEG analysis

data_list <- list()

for (i in 1:length(A)){
  
  pNumber = A[i]
  
  wd1 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_FinalTest", sep="")
  wd2 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_PicNamingIntA", sep="")
  wd3 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_PicNamingIntB", sep="")
  wd4 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/", sep="")
  
  infile1 <- paste(pNumber,"Finaltest_new.txt",sep="_")
  infile2 <- paste(pNumber,"IntPicNaming_A.txt",sep="_")
  infile3 <- paste(pNumber,"IntPicNaming_B.txt",sep="_")
  infile4 <- paste(pNumber,"A_PhonMonitoring.txt",sep="_")
  infile5 <- paste(pNumber,"B_PhonMonitoring.txt",sep="_")
  
  # reading in posttest data 
  setwd(wd1)
  currentFile <- as.data.frame(read.delim(infile1, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  # leaving out RTs under 2000ms
  if (length(currentFile[is.na(currentFile$RT_new) == 0 & currentFile$RT_new < 2000,]$RT_new) > 0){
  currentFile[is.na(currentFile$RT_new) == 0 & currentFile$RT_new < 2000,]$RT_new <- NA}
  
  # log-transforming the new RTs
  currentFile$RT_new_log <- log(currentFile$RT_new-2000)
  
  currentFile1 <- currentFile[1:70,]
  currentFile2 <- currentFile[71:140,]
  
  # reading in data from interference picture naming from 1st and 2nd round 
  setwd(wd2)
  intA <- as.data.frame(read.delim(infile2, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  int1 <- intA[1:70,]
  int2 <- intA[71:140,]
  
  # reading in data from interference picture naming from 3rd and 4th round 
  setwd(wd3)
  intB <- as.data.frame(read.delim(infile3, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  int3 <- intB[1:70,]
  int4 <- intB[71:140,]
  
  # reading in data from interference phoneme 1st round 
  setwd(wd4)
  phonA <- as.data.frame(read.delim(infile4, stringsAsFactors=FALSE, sep = "\t", row.names = NULL, header = T, skipNul = TRUE))
  phonA <- phonA[,-2]
  colnames(phonA)[1] <- "Subject_nr"
  phon1 <- phonA[1:70,]
  phon2 <- phonA[71:140,]
  
  # reading in data from interference phoneme 4th round 
  setwd(wd4)
  phonB <- as.data.frame(read.delim(infile5, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  phon3 <- phonB[1:70,]
  phon4 <- phonB[71:140,]
  
  # subset all dataframes to interference items only 
  currentFile1 <- currentFile1[currentFile1$Condition==1,]
  currentFile2 <- currentFile2[currentFile2$Condition==1,]
  int1 <- int1[int1$Condition==1,]
  int2 <- int2[int2$Condition==1,]
  int3 <- int3[int3$Condition==1,]
  int4 <- int4[int4$Condition==1,]
  phon1 <- phon1[phon1$Condition==1,]
  phon2 <- phon2[phon2$Condition==1,]
  phon3 <- phon3[phon3$Condition==1,]
  phon4 <- phon4[phon4$Condition==1,]
  
  ## sort all datasets alphabetically by item name 
  currentFile1 <- currentFile1[order(currentFile1$Item),]
  currentFile2 <- currentFile2[order(currentFile2$Item),]
  int1 <- int1[order(int1$Item),]
  int2 <- int2[order(int2$Item),]
  int3 <- int3[order(int3$Item),]
  int4 <- int4[order(int4$Item),]
  phon1 <- phon1[order(phon1$Item),]
  phon2 <- phon2[order(phon2$Item),]
  phon3 <- phon3[order(phon3$Item),]
  phon4 <- phon4[order(phon4$Item),]
  
  ## append all dataframes into one big one
  combined <- cbind(currentFile1$RT_new, currentFile2$RT_new, int1$VoiceOnset, int2$VoiceOnset, int3$VoiceOnset, int4$VoiceOnset, phon1$RT, phon2$RT, phon3$RT, phon4$RT)
                    
  ## calculate correlations between items 
  corrmat <- rcorr(as.matrix(combined))
  
  ## save corresponding correlation matrix into list 
  data_list[[i]] <- as.data.frame(corrmat$r)
  
  print(pNumber)
  
}

# get average correlation over participants for the first two columns of each dataframe in data_list
frame1 <- matrix(NA, 10, length(A))
frame2 <- matrix(NA, 10, length(A))
for (i in 1:length(A)){
  frame1[,i] <- data_list[[i]]$V1
  frame2[,i] <- data_list[[i]]$V2
  }

rowMeans (frame1)
rowMeans (frame2)
