function PlotEpisodicVoltageMesh( ...
    Voltages, ...               % m-by-n matrix of voltages, in uV
    SampleTimes, ...            % n sample times for x-axis, in ms
    TrialTimes, ...             % m trial times for y-axis, in sec
    TrialSkippingFactor, ...    % y indices downsampling factor
    SampleTimeRangeForMesh, ... % x-axis range, in ms
    TrialTimeRangeForMesh, ...  % y-axis range, in sec
    VoltageRangeForMesh, ...    % z-axis range, in uV
    ColorRangeForMesh, ...      % color range, in uV
    DesiredTrialTimeUnits, ...  % y-axis units ("sec", "min", or "hr")
    TimeMarkers, ...            % y-axis marker locations, in sec
    TimeMarkersType, ...        % y-axis marker type ("none", "lines", or "planes")
    TracesToHighlight, ...      % y indices to highlight
    ViewAngle, ...              % plot view angle, in degrees
    PlotTitle ...               % plot title
    )
%PlotEpisodicVoltageMesh Plot a 2D mesh of episodic voltage data.
%   PlotEpisodicVoltageMesh(...) (see source for arguments) plots a mesh,
%   where each row is an episode and each column is a voltage sample.
%   Individual episodes can be highlighted, and markers (lines or planes)
%   can be set to mark specified trial times (e.g., place grid lines every
%   X time units).


%% FIND SUBSET OF DATA TO PLOT

% select sample and trial indices within the x- and y-axes ranges
SampleIndicesForMesh = find(SampleTimeRangeForMesh(1) <= SampleTimes & SampleTimes <= SampleTimeRangeForMesh(2));
TrialIndicesForMesh = find(TrialTimeRangeForMesh(1) <= TrialTimes & TrialTimes <= TrialTimeRangeForMesh(2));

% downsample trials to reduce computational load
TrialIndicesForMesh = TrialIndicesForMesh(1:TrialSkippingFactor:end);

% select sample and trial times within the x- and y-axes ranges
TrialTimesForMesh = TrialTimes(TrialIndicesForMesh);
SampleTimesForMesh = SampleTimes(SampleIndicesForMesh);

% select voltages within the x- and y-axes ranges
VoltagesForMesh = Voltages(TrialIndicesForMesh, SampleIndicesForMesh);


%% CONVERT Y-AXIS UNITS

% depending on the desired y-axis units for the plot, determine a
% time conversion factor
switch DesiredTrialTimeUnits
    case 'sec'
        % units are already in sec
        TrialTimeConversionFactor = 1;
    case 'min'
        TrialTimeConversionFactor = 60;
    case 'hr'
        TrialTimeConversionFactor = 3600;
    otherwise
        error('Unknown DesiredTrialTimeUnits ''%s''!', DesiredTrialTimeUnits);
end

% convert all y-coords to desired units
TrialTimes = TrialTimes / TrialTimeConversionFactor;
TrialTimesForMesh = TrialTimesForMesh / TrialTimeConversionFactor;
TrialTimeRangeForMesh = TrialTimeRangeForMesh / TrialTimeConversionFactor;
TimeMarkers = TimeMarkers / TrialTimeConversionFactor;


%% START THE FIGURE

hold on;


%% PLOT MESH

mesh(SampleTimesForMesh, TrialTimesForMesh, VoltagesForMesh);


%% PLOT Y-AXIS MARKERS

for t = TimeMarkers
    switch TimeMarkersType
        case 'none'
            break
        case 'lines'
            x = SampleTimeRangeForMesh;
            y = [t t];
            z = [0 0];
            plot3(x,y,z,...
                'color','w',...
                'linewidth',1);
        case 'planes'
            x = [SampleTimeRangeForMesh flip(SampleTimeRangeForMesh)];
            y = [t t t t];
            z = [-20 -20 0.5 0.5];
            patch(x,y,z,...
                'white',...
                'FaceAlpha',0.5,...
                'EdgeColor','w',...
                'LineStyle','-');
        otherwise
            error('Unknown TimeMarkersType ''%s''!', TimeMarkersType);
    end
end


%% HIGHLIGHT TRACES

if ViewAngle ~= 90
    for i = sort(TracesToHighlight)
        
        t = TrialTimes(i);

        % shift the traces slightly so they are not obscured by the contour plot
        if i == 1
            % the first trace is moved in the -y direction
            y_offset = -0.002 * range(TrialTimeRangeForMesh); % in DesiredTrialTimeUnits
            z_offset = 0; % in uV

            % expand the y plot range to include the first trace
            TrialTimeRangeForMesh(1) = min(TrialTimeRangeForMesh(1), t + y_offset);
        else
            % other traces are moved in the +z direction
            y_offset = 0; % in DesiredTrialTimeUnits
            z_offset = 2; % in uV

%             % other traces are moved towards the camera in the -y and +z directions
%             z_offset = 5; % in uV
%             z_plot_range = range(VoltageRangeForMesh);
%             y_plot_range = range(TrialTimeRangeForMesh);
%             y_offset = - (z_offset / tan(deg2rad(ViewAngle))) * (y_plot_range / z_plot_range);
        end

        % plot the highlighted trace
        plot3(...
            SampleTimesForMesh, ...
            t * ones(size(SampleTimesForMesh)) + y_offset, ...
            Voltages(i,SampleIndicesForMesh) + z_offset, ...
            'color','w', ...
            'linewidth',3 ...
            );
    end
end


%% CUSTOMIZE FIGURE

% set the camera elevation
view(0,ViewAngle);

% set the x,y,z plot ranges
axis([ ...
    SampleTimeRangeForMesh ...
    TrialTimeRangeForMesh ...
    VoltageRangeForMesh ...
    ]);

% set the color scheme
colormap jet;

% set the voltage range that maps to the full color spectrum
caxis(ColorRangeForMesh);

% give the figure a title
title(PlotTitle);

% create and label the color scale
hcb = colorbar;
hcb.Label.String = 'Voltage (\muV)';

% label the sample time axis
xlabel('Time (ms)');

if ViewAngle == 90
    % label the trial time axis
    ylabel(['Experiment time (' DesiredTrialTimeUnits ')']);
else
    % hide the trial time axis ticks
    set(gca, 'ytick', []); set(gca, 'ycolor', 'w');
end

% hide the voltage axis ticks
set(gca, 'ztick', []); set(gca, 'zcolor', 'w');

% set the background behind the mesh to gray
set(gca, 'color', [0.9 0.9 0.9]);

% set the space around the plot to white
set(gcf, 'color', 'w');


end
