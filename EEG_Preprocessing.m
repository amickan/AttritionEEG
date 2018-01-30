%%% EEG analysis script 14/11/2017 %%%
addpath('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\301\Day 3\EEG - Copy')

%read continuous data
cfg = [];
cfg.dataset     = '301.vhdr';
data_org        = ft_preprocessing(cfg)

%rereferencing
cfg = [];
cfg.dataset     = '301.vhdr';
cfg.reref       = 'yes';
cfg.channel     = 'all';
cfg.implicitref = 'TP9';            % the implicit (non-recorded) reference channel is added to the data representation
cfg.refchannel     = {'LinkMast', 'TP9'}; % the average of these channels is used as the new reference
data_eeg        = ft_preprocessing(cfg);

%this is for discarding a channel after re-referencing, but I'm not sure how to edit it 
%cfg = [];
%cfg.channel     = [1:61 65];                      % keep channels 1 to 61 and the newly inserted M1 channel
%data_eeg        = ft_preprocessing(cfg, data_eeg);

%this is to look at three channels
plot(data_eeg.time{1}, data_eeg.trial{1}(1:3,:));
legend(data_eeg.label(1:3));

%reading horizontal EOGH
cfg = [];
cfg.dataset = '301.vhdr';
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
data_eogh.label{2} = 'EOGH';
cfg = [];
cfg.channel = 'EOGH';
data_eogh   = ft_preprocessing(cfg, data_eogh); % nothing will be done, only the selection of the interesting channel
%reading vertical EOGH
cfg = [];
cfg.dataset = '301.vhdr';
cfg.channel = {'EOGabove', 'EOGbelow'}; %is there a difference in which above/below put before?
cfg.reref = 'yes';
cfg.refchannel = 'EOGabove'
data_eogv = ft_preprocessing(cfg);
data_eogv.label{2} = 'EOGV';
cfg = [];
cfg.channel = 'EOGV';
data_eogv = ft_preprocessing(cfg, data_eogv); % nothing will be done, only the selection of the interesting channel
%reading lips
cfg = [];
cfg.dataset = '301.vhdr';
cfg.channel = {'LipUp', 'LipLow'}; %is there a difference in which above/below put before?
cfg.reref = 'yes';
cfg.refchannel = 'LipLow'  %%here I'm not 100% sure if I should put LipUp
data_lips = ft_preprocessing(cfg);
data_lips.label{2} = 'LIPS'; %rename/discard dummy channe
cfg = [];
cfg.channel = 'LIPS';
data_lips = ft_preprocessing(cfg, data_lips); % nothing will be done, only the selection of the interesting channel
%checking lips --doesn't work
figure
plot(data_lips.time{1}, data_lips.trial{1}(1,:));
hold on
plot(data_lips.time{1}, data_lips.trial{1}(2,:),'g'); 
legend({'LipUp' 'LipLow'}); 

%combination of a single representation of using
cfg = [];
data_all = ft_appenddata(cfg, data_eeg, data_eogh, data_eogv, data_lips);

%filtering
cfg = [];
cfg.dataset             = '301.vhdr';
cfg.lpfilter            = 'yes';
cfg.hpfilter            = 'yes';
cfg.lpfreq              = 30;
cfg.hpfreq              = 0.1; 
data_eeg                = ft_preprocessing(cfg);

%trial segmentation
cfg = [];
cfg.dataset             = '301.vhdr';
cfg.trialdef.eventtype = '?';
dummy                   = ft_definetrial(cfg);

%select data of two conditions 
cfg = [];
cfg.dataset             = '301.vhdr';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.prestim        = 1;
cfg.trialdef.poststim       = 2;
cfg.trialdef.eventvalue = {'S208', 'S218'};
cfg_vis_condA          = ft_definetrial(cfg);

cfg.trialdef.eventvalue = {'S209', 'S219'};
cfg_vis_condB            = ft_definetrial(cfg);

%%here sort out something to select only trial with no mistakes

%cut the trials out of the continuous data segment
data_vis_condA = ft_redefinetrial(cfg_vis_condA, data_all);
data_vis_condB   = ft_redefinetrial(cfg_vis_condB,   data_all);

%visual inspection ?
cfg          = [];
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data_all);

%visual inspection of visual channels, to mark them as good or bad
cfg        = [];
cfg.method = 'channel';
ft_rejectvisual(cfg, data_all)
%channel layout?? (the tutorial uses an existing layout)

cfg = [];
cfg.method   = 'summary';
cfg.layout   = 'actiCAP_64ch_Standard2.mat';   % this allows for plotting individual trials
cfg.channel  = [1:60];    % do not show EOG channels
data_clean   = ft_rejectvisual(cfg, data_all);

disp(data_clean.trialinfo')
%computing and plotting ERPs
% use ft_timelockanalysis to compute the ERPs 
% cfg = [];
% cfg.trials = find(cfg_vis_condA);
% task1 = ft_timelockanalysis(cfg, data_all);
% 
% cfg = [];
% cfg.trials = find(cfg_vis_condB);
% task2 = ft_timelockanalysis(cfg, data_all);
% 
% cfg = [];
% cfg.layout = 'mpi_customized_acticap64.mat';
% cfg.interactive = 'yes';
% cfg.showoutline = 'yes';
% ft_multiplotER(cfg, task1, task2)

%averaging trials
cfg = [];
avgCondA = ft_timelockanalysis(cfg_vis_condA, data_all);
avgCondB = ft_timelockanalysis(cfg_vis_condB,   data_all);

%plotting - but still the layout
cfg = [];
cfg.showlabels = 'yes'; 
cfg.fontsize = 6; 
cfg.layout = 'CTF151.lay';
cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avgFIC); 

%manual artifact rejection
%browse throgh the data trial by trial
cfg          = [];
cfg.method   = 'trial';
cfg.alim     = 5e-5; 
dummy        = ft_rejectvisual(cfg,dataFIC);
