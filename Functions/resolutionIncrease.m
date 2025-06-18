function [dataOut,minFitLength] = resolutionIncrease(data)
%RESOLUTIONINCREASE Summary of this function goes here
%   Detailed explanation goes here
    targetStepSize = 0.1;
    tempCol = 1;
    powerCol = 2;

    diffs = diff(data(:,tempCol));
    isMonotonic = all(diffs > 0) || all(diffs < 0);

    if isMonotonic
        % Data is monotonic, checking if he resolutoin is correct
        maxStep = max(abs(diffs));
        if maxStep <= targetStepSize
            fprintf('Data is unique, monotonic, and has sufficient resolution.\n');
            dataOut = data;
            minFitLength = ceil(1/mean(abs(diffs)));
            return;
        end
    end
    fprintf('Data requires processing for stair-steps or large gaps...\n');

    % --- Handling Stair-Steps ---
    [unique_x,~,group_indices] = unique(data(:,tempCol));
    mean_y = accumarray(group_indices, data(:,powerCol),[],@mean);
    cleanData = [unique_x,mean_y];
    
    % check if the original data was descending to restor order later
    wasDescending = data(1,tempCol) > data(end,tempCol);

    gaps = diff(cleanData(:,1));
    points_to_add = floor(abs(gaps(abs(gaps) > targetStepSize))/targetStepSize);
    final_size = size(cleanData,1)+sum(points_to_add);
    dataOut = zeros(final_size,2);

    currentIndex = 1;
    dataOunt(currentIndex,:) = cleanData(1,:);

    for i = 1:size(cleanData,1)-1
        p1 = cleanData(i,:);
        p2 = cleanData(i+1,:);
        gap = p2(1)-p1(1);
        if abs(gap) > targetStepSize
            % This segment has a large gap, so we interpolate inside it
            % Creating interpolated points, exckuding p1 but including p2
            % Sign(gap) ensures this works for both increasing and
            % decreasing data
            interp_x = (p1(1) + sign(gap)*targetStepSize:sign(gap)*targetStepSize:p2(1))';

            interp_y = interp1([p1(1); p2(1)],[p1(2); p2(2)],interp_x);

            num_interp_points = length(interp_x);
            dataOut(currentIndex+1:currentIndex+num_interp_points,:) = [interp_x,interp_y];
            currentIndex = currentIndex + num_interp_points;
            
        else
            currentIndex = currentIndex+1;
            dataOunt(currentIndex,:) = p2;
        end
    end
    dataOut = dataOut(1:currentIndex,:);
    
    if wasDescending
        dataOut = flip(dataOut,1);
    end
    minFitLength = ceil(1/targetStepSize);
    fprintf('Processing complete. New Data ponts: %d\n',length(dataOut));
end