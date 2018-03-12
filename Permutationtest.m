cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\');

%% Loading all preprocessed data 

subjects = [301:307, 310:312, 314:320, 322:326, 328, 329]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 
cfg = [];
cfg.keeptrials='no';

for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('PreprocessedData\', num2str(subjects(i)), '_data_clean_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_timelockanalysis(cfg, dummy.data_finaltestcond1);
    % condition 2 for each participant
    filename2 = strcat('PreprocessedData\', num2str(subjects(i)), '_data_clean_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_timelockanalysis(cfg, dummy2.data_finaltestcond2);
end

%% before cluster based permutation test: neighbour definition
% creation of a structure with ft_neighbourselection
cfg_neighb              = [];
cfg_neighb.method       = 'triangulation';         %better than 'distance'
cfg_neighb.channel      = {'EEG'};
cfg_neighb.layout       = 'actiCAP_64ch_Standard2.mat';
cfg_neighb.feedback     = 'yes';
neighbours              = ft_prepare_neighbours(cfg_neighb, Condition1{1});

%% cluster based permutation test
% configuration settings
cfg                     = [];
cfg.channel             = 'EEG';        % cell-array with selected channel labels
cfg.latency             = [0 1];        % time interval over which the experimental 
                                        % conditions must be compared (in seconds)
cfg.method              = 'montecarlo'; % use the Monte Carlo Method to calculate the significance probability
cfg.statistic           = 'depsamplesT';% within design
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;         % alpha level of the sample-specific test statistic that 
                                        % will be used for thresholding
cfg.clusterstatistic    = 'maxsum';     % test statistic that will be evaluated under the 
                                        % permutation distribution. 
cfg.minnbchan           = 2;            % minimum number of neighborhood channels that is 
                                        % required for a selected sample to be included 
                                        % in the clustering algorithm (default=0).
cfg.neighbours          = neighbours;   
cfg.tail                = 0;            % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail         = 0;
cfg.alpha               = 0.025;        % alpha level of the permutation test
cfg.numrandomization    = 500;          % number of draws from the permutation distribution

% Design matrix
subj                    = length(subjects);           
design                  = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design              = design;        % design matrix EDIT FOR WITHIN
cfg.uvar                = 1;             % unit variable
cfg.ivar                = 2;             % number or list with indices indicating the independent variable(s) EDIT FOR WITHIN

[stat] = ft_timelockstatistics(cfg, Condition1{:}, Condition2{:});

%save stat_ERP stat;

%% plot the results

%use of timelock grand average
cfg = [];
cfg.keeptrials='yes';
cfg.parameter= 'avg';
cfg.channel='all';
cond1 = ft_timelockgrandaverage(cfg, Condition1{:});
cond2 = ft_timelockgrandaverage(cfg, Condition2{:});

% plots
cfg  = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
contrasts = ft_math(cfg, cond1,cond2);


figure;  
% define parameters for plotting
timestep = 0.05;      %(in seconds)
sampling_rate = dataFIC_LP.fsample; %da cambiare
sample_count = length(stat.time);
j = [0:timestep:1];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
m = [1:timestep*sampling_rate:sample_count];  % temporal endpoints in MEEG samples
% get relevant (significant) values
pos_cluster_pvals = [stat.posclusters(:).prob];

%We then construct a boolean matrix indicating membership in the significant clusters.