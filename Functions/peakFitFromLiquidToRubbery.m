function fullMeltFits = peakFitFromLiquidToRubbery(data,rsTrimmed,lsTrimmed,sdPeaksInt)
%PEAKFITFROMLIQUIDTORUBBERY returns all fits made using the liquid states 
% perspective. Starting with the first fit in the liquid state, a baseline
% fit is made with each possible trimmed rubbery state fit. The area is
% then recorded and then the next fit is made with the same liquid state
% but the next longest rubbery state. This process is repeated until all
% rubbery state baselines have been used. From here the areas calculated
% are normalized using midMeltArea(). The goal here is to find the rubbery
% state baseline that returns the "least extreme" area. Areas are
% normalized from -1 to 1, and the normalized area closest to 0 is returned
% as the best rubbery state baseline for a given liquid state. This process
% is then repeated with the next liquid state baseline. 
%
%       Outputs:
%           fullMeltFits        - Struct with fields bestFitIndex and
%                                 bestFullArea (length of struct is the
%                                 same as the number of liquid state fits)
%               Fields:
%                   bestFitIndex    - Rubbery fit that produced the
%                                       normalized area closest to zero for
%                                       a given liquid state
%                   bestFullArea    - Area of the best fit
%
% ***********************************************************************%
    funcData = data;
    [~,peakIndex] = max(funcData(:,2));
    critVal = funcData(peakIndex,1);
    width = -(funcData(sdPeaksInt(2,2),1)-funcData(sdPeaksInt(1,2),1))/2;
    loopLength = length(lsTrimmed);
    fullMeltFits = [];
    f = griddedInterpolant(funcData(:,1),funcData(:,2));
    F = @(t) f(t);
    parfor i = 1:loopLength
        fprintf('Starting L2R Fit Set '+string(i)+'/'+string(loopLength)+'---- \n')
        fullmeltArea = zeros(length(rsTrimmed),1);
        slopeRight = lsTrimmed(i).polyFit(1,1);
        yIntRight = lsTrimmed(i).polyFit(1,2);
        tanhBaselines = [];
        endPoint = lsTrimmed(i).short(end,1);
        for j = 1:length(rsTrimmed)
            slopeLeft = rsTrimmed(j).slope(1,1);
            yIntLeft = rsTrimmed(j).slope(1,2);
            startPoint = rsTrimmed(j).short(1,1);
            xtanhData = linspace(startPoint,endPoint,1000)';
            ytanhData = tanBaseline(xtanhData,slopeLeft,yIntLeft,slopeRight,yIntRight,critVal,width);
            tanhBaseline = [xtanhData,ytanhData];
            tanhBaselines{j} = tanhBaseline;
            g = griddedInterpolant(tanhBaseline(:,1),tanhBaseline(:,2));
            G = @(t) g(t);
            fulltanhArea = integral(G,tanhBaseline(1,1),tanhBaseline(end,1));
            fulldataArea = integral(F,startPoint,endPoint);
            fullmeltArea(j) = fulldataArea-fulltanhArea;
        end
        [midNormAreaFull,midNormAreaFullLoc] = midMeltArea(fullmeltArea);
        fullMeltFits(i).bestFitIndex = midNormAreaFullLoc;
        fullMeltFits(i).bestFullArea = midNormAreaFull;
    end
end