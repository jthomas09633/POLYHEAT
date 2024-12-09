function [meltPeak,firstDer,secDer] = prep2PhaseData(data)
%PREPDATA Summary of this function goes here
%   Detailed explanation goes here
%   Testing this
   
    [peakMax,peakIndex] = max(data(:,2));
    fd = gradient(data(:,2))./gradient(data(:,1));
    sgFd = sgolayfilt(fd,1,21);
    firstDer = [data(:,1),sgFd(:,1)];
    
    sd = gradient(firstDer(:,2))./gradient(firstDer(:,1));
    sgSd = sgolayfilt(sd,1,71);
    secDer = [data(:,1),sgSd(:,1)];
    meltPeak.peakMax = peakMax;
    meltPeak.peakPos = peakIndex;
end

