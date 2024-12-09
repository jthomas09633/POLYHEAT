function [dataOut,minFitLength] = resolutionIncrease(data)
%RESOLUTIONINCREASE Summary of this function goes here
%   Detailed explanation goes here
    for i = 2:length(data)
        diff(i-1) = data(i,1)-data(i-1,1);
    end
    step = mean(diff);
    if step <= 0.1 && step > 0
        dataOut = data;
        minFitLength = ceil(1/step);
    elseif step < 0
        funcData = flip(data,1);
        startPoint = funcData(1,1);
        endPoint = funcData(end,1);
        tempRange = endPoint-startPoint;
        stepSize = 0.1; %minimum of 0.1C change in temp
        lenData = ceil(tempRange/stepSize); %rounds up the number of data point to ensure 0.1
        xData = linspace(startPoint,endPoint,lenData)';
        i = 1;
        while i <= size(funcData,1)
            try 
                f = griddedInterpolant(funcData(i:end,1),funcData(i:end,2));
                break
            catch
                i = i+1;
            end
        end
        len = length(funcData);
        % checks for uniqueness will remove final data points until unique
        if ~exist('f','var')
            while i >=1
                try
                    f = griddedInterpolant(funcData(1:len,1),funcData(1:len,2));
                    break
                catch
                    len = len-1;
                end
            end
        end
        
        F = @(t) f(t);
        yData = zeros(length(xData),1);

        for i = 1:length(xData)
            yData(i,1) = F(xData(i));
        end
        dOut = [xData,yData];
        dataOut = flip(dOut,1);
        minFitLength = ceil(1/stepSize);
    else
        funcData = data;
        startPoint = funcData(1,1);
        endPoint = funcData(end,1);
        tempRange = endPoint-startPoint;
        stepSize = 0.1; %minimum of 0.1C change in temp
        lenData = ceil(tempRange/stepSize); %rounds up the number of data point to ensure 0.1
        xData = linspace(startPoint,endPoint,lenData)';
        i = 1;
        while i <= size(funcData,1)
            try 
                f = griddedInterpolant(funcData(i:end,1),funcData(i:end,2));
                break
            catch
                i = i+1;
            end
        end
        len = length(funcData);
        % checks for uniqueness will remove final data points until unique
        if ~exist('f','var')
            while i >=1
                try
                    f = griddedInterpolant(funcData(1:len,1),funcData(1:len,2));
                    break
                catch
                    len = len-1;
                end
            end
        end
        
        F = @(t) f(t);
        yData = zeros(length(xData),1);

        for i = 1:length(xData)
            yData(i,1) = F(xData(i));
        end
        dataOut = [xData,yData];
        minFitLength = ceil(1/stepSize);
    end
    
end