function [dataPeaksInt,fdPeaksInt,sdPeaksInt] = peakFinder(data,firstDer,secDer)
%PEAKFINDER returns the peak postions and normalizes intensities for melt
%   peak of the original, first derivative, and second derivative. 
%
%       Inputs:
%           - data      2 dimensional array of [temp, heat capacity]
%           - firstDer  2 dimensional array of [temp,d(c_p)/d(T)] 
%           - secDer    2 dimensional array of [temp,dd(d_p)/d(T)]
%
%   A cutoff for each normalized peak will be used to avoid noise. Peak
%   signals will be kept if greater than 0.5
%   Start of Analysis
%************************************************************************%
    [dPeaks,dLocs] = findpeaks(data(:,2)/max(data(:,2)));
    [fdPeaks,fdLocs] = findpeaks(firstDer(:,2)/max(firstDer(:,2)));
    [sdPeaks,sdLocs] = findpeaks(secDer(:,2)/max(secDer(:,2)));
    
    x = 0;
    y = 0;
    z = 0;
    
    dataPeaksInt = [];
    for i = 1:length(dPeaks)
        if dPeaks(i) >= 0.3
            x = x+1;
            dataPeaksInt(x,1) = dPeaks(i);
            dataPeaksInt(x,2) = dLocs(i);
        end
    end
    
    fdPeaksInt = [];
    for j = 1:length(fdPeaks)
        if fdPeaks(j) >= 0.3
            y = y+1;
            fdPeaksInt(y,1) = fdPeaks(j);
            fdPeaksInt(y,2) = fdLocs(j);
        end
    end


    sdPeaksInt = [];
    for k = 1:length(sdPeaks)
        if sdPeaks(k) >= 0.2
            z = z+1;
            sdPeaksInt(z,1) = sdPeaks(k);
            sdPeaksInt(z,2) = sdLocs(k);
        end
    end
end

