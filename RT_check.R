### Check RT exclusions 

require(reshape)
require(data.table)
require(plyr)
require(ggplot2)
require(lme4)
require(lmerTest)
require(lmtest)

A = c(301:308, 310:326, 328, 329) # only including the participants that also enter the EEG analysis
list <- data.frame(PP=as.numeric(), 
                   Trial = as.numeric())

for (i in 1:length(A)){
  pNumber = A[i]
  file <-  read.delim(paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/RT_coding/", pNumber,"_logfile_manual.txt", sep=""), header = F)
  wd1 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_FinalTest", sep="")
  infile2 <- paste(pNumber,"Finaltest.txt",sep="_")
  setwd(wd1)
  finaltest <- as.data.frame(read.delim(infile2, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  for (j in 1:nrow(file)){
  if (file$V5[j]==0){
    num <- as.numeric(sub("Trial([0-9].*?)-001", "\\1", file$V4[j]))
    if (is.na(finaltest$Error[num]) == 0 &  finaltest$Error[num] == 0){
      list <- rbind(list, c(pNumber, num))
    }
  }
  }
  
}
