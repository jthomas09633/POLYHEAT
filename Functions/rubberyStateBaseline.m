function fitsRubbery = rubberyStateBaseline(data,minFitLength,startPoint,sdPeaksInt)
%RUBBERYSTATEBASELINE fitting the rubbery/semi-solid from the end of the 
% glass transittion towards the first peak of the second derivative stopping
% at the position that is to a distance to the left of the first peak of 
% the second derivative that is the same distance as the separation
% distance between the peak of the first and second positive peaks of the
% second derivative
%
% output is a struct of fit with the following fields:
%
%           length      - Length of the fit in number of data points
%           short       - Short fit, the fit exactly the length of the
%                         temperature span that was used to produce the fit
%           Long        - Extrapolation of the short fit to project into
%                         the melt area
%           rSqrd       - rSqrd of the fit
%           polyFit     - the slope and intercept of the fit
%           slope       - just the slope
%           normR       - normalized r^2 values from 0-1 based on min-max
%                         of calculated r^2 values (lowest calculated r^2 
%                         is 0, highest is 1)
%           normLen     - normalized length (same logic)
%           normSlope   - normalized slope (same logic)
%
%*************************************************************************%
    funcData = data;
    funcMinLength = minFitLength;
    rubberyEnd = sdPeaksInt(1,2);
    offset = startPoint+funcMinLength;
    rb = [];
    parfor i = offset+1:rubberyEnd
        xData = funcData(startPoint:i,1);
        yData = funcData(startPoint:i,2);
        [P,s] = polyfit(xData,yData,1);
        normData = norm(yData-mean(yData));
        rSqrd = 1-(s.normr/normData)^2;
        rb(i-offset).length = length(xData);
        rb(i-offset).rSqrd = rSqrd;
        rb(i-offset).adjRsqrd = 1-(((1-rSqrd)*(length(xData)-1))/(length(xData)-2-1));
        rb(i-offset).P = P;
        rb(i-offset).i = i;
    end
    parfor j = 1:length(rb)
        xs = funcData(startPoint:rb(j).i,1);
        xsLong = linspace(funcData(startPoint,1),funcData(end,1),1000)';
        ys = polyval(rb(j).P,xs);
        ysLong = polyval(rb(j).P,xsLong);
        short = [xs,ys];
        long = [xsLong,ysLong];
        fitsRubbery(j).short = short;
        fitsRubbery(j).long = long;
        fitsRubbery(j).rSqrd = rb(j).rSqrd;
        fitsRubbery(j).adjRsqrd = rb(j).adjRsqrd;
        fitsRubbery(j).fitLength = length(short);
        fitsRubbery(j).slope = rb(j).P;
    end
    rsAlone = vertcat(fitsRubbery.rSqrd);
    maxrSqrd = max(rsAlone);
    minrSqrd = min(rsAlone);
    diffr = maxrSqrd-minrSqrd;

    adjRsAlone = vertcat(fitsRubbery.adjRsqrd);
    maxadjRSqrd = max(adjRsAlone);
    minadjRSqrd = min(adjRsAlone);
    diffadjRs = maxadjRSqrd-minadjRSqrd;

    lensAlone = vertcat(fitsRubbery.fitLength);
    maxLen = max(lensAlone);
    minLen = min(lensAlone);
    diffLen = maxLen-minLen;

    fitSlopes = vertcat(fitsRubbery.slope);
    maxSlope = max(fitSlopes);
    minSlope = min(fitSlopes);
    diffSlope = maxSlope-minSlope;

    parfor k = 1:length(fitsRubbery)
        fitsRubbery(k).normR = 1-((maxrSqrd)-fitsRubbery(k).rSqrd)/(diffr);
        fitsRubbery(k).normadjR = 1-((maxadjRSqrd)-fitsRubbery(k).adjRsqrd)/(diffadjRs);
        fitsRubbery(k).normLen = 1-((maxLen)-fitsRubbery(k).fitLength)/(diffLen);
        fitsRubbery(k).normSlope = 1-((maxSlope)-fitsRubbery(k).slope)/(diffSlope);
    end
end

