### Get data in shape for DSC upload
library(filesstrings)

A = c(301:329)

## copy all data from the Back-up folder without audio files 

setwd("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG")
dirs <- list.dirs()
dirsnew <- NA
for (k in 1:length(dirs)){
  dirsnew[k] <- gsub('(^.)(.+?)', 'ForDSC\\2', dirs[k])
}
dirsnew <- dirsnew[-1]

for (i in 1:length(dirsnew)){
  if (dir.exists(dirsnew[i])){}
  else {
    dir.create(dirsnew[i])
  }
}

for (i in 1: length(A)){
  pNumber <- A[i]
  
  wd1 <- paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/", pNumber, sep="")
  setwd(wd1)
  
  files <- list.files(wd1, pattern = ".txt|.eeg|.vhdr|.vmrk", full.names = TRUE, recursive = TRUE)
  
  for (j in 1:length(files)){
    new_destination <- gsub('(^.+?/STD-Back-Up-Exp2-EEG/)(.+?)', '\\1ForDSC/\\2', files[j])
    
    file.copy(files[j], new_destination)
  }
  
}


### moving files from the subfolders into one folder for "Processed data"

dir.create("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/Preprocessed")

A = c(302:329)

for (i in 1: length(A)){
  
  pNumber <- A[i]
  
  file.remove(paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/", pNumber, "/Day3/", pNumber, "_Behav_Int_2.txt", sep=""))
  file.move(paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/", pNumber, "/Day3/", pNumber, "_Behav_Int.txt", sep=""), "//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/Preprocessed/")
  
  file.move(paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/", pNumber, "/Day3/", pNumber, "_FinalTest/", pNumber, "_Finaltest_new.txt", sep=""), "//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/Preprocessed/")
  file.move(paste("//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/", pNumber, "/Day3/", pNumber, "_FinalTest/", pNumber, "_BehavMatrixFinalTest.txt", sep=""), "//cnas.ru.nl/wrkgrp/STD-Back-Up-Exp2-EEG/ForDSC/Preprocessed/")
  
}
