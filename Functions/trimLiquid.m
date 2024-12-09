function lsTrimmed = trimLiquid(lsEndOfData)
%TRIMLIQUID trimming liquid state of low quality fits
%   this is generous as the liquid state can have a good amount of noise so
%   the critical value for rSquard used is 0.8
%
%************************************************************************%
    lsTrimmed = struct();
    x = 0;
    fields = fieldnames(lsEndOfData);
    for i = 1:length(lsEndOfData)
        if lsEndOfData(i).rSqrd >= 0.80
            x = x+1;
            for j = 1:numel(fields)
                lsTrimmed(x).(fields{j}) = lsEndOfData(i).(fields{j});
            end
        end
    end
end