function [bestSolidStateFit,rubberyStart] = endOfSSPoint(minFitLength,ssStartOfData)
%ENDOFSSPOINT Returns the max temperature, and "best" best fit line from
% ssStart of Data
%
%   Input:
%       -   ssStartOfData   Output of fitsStartOfData 
%           Format: Data struct with fields: length, rSqrd, polyFit.
%   Output: 
%       bestSolidStateFit    struct with fields:
%           -   length       Length of "Best" best fit which is also the
%                            max temp index before entering Tg
%
%           -   bestFitParam "Best" best fit parameters [P,s]
%
%       rubberyStart         index at which the rubbery state baseline 
%                            begins following the completion of the glass
%                            transition
%
%   Method: Analyzing change in r^2 values as a function of length of fit
%   multiple regions are observed. Fits typically start with high r^2
%   values before quickly dropping of as data is typically noisy. As fits
%   begin to become longer the r^2 will stabilize until the fit region
%   begins to include the glass transition. At this point there will begin
%   a secondary drop off. As the fits continue to grow passing fully
%   through the glass transition region the quality of fit will begin to
%   rise again as now a small sigmoidal like step around a linear
%   projection yields a relatively good linear fit (almost invariant).
%
%   An example of this curve is shown in:
%               ./Figures/Example Solid State rSqrd.png
%   
%       Here the blue curve is the rSqrd values for each fit plotted
%       against fit length. 
%       
%       The red oval highlights the stabilization
%       region. The max solid state fit temp is taken as the longest fit
%       whose r^2 value matches the mode of the red Oval region. 
%
%       The green line represents the recovery point following the glass
%       transition. This local minimum is taken as the start of the rubbery
%       state where you have fully recovered from the glass transition into
%       the rubbery or "liquid" state.
%   
%*************************************************************************%

% Start of function
% Finding the mode region can be a bit tricky depending on how long the
% solid state region is w.r.t. the length of the rubbery state region.
% Since the end point of the fits were determined based on the approximate
% location of the melt peak, if this region is significantly longer than
% the solid state region the mode may not fall in the red oval. To avoid
% this we start by finding the green line (or the recovery point). We then
% only consider the mode of r^2 values before this point, as this would
% only be in reference to the actual solid state region.
    funcMinLength = minFitLength;
    rs = vertcat(ssStartOfData.rSqrd); %an array of the r^2 values
    lens = vertcat(ssStartOfData.length); %an array of the lengths
    fitsCurve = [lens,rs];
    invFitsCurve = [lens,-1*rs]; %inverts curve local mins now peaks
    [~,locsSS] = findpeaks(invFitsCurve(:,2)); %index of the rubbery start temp
    rubberyStart = (locsSS(end,1));
    roundedRs = round(rs(1:rubberyStart,1),3); %rounds rs for simplicity
    modeRs = mode(roundedRs); %mode of the data from start to rubberyStart
    goodVals = [];
    x = 0;
    for i = 1:length(roundedRs)
        if roundedRs(i) >= modeRs
            x = x +1;
            goodVals(x,1) = lens(i);
            goodVals(x,2) = fitsCurve(i,2);
        end
    end
    bestSolidStateFit.length = goodVals(end,1);
    bestSolidStateFit.bestFitParam = ...
        ssStartOfData(goodVals(end,1)-funcMinLength).polyFit;
    bestSolidStateFit.baseline = ssStartOfData(goodVals(end,1)-funcMinLength).baseline;
end

