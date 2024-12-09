function [heat_of_fusion_total,heat_of_fusion_first_contact,heat_of_fusion_secondary] ...
    = heatOfFusion(localSegment,sec_der_peaks_int,best_baseline)
%HEATOFFUSION Determines the melt area of the crystal melting in two ways
% using the best found tanh baseline. The first area is the entire intergal
% from the start of the rubbery state baseline to the end of the liquid
% state baseline of the data minus the area under the baseline (same
% bounds). The second area is the area of first conact between the baseline
% and the melt peak itself. Imagine moving from the peak of the melt peak
% left and right and the position where the data first intersects the
% baseline from both sides are the bounds. 
%
%   Outputs:
%       heat_of_fusion_total                - first area described
%       heat_of_fusion_first_contact        - second area described
%       heat_of_fusion_secondary_structures - difference between first and
%                                             second
%
%*************************************************************************%
    f = griddedInterpolant(localSegment(:,1),localSegment(:,2));
    F = @(t) f(t);
    h = griddedInterpolant(best_baseline(:,1),best_baseline(:,2));
    H = @(t) h(t);
    dataInt = integral(F,best_baseline(1,1),best_baseline(end,1));
    baseInt = integral(H,best_baseline(1,1),best_baseline(end,1));
    heat_of_fusion_total = dataInt-baseInt;
    for i = sec_der_peaks_int(1,2):-1:2
        if F(localSegment(i,1)) > H(localSegment(i,1)) &&...
                F(localSegment(i-1,1)) < H(localSegment(i,1))
            left_contact = i;
        end
    end
    for i = sec_der_peaks_int(2,2):length(localSegment)
        if F(localSegment(i,1)) > H(localSegment(i,1)) &&...
                F(localSegment(i-1,1)) < H(localSegment(i,1))
            right_contact = i;
        end
    end
    first_contact_data_int = integral(F,localSegment(left_contact,1),...
        localSegment(right_contact,1));
    first_contact_base_int = integral(H,localSegment(left_contact,1),...
        localSegment(right_contact,1));
    heat_of_fusion_first_contact = first_contact_data_int-first_contact_base_int;
    heat_of_fusion_secondary = heat_of_fusion_total-heat_of_fusion_first_contact;
end

