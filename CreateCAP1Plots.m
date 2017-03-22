close all;
clear;


%% GLOBAL SETTINGS

dir_exports = 'figures';
if ~exist(dir_exports, 'dir')
    mkdir(dir_exports)
end

set(0,'DefaultAxesFontSize', 14);

PlotTitle = [
    'CAP1 Sizes' ...
    ];

FigureFileName = [
    dir_exports '/' ...
    'CAP1' ...
    '.png' ...
    ];


%% EXPERIMENT SETTINGS

Experiments = { ...
    
    % ELECTRICAL & LASER EXPERIMENT
    struct( ...
        'id',    'ElectricalAndLaser', ...
        'title', 'Electrical & Laser', ...
        'data',  'data/hl_201605027/AllChartsProcessed.mat' ...
        ) ...

    % ELECTRICAL ONLY EXPERIMENT
    struct( ...
        'id',    'ElectricalOnly', ...
        'title', 'Electrical Only', ...
        'data',  'data/10.11.2016/AllChartsProcessed.mat' ...
        ) ...
    
    };


%% CREATE PLOTS

figure();
    
for i = 1:length(Experiments)

    ex = Experiments{i};

    load(ex.data);

    h(i) = subplot(length(Experiments), 1, i);
    plot(TrialTimesAllCharts/3600, CAP1HeightsAllCharts);

    ylabel([ex.title ' CAP1 Peak (\muV)']);
    if i == 1
        % Set figure title
        title(PlotTitle);
    end

end  % for Experiments

xlabel(h(end), 'Time (hr)');

% Hide x-ticks for all but last plot
set(h, 'box', 'off');
set(h(1:end-1),'xcolor','w');
set(h(1:end-1),'xtick',[]);

% Link time axes for panning and zooming
linkaxes(h, 'x');

% Save plot
set(gcf, 'Units', 'normalized', 'Position', [0,0,1,1]);
hgexport(gcf, FigureFileName, hgexport('factorystyle'), 'Format', 'png');
