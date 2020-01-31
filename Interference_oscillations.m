%%% Oscillation - Interference Phase 

% Loading all preprocessed data 

subjects = [301:302, 304:308, 310:319, 321:326, 328, 329]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
Condition1 = cell(1,length(subjects));
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Fam_data_clean_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.data_fam_cond1);
    clear dummy
end

% grand-average over subjects per condition 
cfg = [];
cfg.keepindividual='no';
cond1 = ft_freqgrandaverage(cfg, Condition1{:});
%clear Condition1

% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
Condition2 = cell(1,length(subjects));
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Fam_data_clean_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.data_fam_cond2); %data_pic1_cond2
    clear dummy2
end

% grand-average over subjects per condition 
cfg = [];
cfg.keepindividual='no';
cond2 = ft_freqgrandaverage(cfg, Condition2{:});
%clear Condition2

% difference wave
diff = cond1;
diff.powspctrm = (cond1.powspctrm - cond2.powspctrm) ./ ((cond1.powspctrm + cond2.powspctrm)/2);

% create an effect structure which is the weighted diff
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

% one channel
cfg = [];
%cfg.baseline     = [-0.5 -0.1];
%cfg.baselinetype = 'absolute';  
%cfg.maskstyle    = 'saturation';	
%cfg.zlim         = [-3e-27 3e-27];	
cfg.channel      = {'Cz'};
%cfg.colormap      = redblue;
figure 
ft_singleplotTFR(cfg, diff);

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

%[stat]                  = ft_freqstatistics(cfg, Condition1{:}, Condition2{:});
%%% different type of analysis
[stat]                 = ft_freqstatistics(cfg, effect, null);
