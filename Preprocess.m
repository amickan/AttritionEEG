%%% EEG analysis script 14/11/2017 %%%
function Preprocess(pNumber)
%addpath('C:\Users\Beatrice\Downloads\fieldtrip-20180128\EEG-analysis-Final')
%addpath('C:\Users\Beatrice\Downloads\fieldtrip-20180128\fieldtrip-20180128')
cd('U:\PhD\EXPERIMENT 2 - EEG\Analysis EEG Anne')

% define files for this participant
vhdr = strcat(num2str(pNumber), '.vhdr');
cond1out = strcat('PreprocessedData\', num2str(pNumber), '_data_clean_cond1');
cond2out = strcat('PreprocessedData\', num2str(pNumber), '_data_clean_cond2');

%read continuous data
cfg = [];
cfg.dataset     = vhdr;
data_org        = ft_preprocessing(cfg);

%rereferencing
cfg.reref       = 'yes';
cfg.channel     = 'all';
cfg.implicitref = 'Ref';            % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel     = {'LinkMast', 'Ref'}; % the average of these channels is used as the new reference
data_eeg        = ft_preprocessing(cfg);

%this is for discarding a channel after re-referencing, we don't need to do
%this, but good to have it for now
%cfg = [];
%cfg.channel     = [1:61 65];                      % keep channels 1 to 61 and the newly inserted M1 channel
%data_eeg        = ft_preprocessing(cfg, data_eeg);

%this is to look at three channels
%plot(data_eeg.time{1}, data_eeg.trial{1}(1:3,:));
%legend(data_eeg.label(1:3));

%% Horizontal EOG
%reading horizontal EOGH
cfg = [];
cfg.dataset = vhdr;
cfg.channel = {'EOGleft', 'EOGright'};
cfg.reref = 'yes';
cfg.refchannel = 'EOGleft';
data_eogh = ft_preprocessing(cfg);
%checking that EOGleft was referenced to itself
figure
plot(data_eogh.time{1}, data_eogh.trial{1}(1,:));
hold on
plot(data_eogh.time{1}, data_eogh.trial{1}(2,:),'g'); 
legend({'EOGleft' 'EOGright'}); 
%rename/discard dummy channel with the next lines
data_eogh.label{1} = 'EOGH'; % if you check, channel number 2 has only 0s in the data, so that can't be right, so I changed the code to 1, not sure why this is different on the website
cfg = [];
cfg.channel = 'EOGH';
data_eogh   = ft_preprocessing(cfg, data_eogh); % nothing will be done, only the selection of the interesting channel

%% Vertical EOG 
%reading vertical EOGV
cfg = [];
cfg.dataset = vhdr;
cfg.channel = {'EOGabove', 'EOGbelow'}; %is there a difference in which above/below put before?
cfg.reref = 'yes';
cfg.refchannel = 'EOGabove';
data_eogv = ft_preprocessing(cfg);
%checking that EOGabove was referenced to itself
figure
plot(data_eogv.time{1}, data_eogv.trial{1}(1,:));
hold on
plot(data_eogv.time{1}, data_eogv.trial{1}(2,:),'g'); 
legend({'EOGabove' 'EOGbelow'}); 
%rename/discard dummy channel with the next lines
data_eogv.label{2} = 'EOGV';
cfg = [];
cfg.channel = 'EOGV';
data_eogv = ft_preprocessing(cfg, data_eogv); % nothing will be done, only the selection of the interesting channel

%% Lips 
%reading lips
cfg = [];
cfg.dataset = vhdr ;
cfg.channel = {'LipUp', 'LipLow'}; %is there a difference in which above/below put before?
cfg.reref = 'yes';
cfg.refchannel = 'LipUp';  %%here I'm not 100% sure if I should put LipUp
data_lips = ft_preprocessing(cfg);
%checking that LipUp was referenced to itself
figure
plot(data_lips.time{1}, data_lips.trial{1}(1,:));
hold on
plot(data_lips.time{1}, data_lips.trial{1}(2,:),'g'); 
legend({'LipUp' 'LipLow'}); 
%rename/discard dummy channel
data_lips.label{1} = 'LIPS'; % again I needed to change the channel number here
cfg = [];
cfg.channel = 'LIPS';
data_lips = ft_preprocessing(cfg, data_lips); % nothing will be done, only the selection of the interesting channel

%% combination of a single representation of using
cfg = [];
data_all = ft_appenddata(cfg, data_eeg, data_eogh, data_eogv, data_lips);

%% filtering from continuous data
cfg.lpfilter            = 'yes';
cfg.lpfreq              = 50;
cfg.hpfilter            = 'no';
%cfg.hpfreq              = 0.1; 
data_filtered           = ft_preprocessing(cfg, data_all); 

%% trial segmentation
% cfg = [];
% cfg.dataset             = '301.vhdr';
% cfg.trialdef.eventtype = '?';
% dummy                   = ft_definetrial(cfg);

% select data of two conditions and baseline correct
cfg = [];
cfg.dataset      = vhdr;
cfg.headerfile   = vhdr; % this needs to be specified, otherwise it doesn't work
% Baseline correction criteria
cfg.demean = 'yes';
cfg.baselinewindow = [-0.5 0];
% trial selection criteria general
cfg.trialfun = 'correctonly_trialfun'; % this is to only select correct trials 
cfg.trialdef.prestim    = 0.5; % time before marker in seconds
cfg.trialdef.poststim   = 2; % time after marker in seconds
cfg.marker2 = 'S205'; % correct / incorrect response marker 
% trial selection crtieria for condition 1
cfg.marker1 = 'S208'; % for the markers that only have two numbers you need to insert a space
cfg_finaltestcond1    = ft_definetrial(cfg);
% trial selection crtieria for condition 2
cfg.marker1 = 'S209';
cfg_finaltestcond2    = ft_definetrial(cfg);

%cut the trials out of the continuous data segment 
data_finaltestcond1 = ft_redefinetrial(cfg_finaltestcond1, data_filtered);
data_finaltestcond2    = ft_redefinetrial(cfg_finaltestcond2, data_filtered);

%% Artifact rejection 
% automatic artifact rejection
% Threshold artifact detection: trials with amplitudes above or below
% +-100m or with a difference between min and max of more than 150mV
cfg             = [];
cfg.continuous = 'no';
cfg.artfctdef.threshold.channel   = setdiff(1:68, [9,12,17,38,44,49,55,66,67,68]);  % only non-EOG channels
cfg.artfctdef.threshold.bpfilter  = 'no';
cfg.artfctdef.threshold.range     = 150;
cfg.artfctdef.threshold.min       = -100; 
cfg.artfctdef.threshold.max       = 100;
cfg.trl = data_finaltestcond1.cfg.trl;
[cfg, artifact_threshold] = ft_artifact_threshold(cfg, data_finaltestcond1);

% Clips - flat electrodes / trials 
%cfg.artfctdef.clip.pretim        = 0.000;  %pre-artifact rejection-interval in seconds
%cfg.artfctdef.clip.psttim        = 0.000;  %post-artifact rejection-interval in seconds
cfg.artfctdef.clip.channel = setdiff(1:68, [9,12,17,38,44,49,55,66,67,68]);
cfg.artfctdef.clip.timethreshold = 0.05; %minimum duration in seconds of a datasegment with consecutive identical samples to be considered as 'clipped'
cfg.artfctdef.clip.amplthreshold = 0; %minimum amplitude difference in consecutive samples to be considered as 'clipped' (default = 0)
[cfg, artifact_clip] = ft_artifact_clip(cfg, data_finaltestcond1);

% Eye-blinks - somehow this finds a huge amount fo artifacts, something is
% wrong with settings
cfg.artfctdef.eog.channel = [66,67];
cfg.artfctdef.eog.cutoff      = 6;
cfg.artfctdef.eog.trlpadding  = 0; %0.5?
cfg.artfctdef.eog.artpadding  = 0.1;
cfg.artfctdef.eog.fltpadding  = 0; %0.1
[cfg, artifact_eog] = ft_artifact_eog(cfg, data_finaltestcond1);

% manual artifact rejection by visual inspection of each trial
% condition 1
cfg.viewmode = 'vertical';
cfg.selectmode              = 'markartifact';
cfg = ft_databrowser(cfg, data_finaltestcond1); %% double click on segments to mark them as artefacts, then at the end exist the box by clicking 'q' or the X
cfg.artfctdef.reject  = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
data_clean_cond1 = ft_rejectartifact(cfg, data_finaltestcond1); %data_clean_cond1
save(cond1out, 'data_clean_cond1');

%automatic artifact rejection for the SECOND condition
% Threshold artifact detection:
cfg             = [];
cfg.continuous = 'no';
cfg.artfctdef.threshold.channel   = setdiff(1:68, [9,12,17,38,44,49,55,66,67,68]);  % only non-EOG channels
cfg.artfctdef.threshold.bpfilter  = 'no';
cfg.artfctdef.threshold.range     = 150;
cfg.artfctdef.threshold.min       = -100; 
cfg.artfctdef.threshold.max       = 100;
cfg.trl = data_finaltestcond2.cfg.trl;
[cfg, artifact_threshold2] = ft_artifact_threshold(cfg, data_finaltestcond2);

% Clips - flat electrodes / trials 
%cfg.artfctdef.clip.pretim        = 0.000;  %pre-artifact rejection-interval in seconds
%cfg.artfctdef.clip.psttim        = 0.000;  %post-artifact rejection-interval in seconds
cfg.artfctdef.clip.channel = setdiff(1:68, [9,12,17,38,44,49,55,66,67,68]);
cfg.artfctdef.clip.timethreshold = 0.05; %minimum duration in seconds of a datasegment with consecutive identical samples to be considered as 'clipped'
cfg.artfctdef.clip.amplthreshold = 0; %minimum amplitude difference in consecutive samples to be considered as 'clipped' (default = 0)
[cfg, artifact_clip2] = ft_artifact_clip(cfg, data_finaltestcond2);

% Eye-blinks - somehow this finds a huge amount fo artifacts, something is
% wrong with settings
cfg.artfctdef.eog.channel = [66,67];
cfg.artfctdef.eog.cutoff      = 6;
cfg.artfctdef.eog.trlpadding  = 0;
cfg.artfctdef.eog.artpadding  = 0.1;
cfg.artfctdef.eog.fltpadding  = 0;
[cfg, artifact_eog2] = ft_artifact_eog(cfg, data_finaltestcond2);

% condition 2
cfg.viewmode = 'vertical';
cfg.selectmode = 'markartifact';
cfg = ft_databrowser(cfg, data_finaltestcond2);
cfg.artfctdef.reject  = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
data_clean_cond2 = ft_rejectartifact(cfg, data_finaltestcond2); %data_clean_cond2
save(cond2out, 'data_clean_cond2');

% document how many trials were kept for later analysis
c1 = length(data_clean_cond1.trial);
c2 = length(data_clean_cond2.trial);

fid = fopen('TrialCount_PostPreprocessing.txt','a');
formatSpec = '%d\t%d\t%d\n';
fprintf(fid,formatSpec,pNumber,c1,c2);