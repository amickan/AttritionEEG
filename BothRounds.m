%% load data from both sessions

subjects = [301:308, 310:326, 328, 329]; % subjects that should be included in grand average
set(groot,'DefaultFigureColormap',jet);
%cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.pad          = 'nextpow2';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.01:1.5; %-0.5:0.05:1.5;    %-0.5:0.01:1.5              % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
Condition1 = cell(1,27);
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.data_cond1);
    %Condition1{i} = ft_freqbaseline(cfg, Condition1{i});
    clear dummy
end

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.pad          = 'nextpow2';
cfg.foi          = 2:1:30;   
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.01:1.5; %-0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
Condition2 = cell(1,27);
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.data_cond2);
    %Condition2{i} = ft_freqbaseline(cfg, Condition2{i});
    clear dummy2
end

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.pad          = 'nextpow2';
cfg.baseline     = [-0.5 0];    
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.01:1.5 ;%-0.5:0.05:1.5; 

for i = 1:length(subjects)
    % condition 1 for each participan
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf\', num2str(subjects(i)), '_data_clean_cond1');
    dummy = load(filename1);
    dummy_freq = ft_freqanalysis(cfg, dummy.data_finaltestcond1);
    Condition1{i}.powspctrm = (Condition1{i}.powspctrm + dummy_freq.powspctrm)./2;
    Condition1{i} = ft_freqbaseline(cfg, Condition1{i});
    clear dummy
    clear dummy_freq
end

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.pad          = 'nextpow2';
cfg.baseline     = [-0.5 0];
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.01:1.5; %-0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)

for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf\', num2str(subjects(i)), '_data_clean_cond2');
    dummy2 = load(filename2);
    dummy_freq2 = ft_freqanalysis(cfg, dummy2.data_finaltestcond2);
    Condition2{i}.powspctrm = (Condition2{i}.powspctrm + dummy_freq2.powspctrm)./2;
    Condition2{i} = ft_freqbaseline(cfg, Condition2{i});
    clear dummy2
    clear dummy_freq2
end

% grand average 
cfg = [];
cfg.keepindividual='yes';
cond1 = ft_freqgrandaverage(cfg, Condition1{:});
cond2 = ft_freqgrandaverage(cfg, Condition2{:});

diff = cond1;
diff.powspctrm = (cond1.powspctrm - cond2.powspctrm) ./ ((cond1.powspctrm + cond2.powspctrm)/2);

%% create an effect structure which is the weighted diff
eff = Condition2;
% loop
for i = 1:length(subjects)
    eff{i}.powspctrm = (Condition1{i}.powspctrm - Condition2{i}.powspctrm) ./ ((Condition1{i}.powspctrm + Condition2{i}.powspctrm)/2);
end

% grand average for weighted effect
cfg = [];
cfg.keepindividual='yes';
effect = ft_freqgrandaverage(cfg, eff{:});

null = cond1;
null.powspctrm = zeros(size(cond1.powspctrm));

cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); 
% all channels
%cfg              = [];
%cfg.baseline     = [-0.5 0]; 
%cfg.baselinetype = 'absolute'; 
%cfg.zlim         = [-.18 .18]; %'maxabs';	 
%cfg.parameter = 'stat';
%cfg.showlabels   = 'yes';	
%cfg.layout       = 'actiCAP_64ch_Standard2.mat';
%cfg.layout = 'EEG1010.lay';
%cfg.maskparameter = 'mask';
%figure
%ft_multiplotTFR(cfg, stat);
%ft_multiplotTFR(cfg, diff);

% one channel
cfg = [];
%cfg.parameter = 'stat';
%cfg.maskparameter = 'mask';
%cfg.maskalpha = 0.2;
%cfg.baseline     = [-0.5 -0.1];
%cfg.baselinetype = 'absolute';  
cfg.channel    = {'Cz', 'FCz', 'CPz', 'Pz', 'CP1', 'CP2', 'P1', 'P2', 'C1', 'C2', 'FC1', 'FC2'};	
cfg.zlim         = [-2 2]; %[-.18 .18]; %'maxabs';	        
figure 
ft_singleplotTFR(cfg, effect);
ft_singleplotTFR(cfg, diff);
ft_singleplotTFR(cfg, stat);

% plotting the topography 
cfg = [];
cfg.xlim = [0.5 1];
cfg.ylim = [4 10];
cfg.zlim = [-.18 .18];
%cfg.layout       = 'actiCAP_64ch_Standard2.mat';
cfg.layout = 'EEG1010.lay';
figure
ft_topoplotTFR(cfg, effect);

% plotting stats
cfg = [];
cfg.xlim = [0.5 1];
cfg.ylim = [4 10];
cfg.zlim = [-3 3];
cfg.layout = 'EEG1010.lay';
%cfg.layout       = 'actiCAP_64ch_Standard2.mat';
cfg.parameter = 'stat';
cfg.maskparameter = 'mask';
ft_topoplotTFR(cfg, stat);

% Create neighbourhood structure
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\');
cfg_neighb                  = [];
cfg_neighb.method           = 'distance';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'EEG1010.lay';
cfg_neighb.feedback         = 'yes';
cfg_neighb.neighbourdist    = 0.15; % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, Condition1{1});

% Permutation test
cfg = [];
cfg.channel          = {'EEG'};
cfg.latency          = [0 1];
cfg.method           = 'montecarlo';
cfg.frequency        = [4 7];%'all';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.correcttail      = 'prob';
cfg.alpha            = 0.05;
cfg.numrandomization = 2000;
cfg.neighbours          = neighbours; 
%cfg.avgovertime = 'yes';
%cfg.avgoverfreq = 'yes';

% Design matrix - within subject design
subj                    = length(subjects);                % number of participants excluding the ones with too few trials
design                  = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design              = design;                           % design matrix EDIT FOR WITHIN
cfg.uvar                = 1;                                % unit variable
cfg.ivar                = 2;                                % number or list with indices indicating the independent variable(s) EDIT FOR WITHIN

[stat]                  = ft_freqstatistics(cfg, Condition1{:}, Condition2{:});
%%% different type of analysis
[stat]                 = ft_freqstatistics(cfg, effect, null);

% plot the result
cfg = [];
% cfg.alpha  = 0.05;
cfg.parameter = 'stat';
cfg.zlim   = [-0.18 0.18];%'maxabs';
cfg.layout = 'EEG1010.lay';
ft_multiplotTFR(cfg, stat);

cfg.maskparameter = 'mask';
figure; ft_multiplotTFR(cfg, stat);

%% Topo of stats
cfg = [];
cfg.parameter = 'stat';
cfg.zlim   = [-2 2]; %'maxabs';
cfg.layout = 'EEG1010.lay';
ft_topoplotTFR(cfg, stat);

%%

% get relevant (significant) values
pos_cluster_pvals = [stat.posclusters(:).prob];
pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
pos = ismember(stat.posclusterslabelmat, pos_signif_clust);

neg_cluster_pvals = [stat.negclusters(:).prob];
neg_signif_clust = find(neg_cluster_pvals < stat.cfg.alpha);
neg = ismember(stat.negclusterslabelmat, neg_signif_clust);

select = pos_cluster_pvals < stat.cfg.alpha;
selectneg = neg_cluster_pvals < stat.cfg.alpha;
signclusters = pos_cluster_pvals(select);
signclustersneg = neg_cluster_pvals(selectneg);
numberofsignclusters = length(signclusters);
numberofsignclustersneg = length(signclustersneg);
disp(['there are ', num2str(numberofsignclusters), ' significant positive clusters']);
disp(['there are ', num2str(numberofsignclustersneg), ' significant negative clusters']);

if numberofsignclusters > 0
    for i = 1:length(signclusters)
        disp(['Positive cluster number ', num2str(i), ' has a p value of ', num2str(signclusters(i))]);
        [foundx,foundy,foundz] = ind2sub(size(pos),find(pos));
        startbin = stat.time(min(foundz));
        endbin = stat.time(max(foundz));
        disp(['Positive cluster ', num2str(i), ' starts at ', num2str(startbin), ' s and ends at ', num2str(endbin), ' s.'])
        disp(['Positive cluster ', num2str(i), ' has a cluster statistic of ', num2str(stat.posclusters(i).clusterstat), ' and a standard deviation of ',num2str(stat.posclusters(i).stddev),'.' ])
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