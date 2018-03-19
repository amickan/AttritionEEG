%%% EEG analysis script March 2018 %%%
function PreprocessInt(pNumber)
    cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\') % this is where EEG data is stored 

    % define files for this participant
    vhdr = strcat(num2str(pNumber), '\Day3\EEG\',num2str(pNumber), '.vhdr');
    preprocFile = strcat('PreprocessedData\', num2str(pNumber), '_Interference_data_all_preprocessed');
    cond1outFam = strcat('PreprocessedData\', num2str(pNumber), '_Fam_data_clean_cond1');
    cond2outFam = strcat('PreprocessedData\', num2str(pNumber), '_Fam_data_clean_cond2');
    cond1outPic1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_data_clean_cond1');
    cond2outPic1 = strcat('PreprocessedData\', num2str(pNumber), '_Pic1_data_clean_cond2');
    cond1outPic2 = strcat('PreprocessedData\', num2str(pNumber), '_Pic2_data_clean_cond1');
    cond2outPic2 = strcat('PreprocessedData\', num2str(pNumber), '_Pic2_data_clean_cond2');
    cond1outPic3 = strcat('PreprocessedData\', num2str(pNumber), '_Pic3_data_clean_cond1');
    cond2outPic3 = strcat('PreprocessedData\', num2str(pNumber), '_Pic3_data_clean_cond2');
    cond1outPic4 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_data_clean_cond1');
    cond2outPic4 = strcat('PreprocessedData\', num2str(pNumber), '_Pic4_data_clean_cond2');

    % defining settings for trial selection
    cfg                     = [];
    cfg.dataset             = vhdr;                                 % raw data file name
    cfg.trialfun            = 'ft_trialfun_general';                % selecting only trials with matching event values
    cfg.trialdef.prestim    = 0.5;                                  % time before marker in seconds (should be generous to avoid filtering artifacts)
    cfg.trialdef.poststim   = 1.5;                                  % time after marker in seconds (should be generous to avoid filtering artifacts)
    cfg.trialdef.eventtype  = 'Stimulus';
    cfg.trialdef.eventvalue = {'S18','S19','S108','S109','S118','S119','S128','S129','S138','S139'};
    
    % Define trials (in cfg.trl)
    cfg                     = ft_definetrial(cfg);                  % fieldtrip function that specifies trials
    
    % rereferencing data
    cfg.reref               = 'yes';                                % data will be rereferenced
    cfg.channel             = setdiff(1:64, [12,17,38,44,49,55]);   % in this step only for the EEG channels (including the right mastoid, elec 9)
    cfg.implicitref         = 'Ref';                                % the implicit (non-recorded) reference channel is added to the data representation
    cfg.refchannel          = {'LinkMast', 'Ref'};                  % the average of these channels is used as the new reference
    % create raw eeg data for possible later inspection
    data_eeg_raw            = ft_preprocessing(cfg); 

    % filtering data
    cfg.lpfilter            = 'yes';                                % data will be lowpass filtered
    cfg.lpfreq              = 40;                                   % lowpass frequency in Hz
    cfg.hpfilter            = 'no';                                 % data will NOT be highpass filtered, as this was already done online

    % baseline correction
    cfg.demean              = 'yes';
    %cfg.baselinewindow      = [-0.2 0];                             % data
    

    % apply the set parameters on the data
    data_eeg                = ft_preprocessing(cfg); 
    % only keep the newly created ref channel
    cfg                     = [];
    cfg.channel             = setdiff(1:59, 9);                   % you can use either strings or numbers as selection
    data_eeg                = ft_selectdata(cfg, data_eeg);
    data_eeg_raw            = ft_selectdata(cfg, data_eeg_raw);
    
    %% processing horizontal EOG
    cfgHEOG                     = [];                           % initiate new, empty cfg for the horizontal EOG preprocessing 
    cfgHEOG.dataset             = vhdr;
    cfgHEOG.trialfun            = 'ft_correct_allconditions_trialfun';  % selecting only trials from the final test  
    cfgHEOG.stimmarkers         = {'S208', 'S209'};             % markers marking stimulus events in the final test
    cfgHEOG.marker2             = 'S205';                                % marker for correctness
    cfgHEOG.trialdef.prestim    = 0.5;                          % time before marker in seconds (should be generous to avoid filtering artifacts)
    cfgHEOG.trialdef.poststim   = 1.5;                          % time after marker in seconds (should be generous to avoid filtering artifacts)
    cfgHEOG.reref               = 'yes';
    cfgHEOG.refchannel          = 'EOGleft';
    cfgHEOG.channel             = {'EOGleft', 'EOGright'};      % horizontal EOG channels
    cfgHEOG                     = ft_definetrial(cfgHEOG);
    data_HEOG_raw               = ft_preprocessing (cfgHEOG);   % creating raw data for possible later inspection
    cfgHEOG.bpfilter            = 'yes';
    cfgHEOG.bpfilttype          = 'but';
    cfgHEOG.bpfreq              = [1 15];
    cfgHEOG.bpfiltord           = 4;
    cfgHEOG.demean              = 'yes';
    %cfgHEOG.baselinewindow      = [-0.2 0];                     % data will be baseline corrected in a window from -200ms to stimulus onset
    % apply the set parameters on the data
    data_HEOG                   = ft_preprocessing (cfgHEOG);
    data_HEOG.label{1}          = 'EOGH';                      % rename newly created channel
    data_HEOG_raw.label{1}      = 'EOGH';   
    % only keep the newly created channel
    cfgHEOG                     = [];
    cfgHEOG.channel             = 'EOGH';                      % you can use either strings or numbers as selection
    data_HEOG                   = ft_selectdata(cfgHEOG, data_HEOG);
    data_HEOG_raw               = ft_selectdata(cfgHEOG, data_HEOG_raw);
    
    %checking that EOGleft was referenced to itself
    %figure
    %plot(data_HEOG.time{1}, data_HEOG.trial{1}(1,:));
    %hold on
    %plot(data_HEOG.time{1}, data_HEOG.trial{1}(2,:),'g'); 
    %legend({'EOGleft' 'EOGright'}); 

    %% processing vertical EOG
    cfgVEOG                     = [];
    cfgVEOG.dataset             = vhdr;
    cfgVEOG.trialfun            = 'ft_correct_allconditions_trialfun';  % selecting only trials from the final test  
    cfgVEOG.stimmarkers         = {'S208', 'S209'};             % markers marking stimulus events in the final test
    cfgVEOG.marker2             = 'S205';
    cfgVEOG.trialdef.prestim    = 0.5;                          % time before marker in seconds (should be generous to avoid filtering artifacts)
    cfgVEOG.trialdef.poststim   = 1.5;                          % time after marker in seconds (should be generous to avoid filtering artifacts)
    cfgVEOG.reref               = 'yes';
    cfgVEOG.channel             = {'EOGabove', 'EOGbelow'};
    cfgVEOG.refchannel          = 'EOGabove';
    cfgVEOG                     = ft_definetrial(cfgVEOG);
    data_VEOG_raw               = ft_preprocessing (cfgVEOG);
    cfgVEOG.bpfilter            = 'yes';
    cfgVEOG.bpfilttype          = 'but';
    cfgVEOG.bpfreq              = [1 15];
    cfgVEOG.bpfiltord           = 4;
    cfgVEOG.demean              = 'yes';
    %cfgVEOG.baselinewindow      = [-0.2 0];                     % data will be baseline corrected in a window from -200ms to stimulus onset
    % apply the set parameters on the data
    data_VEOG                   = ft_preprocessing (cfgVEOG);
    data_VEOG.label(2)          = {'EOGV'};                     % rename newly created channel
    data_VEOG_raw.label(2)      = {'EOGV'};
    % only keep the newly created channel
    cfgVEOG                     = [];
    cfgVEOG.channel             = 'EOGV';                      % you can use either strings or numbers as selection
    data_VEOG                   = ft_selectdata(cfgVEOG, data_VEOG);
    data_VEOG_raw               = ft_selectdata(cfgVEOG, data_VEOG_raw);
    
    %checking that EOGabove was referenced to itself
    %figure
    %plot(data_VEOG.time{1}, data_VEOG.trial{1}(1,:));
    %hold on
    %plot(data_VEOG.time{1}, data_VEOG.trial{1}(2,:),'g'); 
    %legend({'EOGabove' 'EOGbelow'}); 

    %% processing Lips
    cfgLips                     = [];
    cfgLips.dataset             = vhdr;
    cfgLips.trialfun            = 'ft_correct_allconditions_trialfun';  % selecting only trials from the final test  
    cfgLips.stimmarkers         = {'S208', 'S209'};             % markers marking stimulus events in the final test
    cfgLips.marker2             = 'S205';
    cfgLips.trialdef.prestim    = 0.5;                          % time before marker in seconds (should be generous to avoid filtering artifacts)
    cfgLips.trialdef.poststim   = 1.5;                          % time after marker in seconds (should be generous to avoid filtering artifacts)
    cfgLips.reref               = 'yes';
    cfgLips.channel             = {'LipUp', 'LipLow'};
    cfgLips.refchannel          = 'LipUp';
    cfgLips.bpfilter            = 'yes';
    cfgLips.bpfilttype          = 'but';
    cfgLips.bpfreq              = [110 140];
    cfgLips.bpfiltord           = 8;
    cfgLips.demean              = 'yes';
    %cfgLips.baselinewindow      = [-0.2 0];                     % data will be baseline corrected in a window from -200ms to stimulus onset
    cfgLips                     = ft_definetrial(cfgLips);
    % apply the set parameters on the data
    data_lips                   = ft_preprocessing (cfgLips);
    data_lips.label{1}          = 'LIPS';                      % rename newly created channelcfg.dataset = vhdr ;
    % only keep the newly created channel
    cfgLips                     = [];
    cfgLips.channel             = 'LIPS';                      % you can use either strings or numbers as selection
    data_lips                   = ft_selectdata(cfgLips, data_lips);
    
    %checking that LipUp was referenced to itself
    %figure
    %plot(data_lips.time{1}, data_lips.trial{1}(1,:));
    %hold on
    %plot(data_lips.time{1}, data_lips.trial{1}(2,:),'g'); 
    %legend({'LipUp' 'LipLow'}); 

    %% Combining all the preprocessed data into one dataset
    cfg = [];
    data_all = ft_appenddata(cfg, data_eeg, data_HEOG, data_VEOG, data_lips);
    data_raw = ft_appenddata(cfg, data_eeg_raw, data_HEOG_raw, data_VEOG_raw, data_lips);
    % Add behavioral information matrix to the trialinfo matrix for later
    behavFilename = strcat(num2str(pNumber), '_IntMatrix.txt');
    behav = load(behavFilename); 
    data_all.trialinfo = [data_all.trialinfo behav];

    %% Artifact rejection 
    % automatic artifact rejection
    % Threshold artifact detection: trials with amplitudes above or below
    % +-100m or with a difference between min and max of more than 150mV
    cfg                                     = [];
    cfg.continuous                          = 'no';
    cfg.artfctdef.threshold.channel         = 'EEG'; 
    cfg.artfctdef.threshold.lpfilter        = 'no';
    cfg.artfctdef.threshold.hpfilter        = 'no';
    cfg.artfctdef.threshold.bpfilter        = 'no';
    cfg.artfctdef.threshold.demean          = 'no';
    cfg.artfctdef.threshold.reref           = 'no';
    cfg.artfctdef.threshold.range           = 150;
    cfg.artfctdef.threshold.min             = -100; 
    cfg.artfctdef.threshold.max             = 100;
    cfg.trl                                 = data_all.cfg.previous{1,1}.previous.trl;
    [cfg, artifact_threshold]               = ft_artifact_threshold(cfg, data_all);

    % Eye-blinks
    cfg.artfctdef.zvalue.channel               = [59,60];  % only HEOG and VEOG
    cfg.artfctdef.zvalue.bpfilter              = 'yes';
    cfg.artfctdef.zvalue.bpfilttype            = 'but';
    cfg.artfctdef.zvalue.bpfreq                = [1 15];
    cfg.artfctdef.zvalue.bpfiltord             = 4;
    cfg.artfctdef.zvalue.hilbert               = 'yes';
    cfg.artfctdef.zvalue.cutoff                = 4;      
    cfg.artfctdef.zvalue.artpadding            = 0.1;       
    [cfg, artifact_eog]                        = ft_artifact_zvalue(cfg, data_all);

    % manual artifact rejection by visual inspection of each trial
    cfg.viewmode                = 'vertical';
    cfg.selectmode              = 'markartifact';
    cfg.eegscale                = 1;
    cfg.eogscale                = 1.5;
    cfg.layout                  = 'actiCAP_64ch_Standard2.mat';
    cfg                         = ft_databrowser(cfg, data_all);                       % double click on segments to mark them as artefacts, then at the end exist the box by clicking 'q' or the X
    
    % double checking on raw data for dubious eye-artifacts?
    button                      = questdlg('Do you wish to inspect raw data?');
    % if 'Yes' was clicked, the raw data is loaded for the pp in the
    % databrowser
    if (strcmp(button,'Yes') == 1)
       cfg                      = ft_databrowser(cfg, data_raw); 
    else
    end
    
    % once all rejections have been made
    cfg.artfctdef.reject        = 'complete';                                          % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
    cfg.artfctdef.crittoilim    = [-0.2 1];                                            % rejects trial only when artifact is within a certain time window of itnerest
    data_clean                  = ft_rejectartifact(cfg, data_all); 

    
    % OR PURELY VISUAL 
    % Left lick on a channel name to mark it as bad, right click on a
    % channel name to reverse the marking, at the end press 'quit' NOT the 'X'
    %cfg = [];
    %cfg.alim = 15;
    cfg.eegscale = 1;
    cfg.eogscale = 1.5;
    cfg.keepchannel = 'nan';
    cfg.method = 'trial';
    cfg.plotlayout = '1col';
    data_clean = ft_rejectvisual(cfg, data_clean);
    save(preprocFile, 'data_clean');
    
    %% Select trials for further analysis
    % Here you can exclude incorrect answers etc. and cut data into 2 conditions
    cfg=[];
    % Familiarization
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 18)); % this assumes that column 5 is accuracy and that correct trials are indicated with 1. 
    data_fam_cond1 = ft_selectdata(cfg, data_clean);
    save(cond1outFam, 'data_fam_cond1');
    
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 19));
    data_fam_cond2 = ft_selectdata(cfg, data_clean);
    save(cond2outFam, 'data_fam_cond2');
    
    % Picture naming round 1
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 108));
    data_pic1_cond1 = ft_selectdata(cfg, data_clean);
    save(cond1outPic1, 'data_pic1_cond1');
    
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 109));
    data_pic1_cond2 = ft_selectdata(cfg, data_clean);
    save(cond2outPic1, 'data_pic1_cond2');
    
    % Picture naming round 2
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 118));
    data_pic2_cond1 = ft_selectdata(cfg, data_clean);
    save(cond1outPic2, 'data_pic2_cond1');
    
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 119));
    data_pic2_cond2 = ft_selectdata(cfg, data_clean);
    save(cond2outPic2, 'data_pic2_cond2');
    
    % Picture naming round 3
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 128));
    data_pic3_cond1 = ft_selectdata(cfg, data_clean);
    save(cond1outPic3, 'data_pic3_cond1');
    
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 129));
    data_pic3_cond2 = ft_selectdata(cfg, data_clean);
    save(cond2outPic3, 'data_pic3_cond2');
    
    % Picture naming round 4
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 138));
    data_pic4_cond1 = ft_selectdata(cfg, data_clean);
    save(cond1outPic4, 'data_pic4_cond1');
    
    cfg.trials = find((data_clean.trialinfo(:,2) == 1)& (data_clean.trialinfo(:,1) == 139));
    data_pic4_cond2 = ft_selectdata(cfg, data_clean);
    save(cond2outPic4, 'data_pic4_cond2');

    % document how many trials were kept for later analysis
    c1 = length(data_fam_cond1.trial);
    c2 = length(data_fam_cond2.trial);
    c3 = length(data_pic1_cond1.trial);
    c4 = length(data_pic1_cond2.trial);
    c5 = length(data_pic2_cond1.trial);
    c6 = length(data_pic2_cond2.trial);
    c7 = length(data_pic3_cond1.trial);
    c8 = length(data_pic3_cond2.trial);
    c9 = length(data_pic4_cond1.trial);
    c10 = length(data_pic4_cond2.trial);
    
    % save trial information in txt
    fid = fopen('TrialCount_PostPreprocessing.txt','a');
    formatSpec = '%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n';
    fprintf(fid,formatSpec,pNumber,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10);
    
    % calculating average for this pp 
    %cfg = [];
    %cfg.keeptrials='yes';
    %cond1 = ft_timelockanalysis(cfg, data_finaltestcond1);
    %cond2 = ft_timelockanalysis(cfg, data_finaltestcond2);
    % plotting average
    %cfg = [];
    %cfg.layout = 'actiCAP_64ch_Standard2.mat';
    %cfg.interactive = 'yes';
    %cfg.showoutline = 'yes';
    %cfg.showlabels = 'yes'; 
    %cfg.colorbar = 'yes';
    %cfg.fontsize = 6; 
    %cfg.ylim = [-10 10];
    %ft_multiplotER(cfg, cond1, cond2);
    
    disp('##############################################');
    disp(['## Done preprocessing PP_', num2str(pNumber),' ################']);
    disp(['## Trials for interference condition: ', num2str(c1), ' #####']);
    disp(['## Trials for no-interference condition: ', num2str(c2),' ##']);
    disp('##############################################');
    
    % change this to your Github folder directory
    cd('U:\PhD\EXPERIMENT 2 - EEG\EEG-analysis');  