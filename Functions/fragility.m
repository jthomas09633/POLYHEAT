function [fittedCurve,gof,m] = fragility(coolingRates,fictiveTemps)
%FRAGILITY Summary of this function goes here
%   Log of the prior cooling rates
%   fictive temperatures
    tfs = fictiveTemps+273.15;
    betaRef = log10(coolingRates(end));
    tfRef = tfs(end);
    
    xs = log10(coolingRates);
    ys = tfs;
    
    startP = [5 100];
    fitFragility = fittype(@(c1,c2,x) ((x-betaRef)*(tfRef-c2)-(tfRef*c1))./((x-betaRef)-c1));
    [fittedCurve,gof] = fit(xs,ys,fitFragility,'StartPoint',startP,'Lower',1,'Upper',200);
    c1 = fittedCurve.c1;
    c2 = fittedCurve.c2;
    m = (c1/c2)*tfRef;
end

