function [fictiveTemp,deltaCp] = fictiveTemp(data,eOSS,sORS,fullSS,fullRS)
%FICTIVETEMP Fictive temperature and heat capacity increment at Tf are
%determined using the Moynihan method of equal area.
%
%   Outputs
%               fictiveTemp         - Fictive Temperature
%               deltaCp             - Heat capacity increment at Tf
%
%*************************************************************************%
    relativeWidth = sORS-eOSS;
    halfRange = relativeWidth/2;
    lowTemp = eOSS-halfRange;
    highTemp = sORS+halfRange;
    [~,lowLimitPos] = min(abs(fullSS(:,1)-lowTemp));
    [~,highLimitPos] = min(abs(fullRS(:,1)-highTemp));
    [~,startPos] = min(abs(data(:,1)-lowTemp));
    [~,endPos] = min(abs(data(:,1)-highTemp));
    F = griddedInterpolant(data(startPos:endPos,1),data(startPos:endPos,2));
    S = griddedInterpolant(fullSS(lowLimitPos:end,1),fullSS(lowLimitPos:end,2));
    R = griddedInterpolant(fullRS(1:highLimitPos,1),fullRS(1:highLimitPos,2));
    funData = @(t) F(t);
    funSolid = @(t) S(t);
    funRub = @(t) R(t); %lol
    rightSide = integral(funData,data(startPos,1),data(endPos,1))...
        -integral(funSolid,data(startPos,1),data(endPos,1));
    rmsData = rms(data(:,2))/2;
    for x = data(endPos):-0.005:data(startPos,1)
        leftSide = integral(funRub,x,data(endPos,1))...
            -integral(funSolid,x,data(endPos,1));
        if leftSide == rightSide || abs(leftSide-rightSide)<=rmsData
            fictiveTemp = x;
            break
        end
    end
    deltaCp = funRub(x)-funSolid(x);
end

