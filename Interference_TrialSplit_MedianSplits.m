%% Save trials into different datasets for the median split analysis of the interference phase data
clear all
A = [321:326, 328, 329]; % 303, 320 not processed
%A = [320, 328];
for i = 1:length(A)
    cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\') % this is where EEG data is stored 
    pNumber = A(i);
    % define files for this participant
    preprocFile = strcat('PreprocessedData\', num2str(pNumber), '_Interference_data_all_preprocessed');
    % Pic naming 1 subfiles
    low_outPic1_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_low_1');
    high_outPic1_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_high_1');
    low_outPic1_2 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_low_2');
    high_outPic1_2 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_high_2');
    low_outPic1_av = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_low_av');
    high_outPic1_av = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_high_av');
    % Pic naming 2 subfiles
    low_outPic4_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_low_1');
    high_outPic4_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_high_1');
    low_outPic4_2 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_low_2');
    high_outPic4_2 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_high_2');
    low_outPic4_av = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_low_av');
    high_outPic4_av = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_high_av');
    
    % load the preprocessed data
    load(preprocFile, 'data_clean');
    
    % Add behavioral information matrix to the trialinfo matrix for later
    behavFilename = strcat(num2str(pNumber), '\Day3\', num2str(pNumber),'_Behav_Int.txt');
    behav = load(behavFilename); 
    % subset the behavioral matrix to the trials that are also in the
    % preprocessed dataframe 
    C = intersect(data_clean.trialinfo(:,2:3),behav(:,1:2),'rows');
    index_A = find(ismember(behav(:,1:2),C,'rows'));
    behav2 = behav(index_A,:);
    % append the two
    data_clean.trialinfo = [data_clean.trialinfo behav2(:,6:8)];
    
    %% Select trials for further analysis
    cfg=[];
    
    % Picture naming round 1 - split by block 1 
    % lower 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 108) & (data_clean.trialinfo(:,7) == 1));
    low1 = ft_selectdata(cfg, data_clean);
    save(low_outPic1_1, 'low1');
    % upper 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 108) & (data_clean.trialinfo(:,7) == 2));
    up1 = ft_selectdata(cfg, data_clean);
    save(high_outPic1_1, 'up1');
        
    % Picture naming round 1 - split by block 2
    % lower 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 108) & (data_clean.trialinfo(:,8) == 1));
    low2 = ft_selectdata(cfg, data_clean);
    save(low_outPic1_2, 'low2');
    % upper 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 108) & (data_clean.trialinfo(:,8) == 2));
    up2 = ft_selectdata(cfg, data_clean);
    save(high_outPic1_2, 'up2');
        
    % Picture naming round 1 - split by average over blocks 
    % lower 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 108) & (data_clean.trialinfo(:,9) == 1));
    low3 = ft_selectdata(cfg, data_clean);
    save(low_outPic1_av, 'low3');
    % upper 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 108) & (data_clean.trialinfo(:,9) == 2));
    up3 = ft_selectdata(cfg, data_clean);
    save(high_outPic1_av, 'up3');
        
    % Picture naming round 4 split by block 1
    % lower 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,7) == 1));
    low4 = ft_selectdata(cfg, data_clean);
    save(low_outPic4_1, 'low4');
    % upper 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,7) == 2));
    up4 = ft_selectdata(cfg, data_clean);
    save(high_outPic4_1, 'up4');
        
    % Picture naming round 4 split by block 2
    % lower 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,8) == 1));
    low5 = ft_selectdata(cfg, data_clean);
    save(low_outPic4_2, 'low5');
    % upper 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,8) == 2));
    up5 = ft_selectdata(cfg, data_clean);
    save(high_outPic4_2, 'up5');
        
    % Picture naming round 4 split by average over blocks
    % lower 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,9) == 1));
    low6 = ft_selectdata(cfg, data_clean);
    save(low_outPic4_av, 'low6');
    % upper 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,9) == 2));
    up6 = ft_selectdata(cfg, data_clean);
    save(high_outPic4_av, 'up6'); 
    
    % document how many trials were kept for later analysis
    c1 = length(low1.trial);
    c2 = length(up1.trial);
    c3 = length(low2.trial);
    c4 = length(up2.trial);
    c5 = length(low3.trial);
    c6 = length(up3.trial);
    c7 = length(low4.trial);
    c8 = length(up4.trial);
    c9 = length(low5.trial);
    c10 = length(up5.trial);
    c11 = length(low6.trial);
    c12 = length(up6.trial);
    
    % save trial information in txt
    fid = fopen('TrialCount_Interference_PostPreprocessing_MedianSplit.txt','a');
    formatSpec = '%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n';
    fprintf(fid,formatSpec,pNumber,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12);
        
    disp('######################################');
    disp(['## Done PP_', num2str(pNumber),' ########']);
    disp('######################################');
    
    % change this to your Github folder directory
    cd('U:\PhD\EXPERIMENT 2 - EEG\EEG-analysis');  
end  