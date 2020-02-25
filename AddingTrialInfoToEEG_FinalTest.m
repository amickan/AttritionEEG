%% Safe data with errors included from second round Italian test
clear all
A = [301:308, 310:326, 328, 329];

for i = 1:length(A)
    pNumber = A(i);
    % define files for this participant
    cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\') % this is where EEG data is stored 
    % define files for this participant
    preprocFile = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_FinalTestPart2_data_all_preprocessed');
    cond12out = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond1_witherrors');
    cond22out = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond2_witherrors');

    % load the preprocessed data
    load(preprocFile, 'data_clean');
    
    
    %% Cut data in two conditions and save datasets seperately 
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,10) == 1)& (data_clean.trialinfo(:,3) == 1)); 
    data_cond12          = ft_selectdata(cfg, data_clean);
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,10) == 1)& (data_clean.trialinfo(:,3) == 2)); 
    data_cond22          = ft_selectdata(cfg, data_clean);
    
    save(cond12out, 'data_cond12');
    save(cond22out, 'data_cond22');

    % document how many trials were kept for later analysis
    c1 = length(data_cond12.trial);
    c2 = length(data_cond22.trial);
    
    % save trial information in txt
    fid = fopen('TrialCount_PostPreprocessing_SecondHalf_WithErrors.txt','a');
    formatSpec = '%d\t%d\t%d\n';
    fprintf(fid,formatSpec,pNumber,c1,c2);
    
    % change this to your Github folder directory
    cd('U:\PhD\EXPERIMENT 2 - EEG\EEG-analysis');  
end  