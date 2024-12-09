function startTemp = startUpHookEstimator(rate)
%startUpHookEstimator takes in the rate in K/s and applies uses the
%following linear fit for the startup length
    xVals = [30,4000];
    yVals = [5;60];
    P = polyfit(xVals,yVals,1);
    xVals = linspace(30,4000,100)';
    yVals = polyval(P,xVals);
    startUpHookEstimator = [xVals,yVals];
    s = griddedInterpolant(startUpHookEstimator(:,1),startUpHookEstimator(:,2));
    sUHE = @(t) s(t); %startUpHookEstimator
    startTemp = sUHE(rate);

end