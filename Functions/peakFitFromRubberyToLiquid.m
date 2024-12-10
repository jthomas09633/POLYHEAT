function fullMeltFits = peakFitFromRubberyToLiquid(data,rsTrimmed,lsTrimmed,sdPeaksInt)
%PEAKFITFROMRUBBERYTOLIQUID returns all fits made using the rubbery states 
% perspective. Starting with the first fit in the rubbery state, a baseline
% fit is made with each possible trimmed liquid state fit. The area is
% then recorded and then the next fit is made with the same rubbery state
% but the next longest liquid state. This process is repeated until all
% liquid state baselines have been used. From here the areas calculated
% are normalized using midMeltArea(). The goal here is to find the liquid
% state baseline that returns the "least extreme" area. Areas are
% normalized from -1 to 1, and the normalized area closest to 0 is returned
% as the best liquid state baseline for a given rubbery state. This process
% is then repeated with the next rubbery state baseline. 
%
%       Outputs:
%           fullMeltFits        - Struct with fields bestFitIndex and
%                                 bestFullArea (length of struct is the
%                                 same as the number of liquid state fits)
%               Fields:
%                   bestFitIndex    - Liquid fit that produced the
%                                       normalized area closest to zero for
%                                       a given rubbery state
%                   bestArea        - Area of the best fit
%
% ***********************************************************************%
    funcData = data; 
    [~,peakIndex] = max(funcData(:,2));
    critVal = funcData(peakIndex,1);
    width = -(funcData(sdPeaksInt(2,2),1)-funcData(sdPeaksInt(1,2),1))/2;
    loopLength = length(rsTrimmed);
    fullMeltFits = [];
    f = griddedInterpolant(funcData(:,1),funcData(:,2));
    F = @(t) f(t);
    parfor i = 1:loopLength
        meltArea = zeros(length(lsTrimmed),1);
        startPoint = rsTrimmed(i).short(end,1);
        slopeLeft = rsTrimmed(i).slope(1,1);
        yIntLeft = rsTrimmed(i).slope(1,2);
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
        [midNormArea,midNormAreaLoc] = midMeltArea(meltArea);
        fullMeltFits(i).bestFitIndex = midNormAreaLoc;
        fullMeltFits(i).bestArea = midNormArea;
    end
end

