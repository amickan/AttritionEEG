### Creating behavioral file for interference phase EEG analysis ###

### Loading data ####

require(reshape)
require(data.table)

#A = c(301:329)
A = c(301:308, 310:326, 328, 329) 

for (i in 1:length(A)){
  pNumber = A[i]
  wd2 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_PicNamingIntA", sep="")
  wd1 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day2/",pNumber,"_Posttest_Day2", sep="")
  wd3 <- paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_Familiarization", sep="")
  wd4 <- paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day1/", sep="")
  wd5 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_PicNamingIntB", sep="")
  wd6 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_FinalTest", sep="")
  infile1 <- paste(pNumber,"Posttest_Day2.txt",sep="_")
  infile2 <- paste(pNumber,"IntPicNaming_A.txt",sep="_")
  infile3 <- paste(pNumber, "IntFamiliarization.txt", sep="_")
  infile4 <- paste(pNumber, "Familiarization_Day1.txt", sep="_")
  infile5 <- paste(pNumber, "IntPicNaming_B.txt", sep="_")
  infile6 <- paste(pNumber,"Finaltest_new.txt",sep="_")
  
  setwd(wd3)
  currentFile <- as.data.frame(read.delim(infile3, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  if (length(currentFile[currentFile$Error == 999,]$Error) > 0){
    currentFile[currentFile$Error == 999,]$Error<-1}
  
  setwd(wd1)
  currentFile2 <- as.data.frame(read.delim(infile1, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  setwd(wd4)
  currentFile3 <- as.data.frame(read.delim(infile4, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  outFile2 <- matrix(NA,210,8)
  
  # for each of the tasks add information on which median split group they belong to (based on the MedianSplit column in the final test file)  
  setwd(wd6)
  currentFile6 <- as.data.frame(read.delim(infile6, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  # Familiarization
  for (j in 1:nrow(currentFile)) {
    outFile2[j,1] <- currentFile$Trial[j]
    outFile2[j,2] <- 1 # Familiarization
    if (currentFile$Condition[j] == 1) {
      outFile2[j,5] <- 1
    } else {
      outFile2[j,5] <- 2}
    
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile$Item[j])))
    pos2 <- which(tolower(as.character(currentFile3$Item )) == tolower(as.character(currentFile$Item[j])))
    if (length(pos)==0 || length(pos2)==0){
      if (currentFile$Error[j] == 1){
        outFile2[j,3] <- 1
        outFile2[j,4] <- 0
      } else {
        outFile2[j,3] <- 1
        outFile2[j,4] <- 1}
    }
    else {
      if (currentFile2$Error[pos] == 1) {
        outFile2[j,3] <- 0 # read in with errors
        outFile2[j,4] <- 0} # read in without errors
      else if (currentFile3$Known[pos2] == 1) {
        outFile2[j,3] <- 0
        outFile2[j,4] <- 0}
      else if (currentFile$Error[j] == 1){
        outFile2[j,3] <- 1
        outFile2[j,4] <- 0
      } else {
        outFile2[j,3] <- 1
        outFile2[j,4] <- 1
      }} 
    
    pos3 <- which(tolower(as.character(currentFile6$Item )) == tolower(as.character(currentFile$Item[j])))
    if (length(pos3)==0){} else {
      outFile2[j,6] <- currentFile6$MedianGroup_1[pos3[1]]
      outFile2[j,7] <- currentFile6$MedianGroup_2[pos3[2]]
      outFile2[j,8] <- currentFile6$MedianGroup_av[pos3[1]]
    }
  }
  
  # PicNaming round 1
  setwd(wd2)
  currentFile4 <- as.data.frame(read.delim(infile2, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  k <- 71
  
  for (j in 1:(nrow(currentFile4)/2)) {
    outFile2[k,1] <- currentFile4$Trial[j]
    outFile2[k,2] <- 2 # PicNaming
    if (currentFile4$Condition[j] == 1) {
      outFile2[k,5] <- 1
    } else {
      outFile2[k,5] <- 2}
    
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile4$Item[j])))
    pos2 <- which(tolower(as.character(currentFile3$Item )) == tolower(as.character(currentFile4$Item[j])))
    if (length(pos)==0 || length(pos2)==0){
      if (currentFile4$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1}
    }
    else {
      if (currentFile2$Error[pos] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile3$Known[pos2] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile4$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1
      }
    }
    
    pos3 <- which(tolower(as.character(currentFile6$Item )) == tolower(as.character(currentFile4$Item[j])))
    if (length(pos3)==0){} else {
      outFile2[k,6] <- currentFile6$MedianGroup_1[pos3[1]]
      outFile2[k,7] <- currentFile6$MedianGroup_2[pos3[2]]
      outFile2[k,8] <- currentFile6$MedianGroup_av[pos3[1]]
    }
    
    k <- k+1}
  
  # PicNaming round 4
  setwd(wd5)
  currentFile5 <- as.data.frame(read.delim(infile5, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  k <- 141
  
  for (j in 71:nrow(currentFile5)) {
    outFile2[k,1] <- currentFile5$Trial[j]
    outFile2[k,2] <- 5 # PicNaming
    if (currentFile5$Condition[j] == 1) {
      outFile2[k,5] <- 1
    } else {
      outFile2[k,5] <- 2}
    
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile5$Item[j])))
    pos2 <- which(tolower(as.character(currentFile3$Item )) == tolower(as.character(currentFile5$Item[j])))
    if (length(pos)==0 || length(pos2)==0){
      if (currentFile5$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1}
    }
    else {
      if (currentFile2$Error[pos] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile3$Known[pos2] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile5$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1
      }}
    
    pos3 <- which(tolower(as.character(currentFile6$Item )) == tolower(as.character(currentFile5$Item[j])))
    if (length(pos3)==0){} else {
      outFile2[k,6] <- currentFile6$MedianGroup_1[pos3[1]]
      outFile2[k,7] <- currentFile6$MedianGroup_2[pos3[2]]
      outFile2[k,8] <- currentFile6$MedianGroup_av[pos3[1]]
    }
    
    k <- k+1
  }
  
  # safe the new file
  wd7 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/",pNumber,"/Day3/",sep="")
  setwd(wd7)
  outfile = paste(pNumber,"Behav_Int.txt",sep="_")
  write.table(outFile2, outfile, quote = F, row.names = F, col.names = F, sep = "\t")
  
  print(A[i])
  
}

### create a file for the middle two naming tasks 

require(reshape)
require(data.table)

A = c(301:329)

for (i in 1:length(A)){
  pNumber = A[i]
  wd2 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_PicNamingIntA", sep="")
  wd1 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day2/",pNumber,"_Posttest_Day2", sep="")
  wd4 <- paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day1/", sep="")
  wd5 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber,"/Day3/",pNumber,"_PicNamingIntB", sep="")
  infile1 <- paste(pNumber,"Posttest_Day2.txt",sep="_")
  infile2 <- paste(pNumber,"IntPicNaming_A.txt",sep="_")
  infile4 <- paste(pNumber, "Familiarization_Day1.txt", sep="_")
  infile5 <- paste(pNumber, "IntPicNaming_B.txt", sep="_")
  
  setwd(wd1)
  currentFile2 <- as.data.frame(read.delim(infile1, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  setwd(wd4)
  currentFile3 <- as.data.frame(read.delim(infile4, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  
  outFile2 <- matrix(NA,140,5)
  
  # PicNaming round 2
  setwd(wd2)
  currentFile4 <- as.data.frame(read.delim(infile2, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  k <- 1
  
  for (j in 71:nrow(currentFile4)) {
    outFile2[k,1] <- currentFile4$Trial[j]
    outFile2[k,2] <- 3 # PicNaming
    if (currentFile4$Condition[j] == 1) {
      outFile2[k,5] <- 1
    } else {
      outFile2[k,5] <- 2}
    
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile4$Item[j])))
    pos2 <- which(tolower(as.character(currentFile3$Item )) == tolower(as.character(currentFile4$Item[j])))
    if (length(pos)==0 || length(pos2)==0){
      if (currentFile4$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1}
    }
    else {
      if (currentFile2$Error[pos] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile3$Known[pos2] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile4$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1
      }
    }
    k <- k+1}
  
  # PicNaming round 3
  setwd(wd5)
  currentFile5 <- as.data.frame(read.delim(infile5, stringsAsFactors=FALSE, sep = "\t", header = T, skipNul = TRUE))
  k <- 71
  
  for (j in 1:(nrow(currentFile5)/2)) {
    outFile2[k,1] <- currentFile5$Trial[j]
    outFile2[k,2] <- 4 # PicNaming
    if (currentFile5$Condition[j] == 1) {
      outFile2[k,5] <- 1
    } else {
      outFile2[k,5] <- 2}
    
    pos <- which(tolower(as.character(currentFile2$Item )) == tolower(as.character(currentFile5$Item[j])))
    pos2 <- which(tolower(as.character(currentFile3$Item )) == tolower(as.character(currentFile5$Item[j])))
    if (length(pos)==0 || length(pos2)==0){
      if (currentFile5$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1}
    }
    else {
      if (currentFile2$Error[pos] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile3$Known[pos2] == 1) {
        outFile2[k,3] <- 0
        outFile2[k,4] <- 0}
      else if (currentFile5$Error[j] == 1){
        outFile2[k,3] <- 1
        outFile2[k,4] <- 0
      } else {
        outFile2[k,3] <- 1
        outFile2[k,4] <- 1
      }}
    k <- k+1
  }
  
  # safe the new file
  wd6 <-  paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/",pNumber,"/Day3/",sep="")
  setwd(wd6)
  outfile = paste(pNumber,"Behav_Int_2.txt",sep="_")
  write.table(outFile2, outfile, quote = F, row.names = F, col.names = F, sep = "\t")
  
  print(A[i])
  
}

