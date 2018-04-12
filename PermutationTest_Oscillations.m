%%% Permutation script for oscillations

subjects = [301:308, 310:326, 328, 329]; % subjects that should be included in grand average
%cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;   % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
%cfg.keeptrials   = 'yes';
Condition1 = cell(1,27);
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.data_cond1);
    clear dummy
end

% grand-average over subjects per condition 
cfg = [];
cfg.keepindividual='yes';
cond1 = ft_freqgrandaverage(cfg, Condition1{:});

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
%cfg.keeptrials   = 'yes';
Condition2 = cell(1,27);
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.data_cond2);
    clear dummy2
end

%% create an effect structure which is the weighted diff
eff = Condition2;
% loop
for i = 1:length(subjects)
    eff{i}.powspctrm = (Condition1{i}.powspctrm - Condition2{i}.powspctrm) ./ ((Condition1{i}.powspctrm + Condition2{i}.powspctrm)/2);
end

%%
% grand-average over subjects for condition 2
cfg = [];
cfg.keepindividual='yes';
cond2 = ft_freqgrandaverage(cfg, Condition2{:});

% grand average for weighted effect
cfg = [];
cfg.keepindividual='yes';
effect = ft_freqgrandaverage(cfg, eff{:});

% Create neighbourhood structure
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\');
cfg_neighb                  = [];
cfg_neighb.method           = 'distance';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'actiCAP_64ch_Standard2.mat';
cfg_neighb.feedback         = 'yes';
cfg_neighb.neighbourdist    = 0.15; % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, Condition1{1});

% Permutation test
cfg = [];
cfg.channel          = {'EEG'};
cfg.latency          = [0.5 1];
cfg.method           = 'montecarlo';
cfg.frequency        = [6 8];%'all';
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.1;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 2;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.correcttail      = 'prob';
cfg.alpha            = 0.05;
cfg.numrandomization = 1000;
cfg.neighbours          = neighbours; 
% cfg.avgovertime = 'yes';
% cfg.avgoverfreq = 'yes';

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
% [stat2]                 = ft_freqstatistics(cfg, cond1, cond2)

null = cond1;
null.powspctrm = zeros(size(cond1.powspctrm));
[stat]                 = ft_freqstatistics(cfg, effect, null);

%%
% plot the result
cfg = [];
cfg.alpha  = 0.05;
cfg.parameter = 'stat';
cfg.zlim   = [-4 4];
cfg.layout = 'actiCAP_64ch_Standard2.mat';
ft_multiplotTFR(cfg, stat);

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
        disp(['Positive cluster number ', num2str(i), ' has a p value of ', num2str(signclusters(i))])
        select = ismember(stat.posclusterslabelmat, pos_signif_clust(i));
        pos2 = ismember (stat.posclusterslabelmat, pos_signif_clust(i));
        [foundx,foundy] = find(select);
        % pos_int2 = all(pos2(:, min(foundy):max(foundy)),2); % no channels are significant over the total sign. time period....
        % find(pos_int2) % see upper comment
        starttime = stat.time(min(foundy));
        endtime = stat.time(max(foundy));
        
        %%% Topoplot for the cluster 
        figure;
        colormap(redblue);
        colorbar('eastoutside');
        cfg = [];
        cfg.xlim=[starttime endtime];  % in seconds!
        cfg.zlim = [-3 3];
        cfg.layout = 'actiCAP_64ch_Standard2.mat';
        %ft_topoplotER(cfg, raweffect);
        
        disp(['Positive cluster ', num2str(i), ' starts at ', num2str(starttime), ' s and ends at ', num2str(endtime), ' s'])
        disp(['the following ', num2str(length(unique(foundx'))),' channels are included in this significant cluster:  ', num2str(unique(foundx'))])
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
    end
end

if numberofsignclustersneg > 0
    for i = 1:length(signclustersneg)
        disp(['Negative cluster number ', num2str(i), ' has a p value of ', num2str(signclustersneg(i))])
        selectneg = ismember(stat.negclusterslabelmat, neg_signif_clust(i));
        pos2 = ismember (stat.negclusterslabelmat, neg_signif_clust(i));
        [foundx,foundy] = find(selectneg);
        % pos_int2 = all(pos2(:, min(foundy):max(foundy)),2); % no channels are significant over the total sign. time period....
        % find(pos_int2) % see upper comment
        starttime = stat.time(min(foundy));
        endtime = stat.time(max(foundy));
        
        %%% Topoplot for the cluster 
        figure;
        colormap(redblue);
        colorbar('eastoutside');
        cfg = [];
        cfg.xlim=[starttime endtime];  % in seconds!
        %cfg.zlim = [-5 5];
        cfg.layout = 'actiCAP_64ch_Standard2.mat';
        %ft_topoplotER(cfg, raweffect);
        
        disp(['Negative cluster ', num2str(i), ' starts at ', num2str(starttime), ' s and ends at ', num2str(endtime), ' s'])
        disp(['the following ', num2str(length(unique(foundx'))),' channels are included in this significant cluster:  ', num2str(unique(foundx'))])
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
    end
end