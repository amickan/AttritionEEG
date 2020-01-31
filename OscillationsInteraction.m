%%%%%oscillations %%%
%% load data from both sessions
subjects = [301:308, 310:326, 328, 329]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 

% frequency decomposition setting
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.pad          = 'nextpow2';
Condition1 = cell(1,27);
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.data_cond1);
    clear dummy
end

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.pad          = 'nextpow2'; 
Condition2 = cell(1,27);
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.data_cond2);
    clear dummy2
end

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;
cfg.pad          = 'nextpow2'; 
Condition12 = cell(1,27);
for i = 1:length(subjects)
    % condition 1 for each participan
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf\', num2str(subjects(i)), '_data_clean_cond1');
    dummy = load(filename1);
    Condition12{i} = ft_freqanalysis(cfg, dummy.data_finaltestcond1);
    clear dummy
end

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
cfg.pad          = 'nextpow2'; 
Condition22 = cell(1,27);
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf\', num2str(subjects(i)), '_data_clean_cond2');
    dummy2 = load(filename2);
    Condition22{i} = ft_freqanalysis(cfg, dummy2.data_finaltestcond2);
    clear dummy2
end

% difference waves
for i=1:length(Condition1)
    DiffRound2{i} = Condition1{i};
    DiffRound2{i}.powspctrm = Condition1{i}.powspctrm - Condition2{i}.powspctrm ./ ((Condition1{i}.powspctrm + Condition2{i}.powspctrm)/2);
end

for i=1:length(Condition12)
    DiffRound1{i} = Condition12{i};
    DiffRound1{i}.powspctrm = Condition12{i}.powspctrm - Condition22{i}.powspctrm ./ ((Condition12{i}.powspctrm + Condition22{i}.powspctrm)/2);
end

% average powerspectrum 
% for i=1:length(Condition1)
%  AvgCond1{i} = Condition1{i};
%  AvgCond1{i}.powspctrm = (Condition1{i}.powspctrm + Condition12{i}.powspctrm)./2;
% end
% 
% for i=1:length(Condition2)
%  AvgCond2{i} = Condition1{i};
%  AvgCond2{i}.powspctrm = (Condition2{i}.powspctrm + Condition22{i}.powspctrm)./2;
% end

clear Condition1 Condition2 Condition12 Condition22

% grand average
cfg = [];
cfg.keepindividual='yes';
GAdiffRound2 = ft_freqgrandaverage(cfg, DiffRound2{:});
GAdiffRound1 = ft_freqgrandaverage(cfg, DiffRound1{:});

% grand average over avgerages
%cfg = [];
%cfg.keepindividual='yes';
%GAdiffCond2 = ft_freqgrandaverage(cfg, AvgCond2{:});
%GAdiffCond1 = ft_freqgrandaverage(cfg, AvgCond1{:});


%%% Permutation test %%%%

% Create neighbourhood structure
cfg_neighb                  = [];
cfg_neighb.method           = 'distance';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'EEG1010.lay';
%cfg_neighb.layout           = 'actiCAP_64ch_Standard2.mat';
cfg_neighb.feedback         = 'yes';
cfg_neighb.neighbourdist    = 0.15; % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, DiffRound1{1});
%neighbours                  = ft_prepare_neighbours(cfg_neighb, AvgCond1{1});

clear DiffRound2 DiffRound1

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