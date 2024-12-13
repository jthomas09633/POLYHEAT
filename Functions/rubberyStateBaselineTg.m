function rubbery_state_baseline = rubberyStateBaselineTg(localSegment,rubbery_state_start,min_fit_length);
%RUBBERYSTATEBASELINETG Summary of this function goes here
%   Detailed explanation goes here
    funcData = localSegment(rubbery_state_start:end-min_fit_length,:);
    p = polyfit(funcData(:,1),funcData(:,2),1);
    yvals = polyval(p,funcData(:,1));
    rubbery_state_baseline = [funcData(:,1),yvals];
end

