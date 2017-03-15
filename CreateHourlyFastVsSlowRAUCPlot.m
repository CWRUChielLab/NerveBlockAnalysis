close all;
clear;


%% PARAMETERS

CAP1StartTime = -8; % in ms relative to CAP1 peak
CAP1EndTime   =  6; % in ms relative to CAP1 peak


%% ELECTRICAL + LASER EXPERIMENT WITH LASER OFF

load('data/hl_201605027/AllChartsProcessed.mat');

% Periods of time in seconds during which the laser was off and current was
% fixed. These numbers come from an email from Emilie dated 2017-01-16 with
% the subject line "axograph time points"
TrialBlockTimes = { ...
    [   3,     12.5] + sum(DurationsPerChart(1:0)); ... % hour 0
    [  27,     37]   + sum(DurationsPerChart(1:1)); ... % hour 1
    [   3,     12.5] + sum(DurationsPerChart(1:2)); ... % hour 2
    [   3,     13]   + sum(DurationsPerChart(1:3)); ... % hour 3
    [  17,     27]   + sum(DurationsPerChart(1:4)); ... % hour 4
    [   3.5,   13]   + sum(DurationsPerChart(1:5)); ... % hour 5
    [   2.5,   12]   + sum(DurationsPerChart(1:6)); ... % hour 6
    [  31.4,   41.2] + sum(DurationsPerChart(1:7)); ... % hour 7
    [   8.5,   18.2] + sum(DurationsPerChart(1:8)); ... % hour 8
    [3625.7, 3635.7] + sum(DurationsPerChart(1:8)); ... % hour 9 -- these times are not included in the email and were determined by JPG
    };

ElectricalAndLaserWithLaserOff = MeasureFastAndSlowRAUC(TrialBlockTimes, TrialTimesAllCharts, CAP1StartTime, CAP1EndTime, CAP1TimesAllCharts, SampleTimes, ParaScanAllCharts);


%% ELECTRICAL + LASER EXPERIMENT WITH LASER ON

% Periods of time in seconds during which the laser was ON and current was
% THE SAME as samples above (when laser was off), selected by JPG

% artifact_size = 'Large artifacts';
% TrialBlockTimes = { ...
%     [  85.4,   95.4] + sum(DurationsPerChart(1:0)); ... % hour 0 -- CAP1 alone every trial
%     [ 139.6,  149.6] + sum(DurationsPerChart(1:1)); ... % hour 1 -- CAP1 alone every trial
%     [ 282.5,  292.5] + sum(DurationsPerChart(1:2)); ... % hour 2 -- CAP1 and medium units every trial
%     [  80.2,   90.2] + sum(DurationsPerChart(1:3)); ... % hour 3 -- CAP1 alone every trial
%     [  88.6,   98.6] + sum(DurationsPerChart(1:4)); ... % hour 4 -- CAP1 alone every trial
%     [  80,     90]   + sum(DurationsPerChart(1:5)); ... % hour 5 -- CAP1 alone every trial
%     [  50.3,   60.3] + sum(DurationsPerChart(1:6)); ... % hour 6 -- CAP1 alone every trial
%     [ 113.4,  123.4] + sum(DurationsPerChart(1:7)); ... % hour 7 -- CAP1 alone every trial
%     [  85.3,   95.3] + sum(DurationsPerChart(1:8)); ... % hour 8 -- CAP1 alone every trial
%     [2089,   2099]   + sum(DurationsPerChart(1:8)); ... % hour 9 -- CAP1 alone every trial
%     ...[3583.8, 3593.8] + sum(DurationsPerChart(1:8)); ... % hour 9 -- no units firing closer to hour 9 mark
%     };

artifact_size = 'Small artifacts';
TrialBlockTimes = { ...
    [  96.9,  106.9] + sum(DurationsPerChart(1:0)); ... % hour 0 -- CAP1 alone every trial
    [ 151,    161]   + sum(DurationsPerChart(1:1)); ... % hour 1 -- CAP1 alone every trial
    [ 294,    304]   + sum(DurationsPerChart(1:2)); ... % hour 2 -- CAP1 and medium units every trial
    [  60,     70]   + sum(DurationsPerChart(1:3)); ... % hour 3 -- CAP1 alone every trial
    [  101.1, 111.1] + sum(DurationsPerChart(1:4)); ... % hour 4 -- CAP1 alone every trial
    [  60,     70]   + sum(DurationsPerChart(1:5)); ... % hour 5 -- CAP1 alone every trial
    [  62.8,   72.8] + sum(DurationsPerChart(1:6)); ... % hour 6 -- CAP1 alone every trial
    [  91.4,  101.4] + sum(DurationsPerChart(1:7)); ... % hour 7 -- CAP1 alone every trial
    [  97.8,  107.8] + sum(DurationsPerChart(1:8)); ... % hour 8 -- CAP1 alone every trial
    [2066.5, 2076.5] + sum(DurationsPerChart(1:8)); ... % hour 9 -- CAP1 alone every trial
    ...[3597.3, 3607.3] + sum(DurationsPerChart(1:8)); ... % hour 9 -- no units firing closer to hour 9 mark
    };

ElectricalAndLaserWithLaserOn = MeasureFastAndSlowRAUC(TrialBlockTimes, TrialTimesAllCharts, CAP1StartTime, CAP1EndTime, CAP1TimesAllCharts, SampleTimes, ParaScanAllCharts);


%% ELECTRICAL ONLY EXPERIMENT

load('data/10.11.2016/AllChartsProcessed.mat');

% hour1 through hour9 will be sampled at precisely the same times as the
% electrical & laser experiment. The timing of hour9 in the electrical only
% experiment was verified to precede the end-of-experiment adjustments made
% to the current, which occur after the last chart was stopped and
% restarted near its end. hour0 must be sampled at a slightly different
% time because the first trials begin a few seconds later in this
% experiment.
TrialBlockTimes = ElectricalAndLaserWithLaserOff.TrialBlockTimes;
TrialBlockTimes{1} = [10, 20]; % hour 0

ElectricalOnly = MeasureFastAndSlowRAUC(TrialBlockTimes, TrialTimesAllCharts, CAP1StartTime, CAP1EndTime, CAP1TimesAllCharts, SampleTimes, ParaScanAllCharts);


%% CREATE PLOT

set(0,'DefaultAxesFontSize', 14);
hf1 = figure;
hold on;

ax = gca;
ax.Clipping = 'off';

% normalize by initial RAUC with laser OFF
ElectricalAndLaserWithLaserOff.CAP1_normalization_factor = mean(ElectricalAndLaserWithLaserOff.CAP1_RAUC{1});
ElectricalAndLaserWithLaserOff.CAP2_normalization_factor = mean(ElectricalAndLaserWithLaserOff.CAP2_RAUC{1});
ElectricalAndLaserWithLaserOn.CAP1_normalization_factor  = mean(ElectricalAndLaserWithLaserOff.CAP1_RAUC{1});
ElectricalAndLaserWithLaserOn.CAP2_normalization_factor  = mean(ElectricalAndLaserWithLaserOff.CAP2_RAUC{1});
ElectricalOnly.CAP1_normalization_factor                 = mean(ElectricalOnly.CAP1_RAUC{1});
ElectricalOnly.CAP2_normalization_factor                 = mean(ElectricalOnly.CAP2_RAUC{1});

errorbar( ...
    ElectricalAndLaserWithLaserOff.block_time_mean, ...
    ElectricalAndLaserWithLaserOff.CAP1_RAUC_mean   / ElectricalAndLaserWithLaserOff.CAP1_normalization_factor, ...
    ElectricalAndLaserWithLaserOff.CAP1_RAUC_stderr / ElectricalAndLaserWithLaserOff.CAP1_normalization_factor, ...
    'b-', ...
    'LineWidth', 2);
errorbar( ...
    ElectricalAndLaserWithLaserOn.block_time_mean, ...
    ElectricalAndLaserWithLaserOn.CAP1_RAUC_mean   / ElectricalAndLaserWithLaserOn.CAP1_normalization_factor, ...
    ElectricalAndLaserWithLaserOn.CAP1_RAUC_stderr / ElectricalAndLaserWithLaserOn.CAP1_normalization_factor, ...
    'r-', ...
    'LineWidth', 2);
% errorbar( ...
%     ElectricalOnly.block_time_mean, ...
%     ElectricalOnly.CAP1_RAUC_mean   / ElectricalOnly.CAP1_normalization_factor, ...
%     ElectricalOnly.CAP1_RAUC_stderr / ElectricalOnly.CAP1_normalization_factor, ...
%     'g-', ...
%     'LineWidth', 2);
errorbar( ...
    ElectricalAndLaserWithLaserOff.block_time_mean, ...
    ElectricalAndLaserWithLaserOff.CAP2_RAUC_mean   / ElectricalAndLaserWithLaserOff.CAP2_normalization_factor, ...
    ElectricalAndLaserWithLaserOff.CAP2_RAUC_stderr / ElectricalAndLaserWithLaserOff.CAP2_normalization_factor, ...
    'b--', ...
    'LineWidth', 2);
errorbar( ...
    ElectricalAndLaserWithLaserOn.block_time_mean, ...
    ElectricalAndLaserWithLaserOn.CAP2_RAUC_mean   / ElectricalAndLaserWithLaserOn.CAP2_normalization_factor, ...
    ElectricalAndLaserWithLaserOn.CAP2_RAUC_stderr / ElectricalAndLaserWithLaserOn.CAP2_normalization_factor, ...
    'r--', ...
    'LineWidth', 2);
% errorbar( ...
%     ElectricalOnly.block_time_mean, ...
%     ElectricalOnly.CAP2_RAUC_mean   / ElectricalOnly.CAP2_normalization_factor, ...
%     ElectricalOnly.CAP2_RAUC_stderr / ElectricalOnly.CAP2_normalization_factor, ...
%     'g--', ...
%     'LineWidth', 2);

title('Changes in RAUC over 9 Hours of Optical Block for Fast vs. Slow CAP Components');

xlim([0 max([ElectricalAndLaserWithLaserOff.block_time_mean; ElectricalAndLaserWithLaserOn.block_time_mean])]);
% xlim([0 max([ElectricalAndLaserWithLaserOff.block_time_mean; ElectricalAndLaserWithLaserOn.block_time_mean; ElectricalOnly.block_time_mean])]);

ylim([0.6 1.1]);
% ylim([0 1.1]);

xlabel('Time (hours)');
ylabel({
    'Rectified area under the curve'
    '(mean +/- SE, normalized by initial value with laser off)'
    });

legend( ...
    'Fastest unit, laser off', ...
    'Fastest unit, laser on', ...
    'Slow units, laser off', ...
    'Slow units, laser on', ...
    'Location', ...
    'southwest' ...
    );
% legend( ...
%     'Fastest unit, laser off (experiment A)', ...
%     'Fastest unit, laser on (experiment A)', ...
%     'Fastest unit, laser never applied (experiment B)', ...
%     'Slow units, laser off (experiment A)', ...
%     'Slow units, laser on (experiment A)', ...
%     'Slow units, laser never applied (experiment B)', ...
%     'Location', ...
%     'southwest' ...
%     );

set(gcf, 'color', 'w');

filename = ['figures/Hourly RAUC with and without laser - Fast vs slow - ', artifact_size, '.png'];
% filename = ['figures/Hourly RAUC with and without laser - Fast vs slow - Including ElectricalOnly - ', artifact_size, '.png'];

set(hf1, 'Units', 'normalized', 'Position', [0,0,1,1]);
hgexport(hf1, filename, hgexport('factorystyle'), 'Format', 'png');


%% MEASURE FAST AND SLOW UNIT RAUC

function s = MeasureFastAndSlowRAUC(TrialBlockTimes, TrialTimesAllCharts, CAP1StartTime, CAP1EndTime, CAP1TimesAllCharts, SampleTimes, ParaScanAllCharts)
%MeasureFastAndSlowRAUC Measure RAUC mean, stderr for fast and slow units.
%   s = MeasureFastAndSlowRAUC(...) (see source for arguments) identifies
%   trials within blocks of time specified by TrialBlockTimes, measures the
%   rectified area under the curve (RAUC) for all trials in a block for the
%   fastest and all slower units separately (the bounds of the fastest unit
%   are set by CAP1StartTime and CAP1EndTime), and computes the mean and
%   standard error of the RAUCs. Results are returned in a struct s.

% include the trial block times in the result
s.TrialBlockTimes = TrialBlockTimes;

% count the number of trial blocks
s.n_blocks = length(s.TrialBlockTimes);

% identify the indices of all trials within each trial block
s.trial_idx = cell(s.n_blocks, 1);
for i = 1 : s.n_blocks
    s.trial_idx{i} = find( TrialTimesAllCharts > s.TrialBlockTimes{i}(1) & ...
                           TrialTimesAllCharts < s.TrialBlockTimes{i}(2) );
end

% count the number of trials in each trial block
s.n_trials = cellfun(@length, s.trial_idx);
fprintf('Number of trials found: %s\n', num2str(s.n_trials'));

% create lists of the start and end sample times for the fastest unit in
% each trial
s.CAP1_times = cell(s.n_blocks, 1);
for i = 1 : s.n_blocks
    s.CAP1_times{i} = bsxfun(@plus, [CAP1StartTime CAP1EndTime], CAP1TimesAllCharts(s.trial_idx{i}));
end

s.CAP1_idx  = cell(s.n_blocks, 1);
s.CAP1_RAUC = cell(s.n_blocks, 1);
s.CAP2_RAUC = cell(s.n_blocks, 1);

% for each trial block
for i = 1 : s.n_blocks
    
    s.CAP1_idx{i}  = cell(s.n_trials(i), 1);
    s.CAP1_RAUC{i} = zeros(s.n_trials(i), 1);
    s.CAP2_RAUC{i} = zeros(s.n_trials(i), 1);
    
    % for each trial within the trial block
    for j = 1 : s.n_trials(i)
        
        % if the fastest unit was identified
        if all(isfinite(s.CAP1_times{i}(j,:)))
            
            % identify the indices of all samples within the fastest unit
            s.CAP1_idx{i}{j}  = find( SampleTimes > s.CAP1_times{i}(j,1) & ...
                                      SampleTimes < s.CAP1_times{i}(j,2) );
            
            % measure the RAUC for all slower units following the fastest
            % unit
            s.CAP2_RAUC{i}(j) = ParaScanAllCharts(s.trial_idx{i}(j), max(s.CAP1_idx{i}{j})+1);
            
            % measure the RAUC of the fastest unit
            s.CAP1_RAUC{i}(j) = ParaScanAllCharts(s.trial_idx{i}(j), min(s.CAP1_idx{i}{j})) - s.CAP2_RAUC{i}(j);
            
        % else the fastest unit was not identified
        else
            
            % the trial cannot be used, so set the RAUC to zero
            s.CAP2_RAUC{i}(j) = 0;
            s.CAP1_RAUC{i}(j) = 0;
            
        end
    end
end

% compute the means and standard errors
s.block_time_mean  = cellfun(@mean, s.TrialBlockTimes) / 3600; % convert from sec to hr
s.CAP1_RAUC_mean   = cellfun(@mean, s.CAP1_RAUC);
s.CAP2_RAUC_mean   = cellfun(@mean, s.CAP2_RAUC);
s.CAP1_RAUC_stderr = cellfun(@std,  s.CAP1_RAUC) ./ sqrt(s.n_trials);
s.CAP2_RAUC_stderr = cellfun(@std,  s.CAP2_RAUC) ./ sqrt(s.n_trials);

end