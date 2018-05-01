% script to change the trial info in the preprocessed data for the second
% round & later on re-segment based on this new trial information
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\');
subjects = [301:308, 310:326, 328, 329];  

for i = 1:length(subjects)
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_FinalTestPart2_data_all_preprocessed');
    dummy = load(filename1);
    behavFilename = strcat(num2str(subjects(i)), '\Day3\', num2str(subjects(i)),'_FinalTest\', num2str(subjects(i)),'_BehavMatrixFinalTest.txt');
    cond1out = strcat('PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1');
    cond2out = strcat('PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2');
    behav = load(behavFilename);
    behav = behav(71:140,:);
    behav = behav(ismember(behav(:,1),dummy.data_clean.trialinfo(:,2)),:);
    dummy.data_clean.trialinfo = [dummy.data_clean.trialinfo(:,1) behav];
    %condition 1
    cfg                 = [];
    cfg.trials          = find((dummy.data_clean.trialinfo(:,9) == 1)& (dummy.data_clean.trialinfo(:,3) == 1)); 
    data_cond1          = ft_selectdata(cfg, dummy.data_clean);
    save(cond1out, 'data_cond1');
    %condition2
    cfg                 = [];
    cfg.trials          = find((dummy.data_clean.trialinfo(:,9) == 1)& (dummy.data_clean.trialinfo(:,3) == 2)); 
    data_cond2          = ft_selectdata(cfg, dummy.data_clean);
    save(cond2out, 'data_cond2');
    % get trial info
    c1 = length(data_cond1.trial);
    c2 = length(data_cond2.trial); 
    % save trial information in txt
    fid = fopen('TrialCount_PostPreprocessing_SecondHalf.txt','a');
    formatSpec = '%d\t%d\t%d\n';
    fprintf(fid,formatSpec,subjects(i),c1,c2);
    disp(['## Done PP ',num2str(subjects(i))]);
end
