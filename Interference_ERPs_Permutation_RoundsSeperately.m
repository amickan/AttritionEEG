%%% Permutation test script for interference phase normal comparison

% Loading all preprocessed data 

subjects = [301:302, 304:308, 310:326, 328, 329]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 

cfg = [];
cfg.baseline = [-0.2 0];

Condition1 = cell(1,length(subjects));
Condition2 = cell(1,length(subjects));

for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic4_data_clean_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_timelockanalysis(cfg, dummy.data_pic4_cond1);
    Condition1{i} = ft_timelockbaseline(cfg, Condition1{i});
    clear dummy
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic4_data_clean_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_timelockanalysis(cfg, dummy2.data_pic4_cond2);
    Condition2{i} = ft_timelockbaseline(cfg, Condition2{i});
    clear dummy2
end

% Create neighbourhood structure
cfg_neighb                  = [];
cfg_neighb.method           = 'triangulation';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'EEG1010.lay';
cfg_neighb.feedback         = 'yes';
%cfg_neighb.neighbourdist    = 0.15; % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, Condition1{1});

% Stats settings
cfg                     = [];
cfg.method              = 'montecarlo';       
cfg.channel             = {'EEG'};     
cfg.latency             = [0 1]; %[0.2 0.35];      % [0.35 1];
cfg.statistic           = 'ft_statfun_depsamplesT';         % within design
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;                             % alpha level of the sample-specific test statistic that will be used for thresholding
cfg.clusterstatistic    = 'maxsum';                         % test statistic that will be evaluated under the permutation distribution. 
%cfg.minnbchan          = 2;                                % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0).
cfg.neighbours          = neighbours;   
cfg.tail                = 0;                                % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail         = 0;
cfg.alpha               = 0.05;                            % alpha level of the permutation test
cfg.numrandomization    = 2000;                              % number of draws from the permutation distribution
cfg.correcttail         = 'prob';

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

[stat]                  = ft_timelockstatistics(cfg, Condition1{:}, Condition2{:});

%save stat_ERP stat;

% grand-average over subjects per condition 
cfg = [];
cond1 = ft_timelockgrandaverage(cfg, Condition1{:});
cond2 = ft_timelockgrandaverage(cfg, Condition2{:});


% Then take the difference of the averages using ft_math
cfg  = [];
cfg.operation = 'subtract';
cfg.parameter = 'avg';
raweffect = ft_math(cfg,cond1,cond2);

% get relevant (significant) values
pos_cluster_pvals = [stat.posclusters(:).prob];
pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
pos = ismember(stat.posclusterslabelmat, pos_signif_clust);

neg_cluster_pvals = [stat.negclusters(:).prob];
neg_signif_clust = find(neg_cluster_pvals < stat.cfg.alpha);
neg = ismember(stat.negclusterslabelmat, neg_signif_clust); 

% Indicate how many sign. clusters, time period of sign. clusters, channels
% of sign. clusters

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
        %figure;
        %colormap(redblue);
        %colorbar('eastoutside');
        %cfg = [];
        %cfg.xlim=[starttime endtime];  % in seconds!
        %cfg.zlim = [-3 3];
        %cfg.layout = 'actiCAP_64ch_Standard2.mat';
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
        %figure;
        %colormap(redblue);
        %colorbar('eastoutside');
        %cfg = [];
        %cfg.xlim=[starttime endtime];  % in seconds!
        %cfg.zlim = [-5 5];
        %cfg.layout = 'actiCAP_64ch_Standard2.mat';
        %ft_topoplotER(cfg, raweffect);
        
        disp(['Negative cluster ', num2str(i), ' starts at ', num2str(starttime), ' s and ends at ', num2str(endtime), ' s'])
        disp(['the following ', num2str(length(unique(foundx'))),' channels are included in this significant cluster:  ', num2str(unique(foundx'))])
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
    end
end