function fullMeltFits = peakFitFromRubberyToLiquid(data,rsTrimmed,lsTrimmed,sdPeaksInt)
%PEAKFITFROMBOTHEND Summary of this function goes here
%   Detailed explanation goes here  
    funcData = data; 
    [~,peakIndex] = max(funcData(:,2));
    critVal = funcData(peakIndex,1);
    width = -(funcData(sdPeaksInt(2,2),1)-funcData(sdPeaksInt(1,2),1))/2;
    loopLength = length(rsTrimmed);
    fullMeltFits = [];
    f = griddedInterpolant(funcData(:,1),funcData(:,2));
    F = @(t) f(t);
    parfor i = 1:loopLength
        fprintf('Starting Fit Set '+string(i)+'/'+string(loopLength)+'---- \n')
        meltArea = zeros(length(lsTrimmed),1);
        startPoint = rsTrimmed(i).short(end,1);
        slopeLeft = rsTrimmed(i).slope(1,1);
        yIntLeft = rsTrimmed(i).slope(1,2);
        derVal = [];
        tanhBaselines = [];
        for j = 1:length(lsTrimmed)
            slopeRight = lsTrimmed(j).polyFit(1,1);
            yIntRight = lsTrimmed(j).polyFit(1,2);
            endPoint = lsTrimmed(j).short(1,1);
            xtanhData = linspace(startPoint,endPoint,1000)';
            ytanhData = tanBaseline(xtanhData,slopeLeft,yIntLeft,slopeRight,yIntRight,critVal,width);
            tanhBaselines{j} = [xtanhData,ytanhData];
            tanhBaseline = [xtanhData,ytanhData];
            g = griddedInterpolant(tanhBaseline(:,1),tanhBaseline(:,2));
            G = @(t) g(t);
            tanhArea = integral(G,tanhBaseline(1,1),tanhBaseline(end,1));
            dataArea = integral(F,startPoint,endPoint);
            meltArea(j) = dataArea-tanhArea;
        end
        maxVal = max(meltArea);
        minVal = min(meltArea);
        normAreas = zeros(length(lsTrimmed),1);
        midVal = (maxVal+minVal)/2;
        for k = 1:length(normAreas)
            if meltArea(k) == midVal
                normAreas(k) = 0;
            elseif meltArea(k) < midVal
                normAreas(k) = ((meltArea(k)-midVal)/(midVal-minVal));
            else
                normAreas(k) = ((meltArea(k)-midVal))/(maxVal-midVal);                
            end
        end
        [midNormArea,midNormAreaLoc] = min(abs(normAreas));
        fullMeltFits(i).bestFitIndex = midNormAreaLoc;
        fullMeltFits(i).bestArea = midNormArea;
        fullMeltFits(i).bestMatchLiquid = lsTrimmed(midNormAreaLoc).short;
    end
end

