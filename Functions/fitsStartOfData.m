function ssStartOfData = fitsStartOfData(data,minFitLength,sdPeakInt)
%FITSSTARTOFDATA
%   Fits the heat capacity data starting from the first data point to a
%   point in the rubbery state baseline (2-phase, Tg/Tm, model)
%
%   The point in the rubbery state that is taken as the last point to fit
%   to is defined by from the peaks of the second derivative of the melt
%   region
%
%   Inputs: (All Required)
%       -   data            Heat capacity data in ascending temperature order 
%       -   sdPeakInt       Sec. Derv. Peaks that correspond to the melt peak
%       -   minFitLength    Minimum length of fit (ideally 1degC min length)
%
%   The max fit length will be from the first data point to the endPoint
%   defined as:
%   endPoint = posFirstSecDervPeak - (posSecondSecDerv - posFirstSecDervPeak)
%   
%   The shortest fit will be from the first data point to 1C after the
%   first data point. 
%
%   Fits grow in length by one data point ex:
%       -   First   Fit Length 10 data points
%       -   Second  Fit Length same initial 10 data points, plus the next 1
%       -   Third   Fit Length same initial 10 data points, plus the next 2
%
%   Each fit will be recorded in the output struct, ssStartOfData,
%   (solid state fit from the start of the data) with the following fields:
%   
%       -   length  The number of data points in the fit
%       -   rSrqd   The r^2 of the first order polynomial fit
%       -   polyFit [P,s] the polynomial coefficients P and the struct s
%                   for use in POLYVAL for the error estimates
%
%
%   
%% Start of Fitting
    % endPoint is the simply a point in the rubbery state that is defined
    % as the position left of the first peak in the second derivative of
    % the melt peak, from here we shift left (to lower temperatures) by the
    % distance between the two peaks of the second derivative (in a
    % guassian distribution this would be closely related to the FWHM) as this
    % is sufficiently deep enough in the rubbery state to find the points
    % of interest.

    funcData = data;
    funcMinLength = minFitLength;
    endPoint = sdPeakInt(1,2) - (sdPeakInt(end,2)-sdPeakInt(1,2));
    ssStartOfData = []; % initialization of the output struct
    parfor i = funcMinLength+1:endPoint
        xData = funcData(1:i,1); %temperature
        yData = funcData(1:i,2); %heat capacity
        [P,s] = polyfit(xData,yData,1) %linear fit
        ys = polyval(P,xData);
        normData = norm(yData-mean(yData));
        rSqrd = 1-(s.normr/normData)^2;
        ssStartOfData(i-funcMinLength).length = length(xData);
        ssStartOfData(i-funcMinLength).rSqrd = rSqrd;
        ssStartOfData(i-funcMinLength).polyFit = P;
        ssStartOfData(i-funcMinLength).baseline = [xData,ys];
    end
end

