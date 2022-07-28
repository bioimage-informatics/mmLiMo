function estimate_laser_lines(parameter, folder)

for e = 1:length(parameter.emission_list)
    emission = parameter.emission_list{e};
    switch emission
        case 'left-3'
            pos = 1:parameter.s;
        case 'right-3'
            pos = parameter.s+1:parameter.s*2;
        case 'left0'
            pos = parameter.s*2+1:parameter.s*3;
        case 'right0'
            pos = parameter.s*3+1:parameter.s*4;
        case 'left+3'
            pos = parameter.s*4+1:parameter.s*5;
        case 'right+3'
            pos = parameter.s*5+1:parameter.s*6;
        case 'beads'
            pos = 1:parameter.s;
    end
    
    % Load
    filename = [folder.img, '\', emission];
    img = load(filename);
    img = img.stack;
    tilt_img = zeros([parameter.r, parameter.c, length(pos), length(parameter.zList)]);
    line_img = zeros([parameter.r, 1, length(pos), length(parameter.zList)]);
    parfor z = parameter.zList
    % for z = zList % if parfor is not available
        theImg = img(:,:,:,z+1);
        % Rotate
        if isequal(emission, 'left-3') || isequal(emission, 'right-3')
            theImg = arrayfun(@(x) imrotate(theImg(:,:,x), -3, 'crop'), 1:parameter.s, 'UniformOutput', false);
            theImg = cat(3, theImg{:});
        elseif isequal(emission, 'left+3') || isequal(emission, 'right+3')
            theImg = arrayfun(@(x) imrotate(theImg(:,:,x), 3, 'crop'), 1:parameter.s, 'UniformOutput', false);
            theImg = cat(3, theImg{:});
        end
        tilt_img(:,:,:,z+1) = theImg;
        % Detect lines
        mean_img = mean(theImg, 3);
        % Normalization
        theline = arrayfun(@(x) theImg(:,:,x) ./ mean_img, 1:size(theImg, 3), 'UniformOutput', false);
        % Horizontal average
        theline = cellfun(@(x) nanmean(x, 2), theline, 'UniformOutput', false);
        theline = cat(3, theline{:});
        line_img(:,:,:,z+1) = theline;
    end

    % Summation in the axial direction
    line_img_sum = sum(line_img, 4);
    visualize4Dsc(line_img_sum);
    % Peak
    peaks = arrayfun(@(x) line_img_sum(:,:,x) > mean(line_img_sum(:,:,x)) + 2*std(line_img_sum(:,:,x)), ...
        1:size(line_img_sum, 3), 'UniformOutput', false);
    [~, peaks] = arrayfun(@(x) findpeaks(peaks{x}.*line_img_sum(:,:,x), 'MinPeakDistance', 10), 1:length(peaks), ...
        'UniformOutput', false);
    % Interval as the median of inter-peaks
    interval = cellfun(@(x) x(2:end)-x(1:end-1), peaks, 'UniformOutput', false);
    interval = round(median(sort(cat(1, interval{:}))));
    % Offset
    rough_offset = cellfun(@(x) round(median(rem(x, interval))), peaks);

    % fitting
    [~, min_ind] = min(rough_offset);
    rough_offset1 = rough_offset(1:min_ind);
    fit1 = polyfit(1:length(rough_offset1), rough_offset1, 1);
    step = round(fit1(1));
    initial_offset = round(fit1(2)+fit1(1));
    
    % parameter
    parameter.interval = interval;
    parameter.step = step;
    parameter.initial_offset = initial_offset;

    % save
    mkdir(folder.tilt_img);
    filename = [folder.tilt_img, '\', emission];
    parsaveStack(filename, tilt_img);
    
    mkdir(folder.param);
    filename = [folder.param, '\', emission];
    parsaveStack(filename, parameter);
end

% step, initial_offset are common for the angles
intervals = zeros(length(parameter.emission_list),1);
steps = zeros(length(parameter.emission_list),1);
initial_offsets = zeros(length(parameter.emission_list),1);
for e = 1:length(parameter.emission_list)
    emission = parameter.emission_list{e};
    filename = [folder.param, '\', emission];
    parameter = load(filename);
    parameter = parameter.stack;
    intervals(e) = parameter.interval;
    steps(e) = parameter.step;
    initial_offsets(e) = parameter.initial_offset;
end
common_parameter.step = round(mean(steps));
common_parameter.interval = round(mean(intervals));
filename = [folder.param, '\common'];
parsaveStack(filename, common_parameter);

