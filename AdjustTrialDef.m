% script to change the trial info in the preprocessed data for the second
% round & later on re-segment based on this new trial information
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\');
subjects = [301:308, 310:326, 328, 329];  

for i = 1:length(subjects)
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_FinalTestPart2_data_all_preprocessed');
    dummy = load(filename1);
    behavFilename = strcat(num2str(pNumber), '\Day3\', num2str(pNumber),'_FinalTest\', num2str(pNumber),'_BehavMatrixFinalTest.txt');
    cond1out = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond1');
    cond2out = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond2');
    behav = load(behavFilename);
    behav = behav(71:140,:);
    dummy.data_cond1.trialinfo = [dummy.data_cond1.trialinfo(:,1) behav];
    %condition 1
    cfg                 = [];
    cfg.trials          = find((dummy.data_cond1.trialinfo(:,9) == 1)& (dummy.data_cond1.trialinfo(:,3) == 1)); 
    data_cond1          = ft_selectdata(cfg, dummy.data_cond1);
    save(cond1out, 'data_cond1');
    %condition2
    cfg                 = [];
    cfg.trials          = find((dummy.data_cond2.trialinfo(:,9) == 1)& (dummy.data_cond2.trialinfo(:,3) == 2)); 
    data_cond2          = ft_selectdata(cfg, dummy.data_cond2);
    save(cond2out, 'data_cond2');
end
