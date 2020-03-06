%%% excluding artifacts in later time window %%%

function ResegmentIntLong(pNumber)
    cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\') % this is where EEG data is stored 

    % preprocessed data
    preprocFile = strcat('PreprocessedData\', num2str(pNumber), '_Interference_data_all_preprocessed');
    preprocFilelong = strcat('PreprocessedData\', num2str(pNumber), '_Interference_data_all_preprocessed_long');
    
    % Pic naming 1 subfiles
    low_outPic1_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_low_1_long');
    high_outPic1_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_mediansplit_high_1_long');
    
    % Pic naming 4 subfiles
    low_outPic4_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_low_1_long');
    high_outPic4_1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_mediansplit_high_1_long');

    %% load data round 1 
    data_all = load(preprocFile);
    data_all = data_all.data_clean;
    
    % manual artifact rejection by visual inspection of each trial
    cfg.viewmode                = 'vertical';
    cfg.selectmode              = 'markartifact';
    cfg.eegscale                = 1;
    cfg.eogscale                = 1.5;
    cfg.layout                  = 'actiCAP_64ch_Standard2.mat';
    cfg                         = ft_databrowser(cfg, data_all); 
    
    % once all rejections have been made
    cfg.artfctdef.reject        = 'complete';                                          % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
    cfg.artfctdef.crittoilim    = [-0.5 1.5];                                            % rejects trial only when artifact is within a certain time window of itnerest
    data_clean                  = ft_rejectartifact(cfg, data_all); 
    
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
    
    save(preprocFilelong, 'data_clean');
    
    %% segment data into conditions for analysis 
    
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
    
    % Picture naming round 4 split by block 1
    % lower 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,7) == 1));
    low4 = ft_selectdata(cfg, data_clean);
    save(low_outPic4_1, 'low4');
    % upper 
    cfg.trials = find((data_clean.trialinfo(:,5) == 1)& (data_clean.trialinfo(:,1) == 138) & (data_clean.trialinfo(:,7) == 2));
    up4 = ft_selectdata(cfg, data_clean);
    save(high_outPic4_1, 'up4');
    
    c1 = length(low1.trial);
    c2 = length(up1.trial);
    c3 = length(low4.trial);
    c4 = length(up4.trial);
    
    % save trial information in txt
    fid = fopen('TrialCount_Interference_PostPreprocessing_MedianSplit_long.txt','a');
    formatSpec = '%d\t%d\t%d\t%d\t%d\n';
    fprintf(fid,formatSpec,pNumber,c1,c2,c3,c4);
        
    disp('######################################');
    disp(['## Done PP: ', num2str(pNumber),' ########']);
    disp('######################################');
    
    % change this to your Github folder directory
    cd('U:\PhD\EXPERIMENT 2 - EEG\EEG-analysis');  
   
end
