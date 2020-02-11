%%% Permutation script for oscillations

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
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)

Condition1 = cell(1,length(subjects));
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic4_mediansplit_high_1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.up4);
    clear dummy
end

Condition2 = cell(1,length(subjects));
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic4_mediansplit_low_1');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.low4);
    clear dummy2
end

% grand-average over subjects for conditions
cfg = [];
cfg.keepindividual = 'yes';
cond1 = ft_freqgrandaverage(cfg, Condition1{:});
cond2 = ft_freqgrandaverage(cfg, Condition2{:});

cond1x = ft_freqgrandaverage(cfg, cond1);
cond2x = ft_freqgrandaverage(cfg, cond2);
cond1x.powspctrm = squeeze(nanmean(cond1.powspctrm, 1));
cond2x.powspctrm = squeeze(nanmean(cond2.powspctrm, 1));

cfg = [];
cfg.keepindividual = 'no';
cond1y = ft_freqgrandaverage(cfg, Condition1{:});
cond2y = ft_freqgrandaverage(cfg, Condition2{:});

diff = cond1;
diff.powspctrm = (cond1.powspctrm - cond2.powspctrm) ./ ((cond1.powspctrm + cond2.powspctrm)/2);

diffy = cond1y;
diffy.powspctrm = (cond1y.powspctrm - cond2y.powspctrm) ./ ((cond1y.powspctrm + cond2y.powspctrm)/2);

diffx = cond1x;
diffx.powspctrm = (cond1x.powspctrm - cond2x.powspctrm) ./ ((cond1x.powspctrm + cond2x.powspctrm)/2);
diffx.dimord = 'chan_freq_time';

% plot the difference between conditions               
% one channel
cfg = [];
cfg.channel      = {'Cz'};
%cfg.channel    = {'Fz', 'Cz', 'FCz', 'CPz', 'Pz', 'CP1', 'CP2'};
%cfg.colormap      = redblue;
cfg.zlim         = [-.18 .18]; %'maxabs'; %[-.18 .18]; %
figure 
subplot(1,3,1) ;
ft_singleplotTFR(cfg, diff);
title('keepindividual = yes');
subplot(1,3,2) ;
ft_singleplotTFR(cfg, diffx);
title('By hand (first avg over trials per subject, then avg over subjects)');
subplot(1,3,3) ;
ft_singleplotTFR(cfg, diffy);
title('keepindividual = no');


%% Alternative way of looking at data: calculate a structure which is the weighted diff
eff = Condition2;
for i = 1:length(subjects)
    eff{i}.powspctrm = (Condition1{i}.powspctrm - Condition2{i}.powspctrm) ./ ((Condition1{i}.powspctrm + Condition2{i}.powspctrm)/2);
end

% grand average for weighted effect
cfg = [];
cfg.keepindividual='yes';
effect = ft_freqgrandaverage(cfg, eff{:});

null = cond1;
null.powspctrm = zeros(size(cond1.powspctrm));

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
cfg.frequency        = [4 10];                      % look only at frequency between 4 and 10 Hz, or 'all';
cfg.statistic        = 'ft_statfun_depsamplesT';    % for a simple dependent t-test, other tests can be specified here
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;                           % for a two-tailed test, 1 or -1 for one-tailed tests
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.numrandomization = 1000;
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

%[stat]                  = ft_freqstatistics(cfg, Condition1{:}, Condition2{:});
[stat]                 = ft_freqstatistics(cfg, effect, null);

% plot the result
cfg                     = [];                           %First average over electrodes in the cluster
cfg.alpha               = 0.05;
cfg.parameter           = 'stat';
cfg.zlim                = [-3 3];
cfg.layout              = 'EEG1010.lay'; %'actiCAP_64ch_Standard2.mat';
ft_clusterplot(cfg, stat);


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
