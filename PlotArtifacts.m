close all;
clear;


%% GLOBAL SETTINGS

dir_exports = 'figures';
if ~exist(dir_exports, 'dir')
    mkdir(dir_exports)
end


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

for i = 1:length(Experiments)
    
    ex = Experiments{i};
    
    load(ex.data);
    
    PlotTitle = [
        ex.title, ' - ' ...
        'Artifact Sizes' ...
        ];
    
    FigureFileName = [
        dir_exports '/' ...
        ex.id, ' - ' ...
        'Artifacts' ...
        '.png' ...
        ];

    figure();
    
    for i = 1 : ArtifactNPeaks
        
        h(i) = subplot(ArtifactNPeaks, 1, i);
        plot(TrialTimesAllCharts/3600, ArtifactHeightAllCharts(:, i));
        
        if i == 1
            ylabel('Largest artifact osc. height (\muV)');
            
            % Set figure title
            title(PlotTitle);
        else
            ylabel([num2str(i) '-th largest artifact osc. height (\muV)']);
        end
        
    end
    
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

end  % for Experiments
