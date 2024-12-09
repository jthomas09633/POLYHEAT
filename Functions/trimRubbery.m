function rubberyTrimmed = trimRubbery(fitsRubbery)
%TRIMLIQUID Summary of this function goes here
%   Detailed explanation goes here
    rubberyTrimmed = struct();
    x = 0;
    fields = fieldnames(fitsRubbery);
    for i = 1:length(fitsRubbery)
        if fitsRubbery(i).rSqrd >= 0.95
            x = x+1;
            for j = 1:numel(fields)
                rubberyTrimmed(x).(fields{j}) = fitsRubbery(i).(fields{j});
            end
        end
    end
end