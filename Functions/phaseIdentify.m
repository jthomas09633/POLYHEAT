function phaseDynamic = phaseIdentify(localSegment)
%PHASEIDENTIFY Summary of this function goes here
%   Detailed explanation goes here
    %checks if the curve contains only a Tg
    result = tgSearch(localSegment);
    if result == -1
        phaseDynamic = NaN;
    elseif result == 0
        phaseDynamic = convolutionAnalysis(localSegment);
    else
        phaseDynamic = 'Glass Transition';
    end
end

