%% Loading all preprocessed data 

subjects = [301:308, 310:317]; % subjects that should be included in grand average
cd('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\'); % directory with all preprocessed files 
%cd('/Volumes/wrkgrp/STD-Back-Up-Exp2-EEG') %
cfg = [];
cfg.keeptrials='no';
cfg.baseline = [-0.2 0];

Condition1 = cell(1,16);
for i = 1:length(subjects)
    % condition 1 for each participant
    filename1 = strcat('PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond1');
    dummy = load(filename1);
    Condition1{i} = ft_timelockanalysis(cfg, dummy.data_cond1);
    Condition1{i} = ft_timelockbaseline(cfg, Condition1{i});
    clear dummy filename1
    disp(subjects(i));
end
%save('\\cnas.ru.nl\wrkgrp\STD-Back-Up-Exp2-EEG\Condition1', 'Condition1', '-v7.3')
% grand-average over subjects per condition 
cfg = [];
cfg.keepindividuals='no';
cond1 = ft_timelockgrandaverage(cfg, Condition1{:});
clear Condition1

% load data Condition 2
cfg = [];
cfg.keeptrials='no';
cfg.baseline = [-0.2 0];
Condition2 = cell(1,16);
for i = 1:length(subjects)
    % condition 2 for each participant
    filename2 = strcat('PreprocessedData_secondhalf\', num2str(subjects(i)), '_data_clean_2_cond2');
    dummy2 = load(filename2);
    Condition2{i} = ft_timelockanalysis(cfg, dummy2.data_cond2);
    Condition2{i} = ft_timelockbaseline(cfg, Condition2{i});
    clear dummy2 filename2
    disp(subjects(i));
end
% grand-average over subjects per condition 
cfg = [];
cfg.keepindividuals='no';
cond2 = ft_timelockgrandaverage(cfg, Condition2{:});
clear Condition2

% plotting average
cfg = [];
cfg.layout = 'actiCAP_64ch_Standard2.mat';
cfg.interactive = 'yes';
cfg.showoutline = 'yes';
cfg.showlabels = 'yes'; 
cfg.fontsize = 6; 
%cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, cond1, cond2);

% manual plot with some electrodes
fig = figure;

subplot(8,8,3);
plot ((cond1.time)*1000, cond1.avg(57,:), 'r', (cond1.time)*1000, cond2.avg(57,:), 'k');
title('AF3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,4);
plot ((cond1.time)*1000, cond1.avg(37,:), 'r', (cond1.time)*1000, cond2.avg(37,:), 'k');
title('AFz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,5);
plot ((cond1.time)*1000, cond1.avg(30,:), 'r', (cond1.time)*1000, cond2.avg(30,:), 'k');
title('AF4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');


subplot(8,8,10);
plot ((cond1.time)*1000, cond1.avg(54,:), 'r', (cond1.time)*1000, cond2.avg(54,:), 'k');
title('F5');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,11);
plot ((cond1.time)*1000, cond1.avg(51,:), 'r', (cond1.time)*1000, cond2.avg(51,:), 'k');
title('F1');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,12);
plot ((cond1.time)*1000, cond1.avg(25,:), 'r', (cond1.time)*1000, cond2.avg(25,:), 'k');
title('Fz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,13);
plot ((cond1.time)*1000, cond1.avg(32,:), 'r', (cond1.time)*1000, cond2.avg(32,:), 'k');
title('F2');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,14);
plot ((cond1.time)*1000, cond1.avg(33,:), 'r', (cond1.time)*1000, cond2.avg(33,:), 'k');
title('F6');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,17);
plot ((cond1.time)*1000, cond1.avg(26,:), 'r', (cond1.time)*1000, cond2.avg(26,:), 'k');
title('FC5');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,18);
plot ((cond1.time)*1000, cond1.avg(52,:), 'r', (cond1.time)*1000, cond2.avg(52,:), 'k');
title('FC3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,19);
plot ((cond1.time)*1000, cond1.avg(22,:), 'r', (cond1.time)*1000, cond2.avg(22,:), 'k');
title('FC1');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,20);
plot ((cond1.time)*1000, cond1.avg(23,:), 'r', (cond1.time)*1000, cond2.avg(23,:), 'k');
title('FCZ');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,21);
plot ((cond1.time)*1000, cond1.avg(24,:), 'r', (cond1.time)*1000, cond2.avg(24,:), 'k');
title('FC2');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,22);
plot ((cond1.time)*1000, cond1.avg(53,:), 'r', (cond1.time)*1000, cond2.avg(53,:), 'k');
title('FC4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,23);
plot ((cond1.time)*1000, cond1.avg(4,:), 'r', (cond1.time)*1000, cond2.avg(4,:), 'k');
title('FC6');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,33);
plot ((cond1.time)*1000, cond1.avg(18,:), 'r', (cond1.time)*1000, cond2.avg(18,:), 'k');
title('CP5');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,25);
plot ((cond1.time)*1000, cond1.avg(48,:), 'r', (cond1.time)*1000, cond2.avg(48,:), 'k');
title('C5');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,26);
plot ((cond1.time)*1000, cond1.avg(21,:), 'r', (cond1.time)*1000, cond2.avg(21,:), 'k');
title('C3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,27);
plot ((cond1.time)*1000, cond1.avg(50,:), 'r', (cond1.time)*1000, cond2.avg(50,:), 'k');
title('C1');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,28);
plot ((cond1.time)*1000, cond1.avg(12,:), 'r', (cond1.time)*1000, cond2.avg(12,:), 'k');
title('Cz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,29);
plot ((cond1.time)*1000, cond1.avg(51,:), 'r', (cond1.time)*1000, cond2.avg(51,:), 'k');
title('C2');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,30);
plot ((cond1.time)*1000, cond1.avg(5,:), 'r',(cond1.time)*1000, cond2.avg(5,:), 'k');
title('C4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,31);
plot ((cond1.time)*1000, cond1.avg(35,:), 'r',(cond1.time)*1000, cond2.avg(35,:), 'k');
title('C6');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,34);
plot ((cond1.time)*1000, cond1.avg(47,:), 'r', (cond1.time)*1000, cond2.avg(47,:), 'k');
title('CP3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,35);
plot ((cond1.time)*1000, cond1.avg(19,:), 'r', (cond1.time)*1000, cond2.avg(19,:), 'k');
title('CP1');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,36);
plot ((cond1.time)*1000, cond1.avg(41,:), 'r', (cond1.time)*1000, cond2.avg(41,:), 'k');
title('CPz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,37);
plot ((cond1.time)*1000, cond1.avg(7,:), 'r', (cond1.time)*1000, cond2.avg(7,:), 'k');
title('CP2');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,38);
plot ((cond1.time)*1000, cond1.avg(36,:), 'r', (cond1.time)*1000, cond2.avg(36,:), 'k');
title('CP4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,39);
plot ((cond1.time)*1000, cond1.avg(8,:), 'r', (cond1.time)*1000, cond2.avg(8,:), 'k');
title('CP6');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,41);
plot ((cond1.time)*1000, cond1.avg(16,:), 'r', (cond1.time)*1000, cond2.avg(16,:), 'k');
title('P7');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,42);
plot ((cond1.time)*1000, cond1.avg(17,:), 'r', (cond1.time)*1000, cond2.avg(17,:), 'k');
title('P3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,43);
plot ((cond1.time)*1000, cond1.avg(42,:), 'r', (cond1.time)*1000, cond2.avg(42,:), 'k');
title('P1');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,44);
plot ((cond1.time)*1000, cond1.avg(13,:), 'r', (cond1.time)*1000, cond2.avg(13,:), 'k');
title('Pz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,45);
plot ((cond1.time)*1000, cond1.avg(40,:), 'r', (cond1.time)*1000, cond2.avg(40,:), 'k');
title('P2');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,46);
plot ((cond1.time)*1000, cond1.avg(11,:), 'r',(cond1.time)*1000, cond2.avg(11,:), 'k');
title('P4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,47);
plot ((cond1.time)*1000, cond1.avg(9,:), 'r', (cond1.time)*1000, cond2.avg(9,:), 'k');
title('P8');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,51);
plot ((cond1.time)*1000, cond1.avg(44,:), 'r', (cond1.time)*1000, cond2.avg(44,:), 'k');
title('PO3');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,52);
plot ((cond1.time)*1000, cond1.avg(43,:), 'r', (cond1.time)*1000, cond2.avg(43,:), 'k');
title('POz');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

subplot(8,8,53);
plot ((cond1.time)*1000, cond1.avg(39,:), 'r', (cond1.time)*1000, cond2.avg(39,:), 'k');
title('PO4');
ylim([-10 10]);
xlim([-200 1200]); 
hold on
line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
set(gca,'YDir','reverse');

% subplot(8,8,59);
% plot ((cond1.time)*1000, cond1.avg(15,:), 'r', (cond1.time)*1000, cond2.avg(15,:), 'k');
% title('O1');
% ylim([-10 10]);
% xlim([-200 1200]); 
% hold on
% line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
% line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
% set(gca,'YDir','reverse');
% 
% subplot(8,8,60);
% plot ((cond1.time)*1000, cond1.avg(14,:), 'r', (cond1.time)*1000, cond2.avg(14,:), 'k');
% title('Oz');
% ylim([-10 10]);
% xlim([-200 1200]); 
% hold on
% line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
% line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
% set(gca,'YDir','reverse');
% 
% subplot(8,8,61);
% plot ((cond1.time)*1000, cond1.avg(10,:), 'r', (cond1.time)*1000, cond2.avg(10,:), 'k');
% title('O2');
% ylim([-10 10]);
% xlim([-200 1200]); 
% hold on
% line('XData', [-200 1200], 'YData', [0 0], 'LineWidth', 1);
% line('XData', [0 0], 'YData', [-10 10], 'LineWidth', 0.5);
% set(gca,'YDir','reverse');

%h = get(gca,'Children');
%v = [h(1) h(3)];
legend1 = legend('Interference', 'No Interference');
set(legend1,...
    'Position',[0.817402439320025 0.207759699624531 0.0596115241601035 0.108208554452382]);