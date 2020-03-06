%%% excluding artifacts in later time window %%%

function ResegmentLong(pNumber)
    cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\') % this is where EEG data is stored 

    % define files for this participant
    preprocFile1 = strcat('PreprocessedData_firsthalf_new\', num2str(pNumber), '_FinalTestPart1_data_all_preprocessed');
    preprocFile1long = strcat('PreprocessedData_firsthalf_new\', num2str(pNumber), '_FinalTestPart1_data_all_preprocessed_long');
    cond1out = strcat('PreprocessedData_firsthalf_new\', num2str(pNumber), '_data_clean_1_cond1_long');
    cond2out = strcat('PreprocessedData_firsthalf_new\', num2str(pNumber), '_data_clean_1_cond2_long');
    cond12out = strcat('PreprocessedData_firsthalf_new\', num2str(pNumber), '_data_clean_1_cond1_witherrors_long');
    cond22out = strcat('PreprocessedData_firsthalf_new\', num2str(pNumber), '_data_clean_1_cond2_witherrors_long');
    
    preprocFile2 = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_FinalTestPart2_data_all_preprocessed');
    preprocFile2long = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_FinalTestPart2_data_all_preprocessed_long');
    cond1out2 = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond1_long');
    cond2out2 = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond2_long');
    cond12out2 = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond1_witherrors_long');
    cond22out2 = strcat('PreprocessedData_secondhalf\', num2str(pNumber), '_data_clean_2_cond2_witherrors_long');
    
    %% load data round 1 
    data_all = load(preprocFile1);
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

    % OR PURELY VISUAL 
    % Left lick on a channel name to mark it as bad, right click on a
    % channel name to reverse the marking, at the end press 'quit' NOT the 'X'
    %cfg = [];
    %cfg.alim = 15;
    %cfg.eegscale = 1;
    %cfg.eogscale = 1.5;
    %cfg.keepchannel = 'nan';
    %cfg.method = 'trial';
    %cfg.plotlayout = '1col';
    %data_clean = ft_rejectvisual(cfg, data_clean);
    save(preprocFile1long, 'data_clean');
    
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,9) == 1)& (data_clean.trialinfo(:,3) == 1)); 
    data_cond1          = ft_selectdata(cfg, data_clean);
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,9) == 1)& (data_clean.trialinfo(:,3) == 2)); 
    data_cond2          = ft_selectdata(cfg, data_clean);
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,10) == 1)& (data_clean.trialinfo(:,3) == 1)); 
    data_cond12         = ft_selectdata(cfg, data_clean);
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,10) == 1)& (data_clean.trialinfo(:,3) == 2)); 
    data_cond22         = ft_selectdata(cfg, data_clean);
    
    save(cond1out, 'data_cond1');
    save(cond2out, 'data_cond2');
    save(cond12out, 'data_cond12');
    save(cond22out, 'data_cond22');

    % document how many trials were kept for later analysis
    c1 = length(data_cond1.trial);
    c2 = length(data_cond2.trial);
    c3 = length(data_cond12.trial);
    c4 = length(data_cond22.trial);
    
    % save trial information in txt
    fid = fopen('TrialCount_PostPreprocessing_FirstHalf_New_Long.txt','a');
    formatSpec = '%d\t%d\t%d\t%d\t%d\n';
    fprintf(fid,formatSpec,pNumber,c1,c2,c3,c4);
     
    clear data_all data_clean data_cond1 data_cond2 data_cond12 data_cond22
    
    %% load data round 2 
    data_all = load(preprocFile2);
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

    % OR PURELY VISUAL 
    % Left lick on a channel name to mark it as bad, right click on a
    % channel name to reverse the marking, at the end press 'quit' NOT the 'X'
    %cfg = [];
    %cfg.alim = 15;
    %cfg.eegscale = 1;
    %cfg.eogscale = 1.5;
    %cfg.keepchannel = 'nan';
    %cfg.method = 'trial';
    %cfg.plotlayout = '1col';
    %data_clean = ft_rejectvisual(cfg, data_clean);
    save(preprocFile2long, 'data_clean');
    
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,9) == 1)& (data_clean.trialinfo(:,3) == 1)); 
    data_cond1          = ft_selectdata(cfg, data_clean);
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,9) == 1)& (data_clean.trialinfo(:,3) == 2)); 
    data_cond2          = ft_selectdata(cfg, data_clean);
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,10) == 1)& (data_clean.trialinfo(:,3) == 1)); 
    data_cond12         = ft_selectdata(cfg, data_clean);
    cfg                 = [];
    cfg.trials          = find((data_clean.trialinfo(:,10) == 1)& (data_clean.trialinfo(:,3) == 2)); 
    data_cond22         = ft_selectdata(cfg, data_clean);
    
    save(cond1out2, 'data_cond1');
    save(cond2out2, 'data_cond2');
    save(cond12out2, 'data_cond12');
    save(cond22out2, 'data_cond22');

    % document how many trials were kept for later analysis
    c1 = length(data_cond1.trial);
    c2 = length(data_cond2.trial);
    c3 = length(data_cond12.trial);
    c4 = length(data_cond22.trial);
    
    % save trial information in txt
    fid = fopen('TrialCount_PostPreprocessing_SecondHalf_New_Long.txt','a');
    formatSpec = '%d\t%d\t%d\t%d\t%d\n';
    fprintf(fid,formatSpec,pNumber,c1,c2,c3,c4);
    
    cd('U:\PhD\EXPERIMENT 2 - EEG\EEG-analysis');
end
