function [midNormArea,midNormAreaLoc] = midMeltArea(meltArea)
%MIDMELTAREA finds the middle value of the normalized area values,
%normalizes data between 1 and -1, finds the area closes to 0. 
    maxVal = max(meltArea);
    minVal = min(meltArea);
    normAreas = zeros(length(meltArea),1);
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
end

