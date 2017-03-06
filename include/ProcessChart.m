function result = ProcessChart(filename, channel_to_process, channel_with_stim_trigger)
%ProcessChart Read an AxoGraph chart and extract episodic data from it.
%   result = ProcessChart(f, c, cstim) reads in AxoGraph file f and
%   analyzes channel c, using events on channel cstim as triggers for
%   compound action potential (CAP) extraction.

result.filename = filename;
result.channel_to_process = channel_to_process;
result.channel_with_stim_trigger = channel_with_stim_trigger;

result.channel_time = 'Time (s)';
result.stim_freq = 2; % in Hz
result.stim_threshold = 500; % voltage threshold in uV for detecting stim on channel_with_stim_trigger

result.CAPlength = 800; % the length in number of samples of the extracted CAP, 800 samples @ 5 kHz = 160 ms
result.Bias = 0; % an offset in number of samples for starting CAP extraction relative to detected stim trigger
% result.Bias = -150; % an offset in number of samples for starting CAP extraction relative to detected stim trigger

result.artifact_length = 125; % the length in number of samples of the artifact, 125 samples @ 5 kHz = 25 ms
result.n_artifact_peaks = 2; % the artifact is composed of multiple oscillations of varying height, and only the n tallest will be analyzed


%% LOAD INPUT FILE

[chart_data, chart_header] = importaxographx(filename);

index_time                      = find(strcmp({chart_header.YCol.title}, result.channel_time) == 1);
index_channel_to_process        = find(strcmp({chart_header.YCol.title}, result.channel_to_process) == 1);
index_channel_with_stim_trigger = find(strcmp({chart_header.YCol.title}, result.channel_with_stim_trigger) == 1);

assert(any(index_time),                      'No channel found with title ''%s'' in %s', result.channel_time,              filename);
assert(any(index_channel_to_process),        'No channel found with title ''%s'' in %s', result.channel_to_process,        filename);
assert(any(index_channel_with_stim_trigger), 'No channel found with title ''%s'' in %s', result.channel_with_stim_trigger, filename);


%% EXTRACT BASIC TIMING PARAMETERS

result.duration = range(chart_data(:,index_time)); % in sec
result.sample_freq = 1/mean(diff(chart_data(:,index_time))); % in Hz
result.sample_times = (result.Bias : result.CAPlength+result.Bias-1) / result.sample_freq * 1000; % in ms
fprintf('\tchart duration = %g sec = %g min\n', result.duration, result.duration/60);
fprintf('\tsample freq    = %g Hz\n', result.sample_freq);


%% DETERMINE STIMULI TIMING

fprintf('finding stimulus timing ...\n');
result.samples_between_stims = result.sample_freq/result.stim_freq; % expected number of samples between each stim
result.stim_index = FindEpisodes( ...
    chart_data(:,index_channel_with_stim_trigger), ...
    result.stim_threshold * 1e-6, ... % convert from uV to V
    result.samples_between_stims * 0.95 ... % slightly less than expected separation to allow for variability in stim timing
    );
result.stim_times = chart_data(result.stim_index + result.Bias, index_time);
result.n_trials = length(result.stim_index);
fprintf('\tnum trials          = %d\n', result.n_trials);
fprintf('\texpected trial freq = %g Hz\n', result.stim_freq);
fprintf('\tactual trial freq   = %g Hz\n', 1/mean(diff(result.stim_times)));


%% EXTRACT COMPOUND ACTION POTENTIALS

fprintf('extracting CAPs ...\n');
result.CAPsignal = zeros(result.n_trials, result.CAPlength);
for j = 1 : result.n_trials
    
    result.CAPsignal(j,1:result.CAPlength) = chart_data( ...
        result.stim_index(j)+result.Bias : result.stim_index(j)+result.Bias+result.CAPlength-1, ...
        index_channel_to_process) * 1e6; % convert from V to uV
    
    if mod(j, 1024) == 0
        fprintf('\t%.f%% complete (%d/%d)\n', 100*j/result.n_trials, j, result.n_trials);
    end
end


%% PARAMETER SCANS

fprintf('processing trials ...\n');
tic_JPG = tic;
ParaScan_JPG = zeros(result.n_trials, result.CAPlength-1);
ParaScan2_JPG = zeros(result.n_trials, result.CAPlength-1);
for j = 1 : result.n_trials
    
    temp = cumsum(flip(abs(result.CAPsignal(j,1:result.CAPlength))));
    ParaScan_JPG(j,:)  = flip(temp(2:end)); %JPG  THIS SUMMING IS DONE WITHOUT RESPECT TO THE SAMPLE FREQUENCY, SO THE UNITS ARE uV, NOT uV*s
    ParaScan2_JPG(j,:) = flip(temp(2:end)./(1:result.CAPlength-1)); %JPG  THIS IS THE AVERAGE VOLTAGE BETWEEN THE CURRENT SAMPLE AND THE END OF THE CAP, NOT THE LOCAL AVERAGE (SMOOTHED VOLTAGE)

    if mod(j, 1024) == 0
        fprintf('\t%.f%% complete (%d/%d)\n', 100*j/result.n_trials, j, result.n_trials);
    end
end
toc_JPG = toc(tic_JPG);


% % Check that my implementation of the parameter scans matches Junqi's original implementation
% fprintf('validating JPG implementation ...\n');
% tic_JXZ = tic;
% % ParaScan_JXZ = zeros(result.n_trials, result.CAPlength-1);  % JPG  UNCOMMENT TO IMPROVE SPEED
% % ParaScan2_JXZ = zeros(result.n_trials, result.CAPlength-1); % JPG  UNCOMMENT TO IMPROVE SPEED
% for j = 1 : result.n_trials
%     % do the parameter scan of each trace
%     for k = 1:result.CAPlength-1
%         % this is to calculate the parameter with one end fixed and the
%         % other moving from the end to the artifact
%         ParaScan_JXZ(j,k) = sum(abs(result.CAPsignal(j,result.CAPlength-k:result.CAPlength))); %JPG  THIS SUMMING IS DONE WITHOUT RESPECT TO THE SAMPLE FREQUENCY, SO THE UNITS ARE uV, NOT uV*s
%         ParaScan2_JXZ(j,k) = ParaScan_JXZ(j,k)/k; %JPG  THIS IS THE AVERAGE VOLTAGE BETWEEN THE CURRENT SAMPLE AND THE END OF THE CAP, NOT THE LOCAL AVERAGE (SMOOTHED VOLTAGE)
%     end
%     % flip the result to make the index matching the CAP
%     ParaScan_JXZ(j,:) = flip(ParaScan_JXZ(j,:));
%     ParaScan2_JXZ(j,:) = flip(ParaScan2_JXZ(j,:));
%     
%     if mod(j, 1024) == 0
%         fprintf('\t%.f%% complete (%d/%d)\n', 100*j/result.n_trials, j, result.n_trials);
%     end
% end
% toc_JXZ = toc(tic_JXZ);
% assert(max(abs((ParaScan_JPG(:)  - ParaScan_JXZ(:))  ./ ParaScan_JXZ(:)))  < 1e-14, 'ParaScan_JPG is incorrect!')
% assert(max(abs((ParaScan2_JPG(:) - ParaScan2_JXZ(:)) ./ ParaScan2_JXZ(:))) < 1e-14, 'ParaScan2_JPG is incorrect!')
% fprintf('it is accurate and %.1f times faster!\n', toc_JXZ/toc_JPG);


% Save the parameter scans
result.ParaScan = ParaScan_JPG;
result.ParaScan2 = ParaScan2_JPG;


%% MEASURE ARTIFACT

fprintf('measuring artifacts ...\n');
result.artifact_heights     = zeros(result.n_trials, result.n_artifact_peaks);
result.artifact_times       = zeros(result.n_trials, result.n_artifact_peaks);
result.artifact_widths      = zeros(result.n_trials, result.n_artifact_peaks);
result.artifact_prominences = zeros(result.n_trials, result.n_artifact_peaks);
for j = 1 : result.n_trials
    % locate and measure properties of the n largest peaks in each trial
    [pks,locs,w,p] = findpeaks( ...
        result.CAPsignal(j,1:result.artifact_length), ...
        result.sample_times(1:result.artifact_length), ...
        'npeaks', result.n_artifact_peaks, ...
        'sortstr', 'descend' ...
        );
    result.artifact_times(j,:)       = locs; % in ms relative to trial start
    result.artifact_heights(j,:)     = pks;  % in uV relative to 0 (actual voltage)
    result.artifact_prominences(j,:) = p;    % in uV relative to nearby peaks (see findpeaks docs)
    result.artifact_widths(j,:)      = w;    % in ms at half prominence (see findpeaks docs)
    
    if mod(j, 1024) == 0
        fprintf('\t%.f%% complete (%d/%d)\n', 100*j/result.n_trials, j, result.n_trials);
    end
end


end


%%

function indices = FindEpisodes(voltages, threshold, min_spacing)
%description...

    [~, indices] = findpeaks( ...
        voltages, ...
        'minpeakheight', threshold, ...
        'minpeakdistance', min_spacing ...
        );

end

% function indices = FindEpisodes(voltages, threshold, ~)
% %description...
% 
%     [heights, indices] = findpeaks( ...
%         voltages, ...
%         'minpeakheight', threshold ...
%         );
%     
%     % use only trials with small artifacts
%     filtered = 300 * 1e-6 < heights & heights < 740 * 1e-6;
%     indices = indices(filtered);
%     
%     % shift indices to the largest peak of the CAP
%     for i = 1:length(indices)
%         [~, ap1] = findpeaks(voltages(indices(i):indices(i)+800), 'sortstr', 'descend', 'npeaks', 1);
%         indices(i) = ap1 + indices(i) - 1;
%     end
% 
% end