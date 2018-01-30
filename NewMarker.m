function []=NewMarker(pNumber)

% read the familiarization file from Day 1 
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day 1');
cd(curdir);
Fam1FileName=strcat(int2str(pNumber),'_Familiarization_Day1.txt');
fid = fopen(Fam1FileName);
C = textscan(fid, '%d%d%d%s%s%s%d%d%d', 'headerlines',1); % 9 columns and 1 headerline
Item1 = C{4};
Known = C{9}; % was a word already known in Italian, 1 == yes, 0 == no
fclose(fid);

% read the familiarization file from Day 3
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day 3\', int2str(pNumber),'_Familiarization');
cd(curdir);
Fam2FileName=strcat(int2str(pNumber),'_IntFamiliarization.txt');
fid = fopen(Fam2FileName);
D = textscan(fid, '%d%d%s%s%s%s%s%d%d%d%d', 'headerlines',1); % 11 columns and 1 headerline
Item2 = D{3};
Unknown = D{11}; % was a word unknown in English, 1 == yes, 0 == no 
fclose(fid);

% read the final test file from Day 3
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day 3\', int2str(pNumber),'_FinalTest');
cd(curdir);
FinalTestFileName=strcat(int2str(pNumber),'_FinalTest.txt');
fid = fopen(FinalTestFileName);
headline21=fgets(fid); % read and safe the header of the file for later
E = textscan(fid, '%d%d%d%s%s%s%d%d%d%d%d%d%s%d'); % 14 columns and 1 headerline
Subj = E{1};
Block = E{2};
Trial = E{3};
Item3 = E{4};
LbNL = E{5};
label = E{6};
Cond = E{7};
VoiceOnset = E{8};
Marker = E{9};
Error = E{10};
PhonCorr = E{11};
PhonIncorr = E{12};
Produced = E{13};
TypeError = E{14};
fclose(fid);

% read the old marker file
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day 3\EEG');
cd(curdir);
dataFileName=strcat(int2str(pNumber),'.vmrk');
fid = fopen(dataFileName);
headline1=fgets(fid);
headline2=fgets(fid);
headline3=fgets(fid);
headline4=fgets(fid);
headline5=fgets(fid);
headline6=fgets(fid);
headline7=fgets(fid);
headline8=fgets(fid);
headline9=fgets(fid);
headline10=fgets(fid);
headline11=fgets(fid);
F = textscan(fid, '%s%s%d%d%d','Delimiter',',');
Stimulus=F{1};
OldMarker=F{2};
Position=F{3};
Length=F{4};
Channel=F{5};
fclose(fid);

% sort all three vectors to have the same order (based on the Items order)
[~,Item1sort]=sort(Item1);
[~,Item2sort]=sort(Item2);
Item31 = Item3(1:70);
[~,Item31sort]=sort(Item31);
Item3sort = [Item31sort;(Item31sort+70)];

Knowncopy=Known(Item1sort);
Unknowncopy=Unknown(Item2sort);
Errorcopy=Error(Item3sort);

% compute the new FinalTest error column 
NewError = Errorcopy;
for k=1:70
    if Knowncopy(k)=='1' || Unknowncopy(k)=='1'
        NewError(k) = '1';
        NewError(k+70)= '1';
    end
end

% safe the new finaltest file with an additional column
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day 3\', int2str(pNumber),'_FinalTest');
cd(curdir);
outFileName=strcat(int2str(pNumber),'_FinalTest_new.txt');
fid = fopen(outFileName,'w+');
CC = {headline21,'NewError'};
headline21 = strjoin(CC, '\t');
fprintf(fid,headline21);
for i=1:140
    fprintf(fid, '%d\t%d\t%d\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%d\t%s\r\n', Subj(i),Block(i),Trial(i),Item3{i} ,LbNL{i},label{i} ,Cond(i), VoiceOnset(i) , Marker(i) ,Error(i) ,PhonCorr(i),PhonIncorr(i) ,Produced{i},TypeError(i),NewError{i});
end
fclose(fid);

% compute the new marker
% this does not yet work!
for i=1:length(OldMarker)
    % somehow jump the first I don't know how many lines that do not belong
    % to the final test
    for k=1:140
    if Known{k}=='1' && Unknown{k}=='1'
        tempMarker='1';
    else
        tempMarker='1';
    end
    end
    % somehow put the temp marker into the oldMarker to create the
    % NewMarker vector 
end

% rewrite the new marker file
outFileName=strcat(int2str(pNumber),'.vmrk');
fid = fopen(outFileName,'w+');
fprintf(fid,headline1);
fprintf(fid,headline2);
fprintf(fid,headline3);
fprintf(fid,headline4);
fprintf(fid,headline5);
fprintf(fid,headline6);
fprintf(fid,headline7);
fprintf(fid,headline8);
fprintf(fid,headline9);
fprintf(fid,headline10);
fprintf(fid,headline11);

for i=1:length(Position)
    temp=[Stimulus{i},', ', NewMarker{i},', ', num2str(Position(i)),', ',num2str(Length(i)),', ',Channel{i},'\r\n'];
    fprintf(fid,temp);
end

fclose(fid);