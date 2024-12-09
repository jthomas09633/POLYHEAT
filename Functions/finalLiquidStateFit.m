function lsEndOfData = finalLiquidStateFit(data,minFitLength,sdPeaksInt)
%FINALLIQUIDSTATEFIT fitting the liquid state begins from the end of the
%data growing in length towards the melt peak. Longest fit performed will
%be from the end of the heating segment to the second peak of the second
%derivative (in heat capacity space, this would be the peak on the right
%hand side of the melt peak).
%
% output is a struct of fit with the following fields:
%
%           Length      - Length of the fit in number of data points
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
%           normLength  - normalized length (same logic)
%           normSlope   - normalized slope (same logic)
%
%*************************************************************************%
    funcData = data;
    funcMinLength = minFitLength;
    lsEndOfData = [];
    startPoint = sdPeaksInt(2,2);
    xsLong = funcData(startPoint:end,1);
    parfor i = startPoint+1:length(funcData)-funcMinLength
        xData = funcData(i:end,1);
        yData = funcData(i:end,2);
        [P,s] = polyfit(xData,yData,1);
        yVals = polyval(P,xData);
        yValsLong = polyval(P,xsLong);
        normData = norm(yData-mean(yData));
        rSqrd = 1-(s.normr/normData)^2;
        lsEndOfData(i-startPoint).Length = length(xData);
        lsEndOfData(i-startPoint).short = [xData,yVals];
        lsEndOfData(i-startPoint).Long = [xsLong,yValsLong];
        lsEndOfData(i-startPoint).rSqrd = rSqrd;
        lsEndOfData(i-startPoint).polyFit = P;
        lsEndOfData(i-startPoint).slope = P(1,1);
    end
    rs = vertcat(lsEndOfData.rSqrd);
    lens = vertcat(lsEndOfData.Length);
    slopes = vertcat(lsEndOfData.slope);
    maxRs = max(rs);
    minRs = min(rs);
    diffRs = maxRs-minRs;
    maxLens = max(lens);
    minLens = min(lens);
    diffLs = maxLens-minLens;
    maxSlope = max(slopes);
    minSlope = min(slopes);
    diffSlopes = maxSlope-minSlope;
    


    parfor j = 1:length(lsEndOfData)
        lsEndOfData(j).normR = 1-((maxRs)-lsEndOfData(j).rSqrd)/diffRs;
        lsEndOfData(j).normLength = 1-((maxLens)-lsEndOfData(j).Length)/diffLs;
        lsEndOfData(j).normSlope = 1-((maxSlope)-lsEndOfData(j).slope)/diffSlopes;
    end

end

