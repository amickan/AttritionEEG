%%% Interference - Oscillations - Permutation and plotting - Median splits

%% load data
subjects = [301:302, 304:308, 310:326, 328, 329]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.pad          = 'nextpow2'; 
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                   % ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.01:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)

Condition1 = cell(1,length(subjects));
Condition2 = cell(1,length(subjects));

for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic4_mediansplit_high_1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.up4);
    clear dummy
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic4_mediansplit_low_1');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.low4);
    clear dummy2
end

%% calculate the relative difference between the conditions per subject
eff = Condition2;
for i = 1:length(subjects)
    eff{i}.powspctrm = (Condition1{i}.powspctrm - Condition2{i}.powspctrm) ./ ((Condition1{i}.powspctrm + Condition2{i}.powspctrm)/2);
end

%% grand average over subjects
cfg = [];
cfg.keepindividual='yes';
effect = ft_freqgrandaverage(cfg, eff{:});

%% Permutation test 

% create a null structure to compare the average effect to
null = effect;
null.powspctrm = zeros(size(effect.powspctrm));

% Create neighbourhood structure
cfg_neighb                  = [];
cfg_neighb.method           = 'triangulation';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'EEG1010.lay'; %'actiCAP_64ch_Standard2.mat';
cfg_neighb.feedback         = 'yes';
%cfg_neighb.neighbourdist    = 0.15;                 % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, Condition1{1});

% Permutation test
cfg = [];
cfg.channel          = {'EEG'};                     % only EEG channels in analysis, possibly restrict even more, i.e. exclude bad channels
cfg.latency          = [0.5 1];                       % time window in seconds
cfg.method           = 'montecarlo';
cfg.frequency        = [4 7];                      % look only at frequency between 4 and 10 Hz, or 'all';
cfg.statistic        = 'ft_statfun_depsamplesT';    % for a simple dependent t-test, other tests can be specified here
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;                           % for a two-tailed test, 1 or -1 for one-tailed tests
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.numrandomization = 2000;
cfg.correcttail      = 'prob';
cfg.neighbours       = neighbours;

% Design matrix - within subject design
subj                 = length(subjects);
design               = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design              = design;
cfg.uvar                = 1;                         % unit variable
cfg.ivar                = 2;                         % number or list with indices indicating the independent variable(s)

[stat]                 = ft_freqstatistics(cfg, effect, null);

%% Permutation test results 

% get relevant (significant) values
if isempty(stat.posclusters) == 0
    pos_cluster_pvals = [stat.posclusters(:).prob];
    pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
    pos = ismember(stat.posclusterslabelmat, pos_signif_clust);
    select = pos_cluster_pvals < stat.cfg.alpha;
    signclusters = pos_cluster_pvals(select);
    numberofsignclusters = length(signclusters);
    disp(['there are ', num2str(numberofsignclusters), ' significant positive clusters']);
else
    numberofsignclusters = 0;
end

if isempty(stat.negclusters) == 0
    neg_cluster_pvals = [stat.negclusters(:).prob];
    neg_signif_clust = find(neg_cluster_pvals < stat.cfg.alpha);
    neg = ismember(stat.negclusterslabelmat, neg_signif_clust);
    selectneg = neg_cluster_pvals < stat.cfg.alpha;
    signclustersneg = neg_cluster_pvals(selectneg);
    numberofsignclustersneg = length(signclustersneg);
    disp(['there are ', num2str(numberofsignclustersneg), ' significant negative clusters']);
else 
    numberofsignclustersneg = 0;
end

if numberofsignclusters > 0
    for i = 1:length(signclusters)
        disp(['Positive cluster number ', num2str(i), ' has a p value of ', num2str(signclusters(i))]);
        [foundx,foundy,foundz] = ind2sub(size(pos),find(pos));
        startbin = stat.time(min(foundz));
        endbin = stat.time(max(foundz));
        disp(['Positive cluster ', num2str(i), ' starts at ', num2str(startbin), ' s and ends at ', num2str(endbin), ' s.'])
        disp(['Positive cluster ', num2str(i), ' has a cluster statistic of ', num2str(stat.posclusters(i).clusterstat), ' and a standard deviation of',num2str(stat.posclusters(i).stddev),'.' ])
        disp(['The following frequencies are included in this significant cluster:  ', num2str(stat.freq(unique(foundy')))])
        disp(['The following ', num2str(length(unique(foundx'))),' channels are included in this significant cluster:  ', num2str(unique(foundx'))])
    end
end
    
if numberofsignclustersneg > 0
   for i = 1:length(signclustersneg)
        disp(['Negative cluster number ', num2str(i), ' has a p value of ', num2str(signclustersneg(i))]);
        [foundx,foundy,foundz] = ind2sub(size(neg),find(neg));
        startbin = stat.time(min(foundz));
        endbin = stat.time(max(foundz));
        disp(['Negative cluster ', num2str(i), ' starts at ', num2str(startbin), ' s and ends at ', num2str(endbin), ' s.'])
        disp(['Negative cluster ', num2str(i), ' has a cluster statistic of ', num2str(stat.negclusters(i).clusterstat), ' and a standard deviation of ',num2str(stat.negclusters(i).stddev),'.' ])
        disp(['The following frequencies are included in this significant cluster:  ', num2str(stat.freq(unique(foundy')))])
        disp(['The following ', num2str(length(unique(foundx'))),' channels are included in this significant cluster:  ', num2str(unique(foundx'))])
    end
end

%% Plotting

effect2 = effect;
effect2.freq = round(effect.freq);  % to circumvent plotting problem with newest fieldtrip version, round frequencies 

% plot the relative difference between conditions
cfg                 = [];
%cfg.parameter      = 'stat';
%cfg.maskparameter  = 'mask';
%cfg.maskalpha      = 0.2;
cfg.channel         = {'Cz', 'FCz', 'CPz', 'Pz', 'CP1', 'CP2', 'P1', 'C2', 'FC1', 'Fz', 'F1'};	
cfg.zlim            = [-.2 .2]; %
%cfg.masknans        = 'yes';
figure 
ft_singleplotTFR(cfg, effect2);
%ft_singleplotTFR(cfg, stat);

% plotting the topography 
cfg                 = [];
cfg.xlim            = [0.51 1];
cfg.ylim            = [4 7];
cfg.zlim            = 'maxabs';% [-.1 .1];
cfg.layout          = 'EEG1010.lay';
figure
ft_topoplotTFR(cfg, effect);

cfg                 = [];
cfg.xlim            = [0.51 1];
cfg.ylim            = [4 7];
cfg.zlim            = [-2 2];%'maxabs';% [-.18 .18];
cfg.layout          = 'EEG1010.lay';
cfg.parameter       = 'stat';
figure
ft_topoplotTFR(cfg, stat);
