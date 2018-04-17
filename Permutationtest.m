% Loading all preprocessed data 
subjects = [301:308, 310:326, 328, 329];  % subjects that should be included in grand average
cfg = [];
cfg.keeptrials='no';
cfg.baseline = [-0.2 0];
Condition1 = cell(1,27);
Condition2 = cell(1,27);
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_timelockanalysis(cfg, dummy.data_cond1);
    Condition1{i} = ft_timelockbaseline(cfg, Condition1{i});
    clear dummy
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_timelockanalysis(cfg, dummy2.data_cond2);
    Condition2{i} = ft_timelockbaseline(cfg, Condition2{i});
    clear dummy2
end

%% Neighbourhood definition
cfg_neighb                  = [];
cfg_neighb.method           = 'distance';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'actiCAP_64ch_Standard2.mat';
cfg_neighb.feedback         = 'yes';
cfg_neighb.neighbourdist    = 0.15;                                         % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, Condition1{1});

%% cluster based permutation test
% configuration settings
cfg                     = [];
cfg.channel             = 'EEG';        % cell-array with selected channel labels
cfg.latency             = [0 1];      % time interval over which the experimental conditions must be compared (in seconds)
cfg.method              = 'montecarlo'; % use the Monte Carlo Method to calculate the significance probability
cfg.statistic           = 'depsamplesT';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;         % alpha level of the sample-specific test statistic that will be used for thresholding
cfg.clusterstatistic    = 'maxsum';     % test statistic that will be evaluated under the permutation distribution. 
cfg.minnbchan           = 2;            % minimum number of neighborhood channels that is required for a selected sample to be included in the clustering algorithm (default=0).                                        
cfg.neighbours          = neighbours;   
cfg.tail                = 0;            % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfg.clustertail         = 0;
cfg.alpha               = 0.05;        % alpha level of the permutation test
cfg.numrandomization    = 500;         % number of draws from the permutation distribution
cfg.correcttail         = 'prob';      % correcting for two-sided test

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

cfg.design              = design;        % design matrix 
cfg.uvar                = 1;             % unit variable
cfg.ivar                = 2;             % number or list with indices indicating the independent variable(s) EDIT FOR WITHIN

[stat] = ft_timelockstatistics(cfg, Condition1{:}, Condition2{:});

%save stat_ERP stat;

%% plot the results

%use of timelock grand average
cfg                 = [];
cfg.channel         = 'all';
cfg.latency         = [0 1];
cfg.parameter       = 'avg';
cond1               = ft_timelockgrandaverage(cfg, Condition1{:});
cond2               = ft_timelockgrandaverage(cfg, Condition2{:});

% plots
cfg                 = [];
cfg.operation       = 'subtract';
cfg.parameter       = 'avg';
contrast            = ft_math(cfg, cond1, cond2);

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
        figure;
        colormap(redblue);
        colorbar('eastoutside');
        cfg = [];
        cfg.xlim=[starttime endtime];  % in seconds!
        %cfg.zlim = [-5 5];
        cfg.layout = 'actiCAP_64ch_Standard2.mat';
        ft_topoplotER(cfg, raweffect);
        
        disp(['Negative cluster ', num2str(i), ' starts at ', num2str(starttime), ' s and ends at ', num2str(endtime), ' s'])
        disp(['the following ', num2str(length(unique(foundx'))),' channels are included in this significant cluster:  ', num2str(unique(foundx'))])
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
    end
end

% define parameters for plotting
timestep = 0.05; % in seconds, this can be changed to for example 0.02 for small time windows. otherwise, keep at 0.05
sampling_rate = 500;
sample_count = length(stat.time);
j = [0:timestep:1];
m = [1:timestep*sampling_rate:sample_count];

figure;

% plot positive clusters
if numberofsignclusters > 0
    for k = 1:(length(m)-1)
        if (length(m)-1)>1
            if mod((length(m)-1),2) == 0
                subplot(2,(length(m)-1)/2,k);
            else
                subplot(1,(length(m)-1),k);
            end
        end
        cfg = [];
        cfg.xlim=[stat.time(m(k)) stat.time(m(k+1))];
        %cfg.ylim = [-3e-13 3e-13];
        pos_int = all(pos(:, m(k):m(k+1)), 2);
        cfg.highlight = 'on';
        cfg.highlightchannel = find(pos_int);
        cfg.comment = 'xlim';
        cfg.commentpos = 'title';
        cfg.layout = 'actiCAP_64ch_Standard2.mat';
        ft_topoplotER(cfg, raweffect);
    end
end

% plot positive clusters
if numberofsignclustersneg > 0
    for k = 1:(length(m)-1)
        if (length(m)-1)>1
            if mod((length(m)-1),2) == 0
                subplot(2,(length(m)-1)/2,k);
            else
                subplot(1,(length(m)-1),k);
            end
        end
        cfg = [];
        cfg.xlim=[stat.time(m(k)) stat.time(m(k+1))];
        %cfg.ylim = [-3e-13 3e-13];
        neg_int = all(neg(:, m(k):m(k+1)), 2);
        cfg.highlight = 'on';
        cfg.highlightchannel = find(neg_int);
        cfg.comment = 'xlim';
        cfg.commentpos = 'title';
        cfg.layout = 'actiCAP_64ch_Standard2.mat';
        ft_topoplotER(cfg, raweffect);
    end
end
