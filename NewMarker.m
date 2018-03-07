function []=NewMarker(pNumber)

% read the final test file from Day 3
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day3\', int2str(pNumber),'_FinalTest');
cd(curdir);
FinalTestFileName=strcat(int2str(pNumber),'_FinalTest_new.txt');
fid = fopen(FinalTestFileName);
headline21=fgets(fid); % read and safe the header of the file for later
E = textscan(fid, '%d%d%d%s%s%s%d%s%d%s%s%s%s%d%d'); % 14 columns and 1 headerline
Item = E{4};
Cond = E{7};
Marker = E{9};
ReadIn = E{15}; % 1 for include data and 0 for do not include data
fclose(fid);

% read the old marker file
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day3\EEG');
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
headline12=fgets(fid);
headline13=fgets(fid);
F = textscan(fid, '%s%s%d%d%d','Delimiter',',');
Stimulus=F{1};
OldMarker=F{2};
Position=F{3};
Length=F{4};
Channel=F{5};
fclose(fid);

% compute the new marker
k = 1;
for i=1:length(OldMarker)
    if (strcmp(OldMarker{i},'S205') == 1) || strcmp(OldMarker{i},'S207') == 1 || strcmp(OldMarker{i},'S217') == 1 || (strcmp(OldMarker{i},'S206')==1 || strcmp(OldMarker{i},'S215') == 1) || (strcmp(OldMarker{i},'S216')==1)
         if (ReadIn(k)==1 && k < 71)
            OldMarker{i}='S205'; % usuable trial
            k = k+1;
         elseif (ReadIn(k)==1 && k > 70)
            OldMarker{i}='S215'; % usuable trial
            k = k+1;
         elseif (ReadIn(k)==0 && k < 71)
            OldMarker{i}='S206'; % not-usable trial
            k = k+1;
         elseif (ReadIn(k)==0 && k > 70)
            OldMarker{i}='S216'; % not-usable trial
            k = k+1;
         end
    end
end 

% rewrite the new marker file
curdir = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\', int2str(pNumber),'\Day3\EEG');
cd(curdir);
outFileName=strcat(int2str(pNumber),'_new.vmrk');
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
fprintf(fid,strrep(headline11, '\', '\\'));
fprintf(fid,headline12);
fprintf(fid,headline13);

for i=1:length(OldMarker)
    temp=[Stimulus{i},',', OldMarker{i},',', num2str(Position(i)),',',num2str(Length(i)),',',num2str(Channel(i)),'\r\n'];
    fprintf(fid,temp);
end

fclose(fid);

% change this to your Github folder directory
cd('U:\PhD\EXPERIMENT 2 - EEG\EEG-analysis');  