%Condition1 from timelock analysis
%cond1 from timelock grandaverage

%for a single subject, average of trials with timelockanalisis for
%neighbours
dummy = load(strcat('PreprocessedData\301_data_clean_cond2'))
Condition2 = ft_timelockanalysis(cfg, dummy.data_finaltestcond2);

%copy from grandaverage script
subjects = [301:307, 310:312, 314:320, 322:326, 328, 329];
cfg = [];
cfg.keeptrials='yes';
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

%creation of a structure with ft_neighbourselection
cfg_neighb        = [];
cfg_neighb.method = 'template';         %may be changed with 'distance'
cfg.feedback      ='yes'
neighbours        = ft_prepare_neighbours(cfg_neighb, Condition2);



%configuration settings
cfg = [];
cfg.method = 'montecarlo';       % use the Monte Carlo Method to calculate the significance probability
cfg.channel       = {'EEG'};     % cell-array with selected channel labels
cfg.latency       = [0.1 1];       % time interval over which the experimental 
                                 % conditions must be compared (in seconds)
cfg.statistic = 'ft_statfun_depsamplesT'; % within design
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;         % alpha level of the sample-specific test statistic that 
                                 % will be used for thresholding
cfg.clusterstatistic = 'maxsum'; % test statistic that will be evaluated under the 
                                 % permutation distribution. 
%cfg.minnbchan = 2;               % minimum number of neighborhood channels that is 
                                 % required for a selected sample to be included 
                                 % in the clustering algorithm (default=0).
cfg.neighbours = neighbours;   
cfg.tail = 0;                    % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail = 0;
cfg.alpha = 0.025;               % alpha level of the permutation test
cfg.numrandomization = 500;      % number of draws from the permutation distribution

subj = 25; %number of participants excluding the ones with too few trials
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design = design;             % design matrix EDIT FOR WITHIN
cfg.uvar = 1;                       %unit variable
cfg.ivar  = 1;                   % number or list with indices indicating the independent variable(s) EDIT FOR WITHIN

[stat] = ft_timelockstatistics(cfg, Condition1{:}, Condition2{:});

%save stat_ERP stat;

% % plot the result
% cfg = [];
% avgFIC = ft_timelockanalysis(cfg, dataFIC_LP);
% avgFC  = ft_timelockanalysis(cfg, dataFC_LP);

% Then take the difference of the averages using ft_math
cfg  = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
raweffect = ft_math(cfg,Condition1,Condition2);

%We then construct a boolean matrix indicating membership in the significant clusters.