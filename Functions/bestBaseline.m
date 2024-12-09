function [best_baseline,best_rubbery_fit,best_liquid_fit] = bestBaseline(localSegment,trimmed_rubbery_state,trimmed_liquid_state,full_melt_fits_LiTRu,full_melt_fits_RuTLi,sder_peaks_int)
%BESTBASELINE with the best rubbery state and best liquid state found the
%final tanh baseline is calculated with this pairing
%
%   Outputs
%           best_baseline       - Best baseline full range from start of
%                                 state to end of liquid state
%           best_rubbery_fit    - The best baseline of the rubbery state
%                                 reported from the liquid perspective
%           best_liquid_fit     - The best baseline of the liquid state
%                                 reported from the rubbery perspective
%
%************************************************************************%
    [~,peak_index] = max(localSegment(:,2));
    crit_val = localSegment(peak_index,1);
    w1 = sder_peaks_int(end,2);
    w2 = sder_peaks_int(1,2);
    width = -(localSegment(w1,1)-localSegment(w2,1))/2;
    liquid_preference = mode(vertcat(full_melt_fits_LiTRu.bestFitIndex));
    rubbery_preference = mode(vertcat(full_melt_fits_RuTLi.bestFitIndex));
    slopeLeft = trimmed_rubbery_state(liquid_preference).slope(1,1);
    yIntLeft = trimmed_rubbery_state(liquid_preference).slope(1,2);
    slopeRight = trimmed_liquid_state(rubbery_preference).polyFit(1,1);
    yIntRight = trimmed_liquid_state(rubbery_preference).polyFit(1,2);
    xtanhdata = linspace(trimmed_rubbery_state(liquid_preference).short(1,1),trimmed_liquid_state(rubbery_preference).short(end,1),1000)';
    
    final_tanh_yvalues = tanBaseline(xtanhdata,slopeLeft,yIntLeft,slopeRight,yIntRight,crit_val,width);
    best_baseline = [xtanhdata,final_tanh_yvalues];
    best_rubbery_fit = liquid_preference;
    best_liquid_fit = rubbery_preference;
end

