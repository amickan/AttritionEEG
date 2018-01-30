function []=CreateNewMarkers(pNumber)
% this function create new marker files for BrainVision analysis
% the following files need to be in the same folder with the m file:
% EEGlogfile
% List coding file in txt format
% old marker file from BrainVision

% read the list coding file, get sentence numbers and codes
lNumber=mod((pNumber-1),4)+1;% calculate the list
dataFileName=strcat('List',int2str(lNumber),'_for_coding.txt');
fid = fopen(dataFileName);
C = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 'headerlines',5);%24 columns
sNumber=C{4}; % sentence number
code=C{8}; % code for the trial: CC, IC, CF, IF
fclose(fid);

dataFileName=strcat(int2str(pNumber),'_logfile.txt');
fid = fopen(dataFileName);
C = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s%s', 'headerlines',5);%12 columns
rScore=C{11}; % response score, 1 for correct, 0 for incorrect
fclose(fid);

% compute the new marker
for i=1:120
    if rScore{i}=='1'
        tempMarker='corresp';
    else
        tempMarker='incresp';
    end
        newMarker(i)= strcat(code(i),'_',tempMarker,'_snr',sNumber{i});
end

% read the old marker file
dataFileName=strcat('EEG_32_Xiaochen_',int2str(pNumber),'_Raw Data.markers');
fid = fopen(dataFileName);
headline1=fgets(fid);
headline2=fgets(fid);
C = textscan(fid, '%s%s%d%d%s','Delimiter',',');
Stimulus=C{1};
Position=C{3};
Length=C{4};
Channel=C{5};
fclose(fid);

% rewrite the new marker file
outFileName=strcat('EEG_32_Xiaochen_',int2str(pNumber),'_Raw Data_newMarker.markers');
fid = fopen(outFileName,'w+');
fprintf(fid,headline1);
fprintf(fid,headline2);
for i=1:120
    temp=[Stimulus{i},', ', newMarker{i},', ', num2str(Position(i)),', ',num2str(Length(i)),', ',Channel{i},'\r\n'];
    fprintf(fid,temp);
end
fclose(fid);