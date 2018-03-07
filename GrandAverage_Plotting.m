%% Loading all preprocessed data 

subjects = [301:307, 310:312, 314:320, 322:326, 328, 329]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 
cfg = [];
cfg.keeptrials='yes';

for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('PreprocessedData\', num2str(subjects(i)), '_data_clean_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_timelockanalysis(cfg, dummy.data_finaltestcond1);
    % condition 2 for each participant
    filename2 = strcat('PreprocessedData\', num2str(subjects(i)), '_data_clean_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_timelockanalysis(cfg, dummy2.data_finaltestcond2);
end

% grand-average over subjects per condition 
cfg = [];
cfg.keeptrials='yes';
cond1 = ft_timelockgrandaverage(cfg, Condition1{:});
cond2 = ft_timelockgrandaverage(cfg, Condition2{:});

% plotting average
cfg = [];
%cfg.demean = 'yes'; %baseline
%cfg.baselinewindow = [-0.5 0]; %baseline
cfg.layout = 'actiCAP_64ch_Standard2.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
cfg.showlabels = 'yes'; 
cfg.fontsize = 6; 
%cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, cond1, cond2);

% manual plot with some electrodes
fig = figure;

subplot(5,5,3);
plot ((cond1.time)*1000, cond1.avg(36,:), 'k', (cond1.time)*1000, cond2.avg(36,:), 'r');
title('AFz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,6);
plot ((cond1.time)*1000, cond1.avg(26,:), 'k', (cond1.time)*1000, cond2.avg(26,:), 'r');
title('FC5');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,7);
plot ((cond1.time)*1000, cond1.avg(28,:), 'k', (cond1.time)*1000, cond2.avg(28,:), 'r');
title('F3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,8);
plot ((cond1.time)*1000, cond1.avg(25,:), 'k', (cond1.time)*1000, cond2.avg(25,:), 'r');
title('Fz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,9);
plot ((cond1.time)*1000, cond1.avg(2,:), 'k', (cond1.time)*1000, cond2.avg(2,:), 'r');
title('F4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');


subplot(5,5,10);
plot ((cond1.time)*1000, cond1.avg(4,:), 'k', (cond1.time)*1000, cond2.avg(4,:), 'r');
title('FC6');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,11);
plot ((cond1.time)*1000, cond1.avg(18,:), 'k', (cond1.time)*1000, cond2.avg(18,:), 'r');
title('CP5');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,12);
plot ((cond1.time)*1000, cond1.avg(21,:), 'k', (cond1.time)*1000, cond2.avg(21,:), 'r');
title('C3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,13);
plot ((cond1.time)*1000, cond1.avg(12,:), 'k', (cond1.time)*1000, cond2.avg(12,:), 'r');
title('Cz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,14);
plot ((cond1.time)*1000, cond1.avg(5,:), 'k',(cond1.time)*1000, cond2.avg(5,:), 'r');
title('C4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,15);
plot ((cond1.time)*1000, cond1.avg(8,:), 'k', (cond1.time)*1000, cond2.avg(8,:), 'r');
title('CP6');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,17);
plot ((cond1.time)*1000, cond1.avg(17,:), 'k', (cond1.time)*1000, cond2.avg(17,:), 'r');
title('P3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,18);
plot ((cond1.time)*1000, cond1.avg(13,:), 'k', (cond1.time)*1000, cond2.avg(13,:), 'r');
title('Pz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,19);
plot ((cond1.time)*1000, cond1.avg(11,:), 'k',(cond1.time)*1000, cond2.avg(11,:), 'r');
title('P4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');


subplot(5,5,22);
plot ((cond1.time)*1000, cond1.avg(15,:), 'k', (cond1.time)*1000, cond2.avg(15,:), 'r');
title('O1');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,23);
plot ((cond1.time)*1000, cond1.avg(14,:), 'k', (cond1.time)*1000, cond2.avg(14,:), 'r');
title('Oz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(5,5,24);
plot ((cond1.time)*1000, cond1.avg(10,:), 'k', (cond1.time)*1000, cond2.avg(10,:), 'r');
title('O2');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

h = get(gca,'Children');
v = [h(1) h(3)];
legend1 = legend(v,'Interference', 'No interference');
set(legend1,...
    'Position',[0.817402439320025 0.207759699624531 0.0596115241601035 0.108208554452382]);