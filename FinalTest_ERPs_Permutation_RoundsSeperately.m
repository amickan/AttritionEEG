%%% Final test - ERPs - Permutation test %%%

%% Loading data 
% some global settings for plotting later on 
set(groot,'DefaultFigureColormap',jet);

subjects = [301:308, 310:326, 328, 329]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 

cfg = [];
cfg.keeptrials='no';
cfg.baseline = [-0.2 0];

Condition1 = cell(1,length(subjects));
Condition2 = cell(1,length(subjects));

for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf_new\', num2str(subjects(i)), '_data_clean_1_cond1_witherrors');
    %filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1_witherrors');
    dummy = load(filename1);
    Condition1{i} = ft_timelockanalysis(cfg, dummy.data_cond12);
    Condition1{i} = ft_timelockbaseline(cfg, Condition1{i});
    clear dummy
    
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_firsthalf_new\', num2str(subjects(i)), '_data_clean_1_cond2_witherrors');
    %filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2_witherrors');
    dummy2 = load(filename2);
    Condition2{i} = ft_timelockanalysis(cfg, dummy2.data_cond22);
    Condition2{i} = ft_timelockbaseline(cfg, Condition2{i});
    clear dummy2
end

%% Permutation test 

% Create neighbourhood structure
cfg_neighb                  = [];
cfg_neighb.method           = 'triangulation';        
cfg_neighb.channel          = 'EEG';
cfg_neighb.layout           = 'EEG1010.lay';
cfg_neighb.feedback         = 'yes';
cfg_neighb.neighbourdist    = 0.15; % higher number: more is linked!
neighbours                  = ft_prepare_neighbours(cfg_neighb, Condition1{1});

% Stats settings
cfg                     = [];
cfg.method              = 'montecarlo';       
cfg.channel             = {'EEG'};     
cfg.latency             = [0.35 1]; %[0.2 0.35];      
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

%% Permutation test results 

% calculate difference between conditions per subject 
cfg                 = [];
cfg.operation       = 'subtract';
cfg.parameter       = 'avg';
raweffect           = cell(1,length(subjects));
for i = 1:length(subjects)
    raweffect{i} = ft_math(cfg,Condition1{i},Condition2{i});
end

% grand average over participants difference scores
cfg                 = [];
raw                 = ft_timelockgrandaverage(cfg, raweffect{:});

% get relevant (significant) values
if isempty(stat.posclusters) == 0
    pos_cluster_pvals = [stat.posclusters(:).prob];
    pos_signif_clust = find(pos_cluster_pvals < stat.cfg.alpha);
    pos = ismember(stat.posclusterslabelmat, pos_signif_clust);
    selectpos = pos_cluster_pvals < stat.cfg.alpha;
    signclusterspos = pos_cluster_pvals(selectpos);
    numberofsignclusterspos = length(signclusterspos);
    disp(['there are ', num2str(numberofsignclusterspos), ' significant positive clusters']);
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

if numberofsignclusterspos > 0
    for i = 1:length(signclusterspos)
        disp(['Positive cluster number ', num2str(i), ' has a p value of ', num2str(signclusterspos(i))])
        select = ismember(stat.posclusterslabelmat, pos_signif_clust(i));
        pos2 = ismember (stat.posclusterslabelmat, pos_signif_clust(i));
        [foundx,foundy] = find(select);
        % pos_int2 = all(pos2(:, min(foundy):max(foundy)),2); % no channels are significant over the total sign. time period....
        % find(pos_int2) % see upper comment
        starttime = stat.time(min(foundy));
        endtime = stat.time(max(foundy));
        
        %%% Topoplot for the cluster 
        figure;
        %colormap(redblue);
        colorbar('eastoutside');
        cfg = [];
        cfg.xlim=[starttime endtime];  % in seconds!
        cfg.zlim = [-1.8 1.8];
        cfg.layout = 'EEG1010.lay';
        ft_topoplotER(cfg, raw);
        
        disp(['Positive cluster ', num2str(i), ' starts at ', num2str(starttime), ' s and ends at ', num2str(endtime), ' s'])
        disp(['Negative cluster ', num2str(i), ' has a cluster statistic of ', num2str(stat.posclusters(i).clusterstat), ' and a standard deviation of ',num2str(stat.posclusters(i).stddev),'.'])
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
        cfg.zlim = [-1.8 1.8];
        cfg.layout = 'EEG1010.lay';
        ft_topoplotER(cfg, raw);
        
        
        disp(['Negative cluster ', num2str(i), ' starts at ', num2str(starttime), ' s and ends at ', num2str(endtime), ' s']) 
        disp(['Negative cluster ', num2str(i), ' has a cluster statistic of ', num2str(stat.negclusters(i).clusterstat), ' and a standard deviation of ',num2str(stat.negclusters(i).stddev),'.' ])
        disp(['the following ', num2str(length(unique(foundx'))),' channels are included in this significant cluster:  ', num2str(unique(foundx'))])
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
    end
end

%% Extra plotting
% timestep = 0.05; % in seconds, this can be changed to for example 0.02 for small time windows. otherwise, keep at 0.05
% sampling_rate = 500;
% sample_count = length(stat.time);
% j = [0:timestep:1];
% m = [1:timestep*sampling_rate:sample_count];
% 
% figure;
% 
% % plot positive clusters
% if numberofsignclusters > 0
%     for k = 1:(length(m)-1)
%         if (length(m)-1)>1
%             if mod((length(m)-1),2) == 0
%                 subplot(2,(length(m)-1)/2,k);
%             else
%                 subplot(1,(length(m)-1),k);
%             end
%         end
%         cfg = [];
%         cfg.xlim=[stat.time(m(k)) stat.time(m(k+1))];
%         %cfg.ylim = [-3e-13 3e-13];
%         pos_int = all(pos(:, m(k):m(k+1)), 2);
%         cfg.highlight = 'on';
%         cfg.highlightchannel = find(pos_int);
%         cfg.comment = 'xlim';
%         cfg.commentpos = 'title';
%         cfg.layout = 'actiCAP_64ch_Standard2.mat';
%         ft_topoplotER(cfg, raweffect);
%     end
% end
% 
% % plot positive clusters
% if numberofsignclustersneg > 0
%     for k = 1:(length(m)-1)
%         if (length(m)-1)>1
%             if mod((length(m)-1),2) == 0
%                 subplot(2,(length(m)-1)/2,k);
%             else
%                 subplot(1,(length(m)-1),k);
%             end
%         end
%         cfg = [];
%         cfg.xlim=[stat.time(m(k)) stat.time(m(k+1))];
%         %cfg.ylim = [-3e-13 3e-13];
%         neg_int = all(neg(:, m(k):m(k+1)), 2);
%         cfg.highlight = 'on';
%         cfg.highlightchannel = find(neg_int);
%         cfg.comment = 'xlim';
%         cfg.commentpos = 'title';
%         cfg.layout = 'actiCAP_64ch_Standard2.mat';
%         ft_topoplotER(cfg, raweffect);
%     end
% end

%% Cluster plot 
% figure; 
% hold on; 
% channels    = stat.label;                               % Get the list of channels
% thing       = pos;                                      % Gets the datapoints in the cluster: stat.posclusterslabelmat / stat.negclusterslabelmat
% plot(stat.time, zeros(size(stat.time)), 'k');           % this is plotting a horizontal line to use as the x-axis
% hold on;
% title( ['Grand average cluster plot'], 'FontSize', 18); % puts a title on the plot
% set(gca, 'YLim', [0, length(stat.label)]);              % Sets the y-limit. This is based on my number of channels;
%     
% % Iterate through the channels, plotting a scatter of the 'active'
% % timepoints in each channel.
%  for chan= 1:length(stat.label)
%   value = stat.stat(chan, find(thing(chan,:)));
%   scatter(stat.time(find(thing(chan,:))), zeros(size(find(thing(chan,:))))+chan, 9,value, 'filled');
%  end
%    
%  % Edit the axes
%  set(gca, 'YTick', 0:length(stat.label), 'YTickLabel', [{''}; stat.label], 'XLim', [min(stat.time) max(stat.time)]); %This sets the y-axis ticks to be channel labels, instead of numbers
%  xlabel('Time (seconds)', 'FontSize', 16);              % Sets pretty x- and y-labels
%  ylabel('Channel', 'FontSize', 14');
%  set(gcf, 'Color', 'w');                                % gives a white background
%   
%  % sets the legend
%  colorbar;
%  colormap(redblue);
%  caxis([-5 5]);
%  h = colorbar;
%  xlabel(h,'T-values');