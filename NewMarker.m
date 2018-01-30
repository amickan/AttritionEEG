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
E = textscan(fid, '%d%d%s%s%s%d%d%d%d%d%d%s%d', 'headerlines',1); % 13 columns and 1 headerline
Item3 = E{4};
Error = E{10};
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

% compute the new FinalTest file 
for i=1:140
    if Known{k}=='1' && Unknown{k}=='1'
        ErrorNew = '1';
    else
        ErrorNew = '0';
    end
end

% compute the new marker
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