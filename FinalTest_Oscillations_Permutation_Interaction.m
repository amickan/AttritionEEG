%%%% Final test Oscillations - testing for an interaction between rounds %%%
%% load data 
subjects        = [301:308, 310:326, 328, 329];     % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\');    % directory with all preprocessed files 

% settings for frequency decomposition
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.pad          = 'nextpow2';

% initiate empty cell arrays per condition for subject averages 
Condition1      = cell(1,length(subjects));
Condition2      = cell(1,length(subjects));
Condition12     = cell(1,length(subjects));
Condition22     = cell(1,length(subjects));

for i = 1:length(subjects)
    % condition 1 first half for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf\', num2str(subjects(i)), '_data_clean_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.data_finaltestcond1);
    clear dummy
    % condition 2 first half for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf\', num2str(subjects(i)), '_data_clean_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.data_finaltestcond2);
    clear dummy2
    % condition 1 second half for each participan
    filename12 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1');
    dummy12 = load(filename12);
    Condition12{i} = ft_freqanalysis(cfg, dummy12.data_cond1);
    clear dummy12
     % condition 2 second half for each participant
    filename22 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2');
    dummy22 = load(filename22);
    Condition22{i} = ft_freqanalysis(cfg, dummy22.data_cond2);
    clear dummy22
end

%% calculate difference waves for each round (i.e. half of the data)for i=1:length(Condition1)
for i=1:length(Condition1)
    DiffRound1{i}           = Condition1{i};
    DiffRound1{i}.powspctrm = Condition1{i}.powspctrm - Condition2{i}.powspctrm ./ ((Condition1{i}.powspctrm + Condition2{i}.powspctrm)/2);
end

for i=1:length(Condition12)
    DiffRound2{i}           = Condition12{i};
    DiffRound2{i}.powspctrm = Condition12{i}.powspctrm - Condition22{i}.powspctrm ./ ((Condition12{i}.powspctrm + Condition22{i}.powspctrm)/2);
end

clear Condition1 Condition2 Condition12 Condition22

%% grand average the difference
cfg                         = [];
cfg.keepindividual          = 'yes';
GAdiffRound2                = ft_freqgrandaverage(cfg, DiffRound2{:});
GAdiffRound1                = ft_freqgrandaverage(cfg, DiffRound1{:});

%% Permutation test

% Create neighbourhood structure
cfg_neighb                  = [];
cfg_neighb.method           = 'triangulation';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'EEG1010.lay';
cfg_neighb.feedback         = 'yes';
cfg_neighb.neighbourdist    = 0.15; % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, DiffRound1{1});

clear DiffRound2 DiffRound1

% stats settings
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

[stat]                  = ft_freqstatistics(cfg, GAdiffRound1, GAdiffRound2);

%% Permutation test evaluation

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