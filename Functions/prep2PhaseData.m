function [meltPeak,firstDer,secDer] = prep2PhaseData(data)
%PREPDATA finds the melt peak position, and returns the first and second
%derivative of heat capacity with respect to temperature. Each derivative
%is filtered using a savitzky golay filter to reduce noise
   
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

