%% Oscillations grand average for median splits

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
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)

Condition1 = cell(1,length(subjects));
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic1_mediansplit_high_1');
    dummy = load(filename1);
    Condition1{i} = ft_freqanalysis(cfg, dummy.up1);
    clear dummy
end

% grand-average over subjects per condition 
cfg = [];
cfg.keepindividual='no';
cond1 = ft_freqgrandaverage(cfg, Condition1{:});


% frequency decomposition settings
cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'EEG';
cfg.method       = 'mtmconvol';
cfg.pad          = 'nextpow2'; 
cfg.taper        = 'hanning';
cfg.foi          = 2:1:30;                         % analysis 4 to 30 Hz in steps of 1 Hz 
cfg.t_ftimwin    = 3 ./ cfg.foi;                    %ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.5:0.05:1.5;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
Condition2 = cell(1,length(subjects));
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\PreprocessedData\', num2str(subjects(i)), '_Pic1_mediansplit_low_1');
    dummy2 = load(filename2);
    Condition2{i} = ft_freqanalysis(cfg, dummy2.low1);
    clear dummy2
end

% grand-average over subjects per condition 
cfg = [];
cfg.keepindividual='no';
cond2 = ft_freqgrandaverage(cfg, Condition2{:});

% calculate difference between conditions
diff = cond1;
diff.powspctrm = (cond1.powspctrm - cond2.powspctrm) ./ ((cond1.powspctrm + cond2.powspctrm)/2);
% this calculates the difference between the high and low median split
% groups, such that a positive difference reflects more X for the high vs.
% the low median split trials --> we expect more theta in the comparison

% one channel
cfg = [];
cfg.channel      = {'Cz'};
%cfg.channel    = {'Fz', 'Cz', 'FCz', 'CPz', 'Pz', 'CP1', 'CP2'};
%cfg.colormap      = redblue;
cfg.zlim         = 'maxabs'; %[-.18 .18]; %
figure 
ft_singleplotTFR(cfg, diff);
