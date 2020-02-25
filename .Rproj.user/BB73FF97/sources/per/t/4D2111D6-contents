## Item summary for EEG experiment 

# Dutch frequency 
dutch <- read.delim("U:/PhD/EXPERIMENT 2 - EEG/Dutch_frequencies.txt", header = F, stringsAsFactors = F, sep = "\\")

master <- read.delim("//cnas.ru.nl/wrkgrp/STD-Beatrice_MSc/ListMaking/Masterfile_Exp2.txt")

max(dutch$V2) # mean log frequency
sd(dutch$V3) # mean frequency per million

colnames(dutch)[1] <- "Dutch"

combined <- merge(dutch, master, by = "Dutch")

tapply(combined$V2, combined$Condition, mean)
