clear;
addpath(genpath('include'));

skip_charts_previously_processed = false;

%% FILE NAMES

experiment = 'ElectricalAndLaser';
% experiment = 'ElectricalOnly';

% Input and output file names
switch experiment
    
    case 'ElectricalAndLaser'
        charts = {
            'data/hl_201605027/hl_201605027 002.axgd' ...
            'data/hl_201605027/hl_201605027 003.axgd' ...
            'data/hl_201605027/hl_201605027 004.axgd' ...
            'data/hl_201605027/hl_201605027 005.axgd' ...
            'data/hl_201605027/hl_201605027 006.axgd' ...
            'data/hl_201605027/hl_201605027 007.axgd' ...
            'data/hl_201605027/hl_201605027 008.axgd' ...
            'data/hl_201605027/hl_201605027 009.axgd' ...
            'data/hl_201605027/hl_201605027 010.axgd' ...
            };
        combined_results_filename = 'data/hl_201605027/AllChartsProcessed.mat';
    
    case 'ElectricalOnly'
        charts = {
            'data/10.11.2016/10.11.2016 005.axgd' ...
            'data/10.11.2016/10.11.2016 006.axgd' ...
            'data/10.11.2016/10.11.2016 007.axgd' ...
            'data/10.11.2016/10.11.2016 008.axgd' ...
            'data/10.11.2016/10.11.2016 009.axgd' ...
            };
        combined_results_filename = 'data/10.11.2016/AllChartsProcessed.mat';
end


%% EXPERIMENT PARAMETERS

channel_to_process        = 'dist (V)';
channel_with_stim_trigger = 'dist (V)';
%stim_freq = 2; % in Hz


%% ANALYSIS PARAMETERS
%findpeaks_threshold = 500; % voltage threshold in uV for detecting stim on channel_with_stim_trigger
%CAPlength = 800; % the length in number of samples of the extracted CAP, 800 samples @ 5 kHz = 160 ms
%Bias = 0; % an offset in number of samples for starting CAP extraction relative to detected stim trigger


%% PROCESS DATA

% Initialize arrays to hold data from all charts
TrialsPerChart              = [];
TrialTimesAllCharts         = [];
DurationsPerChart           = [];
CAPsignalAllCharts          = [];
ParaScanAllCharts           = [];
ParaScan2AllCharts          = [];
ArtifactHeightAllCharts     = [];
ArtifactLocationAllCharts   = [];
ArtifactWidthAllCharts      = [];
ArtifactProminenceAllCharts = [];

% Process charts one at a time
for i = 1 : length(charts)
    
    % Determine input file name
    input_filename = charts{i};
    fprintf('Processing chart %d of %d ...\n', i, length(charts));
    tic; % start a timer
    
    % Determine output file name
    [pathstr, name, ext] = fileparts(input_filename);
    output_filename = fullfile(pathstr, strcat(name, ' - Processed.mat'));
    
    % Process chart and save results to file if output file does not
    % already exist, otherwise load output file
    if ~skip_charts_previously_processed || ~exist(output_filename, 'file')
        
        result = ProcessChart(input_filename, channel_to_process, channel_with_stim_trigger);
        fprintf('saving results ...\n');
        save(output_filename, 'result');
        
    else
        
        fprintf('loading pre-processed data ... (you may delete ''%s'' to re-process)\n', output_filename);
        load(output_filename);
        
    end
    
    fprintf('combining chart results ...\n');
    TrialsPerChart              = [TrialsPerChart;              result.n_trials];
    TrialTimesAllCharts         = [TrialTimesAllCharts;         sum(DurationsPerChart)+result.stim_times];
    DurationsPerChart           = [DurationsPerChart;           result.duration];
    CAPsignalAllCharts          = [CAPsignalAllCharts;          result.CAPsignal];
    ParaScanAllCharts           = [ParaScanAllCharts;           result.ParaScan];
    ParaScan2AllCharts          = [ParaScan2AllCharts;          result.ParaScan2];
    ArtifactHeightAllCharts     = [ArtifactHeightAllCharts;     result.artifact_height];
    ArtifactLocationAllCharts   = [ArtifactLocationAllCharts;   result.artifact_location];
    ArtifactWidthAllCharts      = [ArtifactWidthAllCharts;      result.artifact_width];
    ArtifactProminenceAllCharts = [ArtifactProminenceAllCharts; result.artifact_prominence];
    
    toc; % print elapsed time since start of timer
    fprintf('\n');
end


%% SAVE COMBINED RESULTS

fprintf('Saving combined chart results ...\n');
ArtifactLength = result.artifact_length;  % assuming this is the same for all charts
ArtifactNPeaks = result.n_artifact_peaks; % assuming this is the same for all charts
SampleFreq = result.sample_freq;          % assuming this is the same for all charts
SampleTimes = result.sample_times;        % assuming this is the same for all charts
StimFreq = result.stim_freq;              % assuming this is the same for all charts
save(combined_results_filename, ...
    'ArtifactHeightAllCharts', ...
    'ArtifactLength', ...
    'ArtifactLocationAllCharts', ...
    'ArtifactNPeaks', ...
    'ArtifactProminenceAllCharts', ...
    'ArtifactWidthAllCharts', ...
    'CAPsignalAllCharts', ...
    'DurationsPerChart', ...
    'ParaScanAllCharts', ...
    'ParaScan2AllCharts', ...
    'SampleFreq', ...
    'SampleTimes', ...
    'StimFreq', ...
    'TrialsPerChart', ...
    'TrialTimesAllCharts' ...
    );
