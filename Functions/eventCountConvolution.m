function events = eventCountConvolution(pos_peaks_true_loc,neg_peaks_true_loc,sig_true_loc)
%EVENTCOUNTCONVOLUTION labels and counts each event.
    all_events = [sig_true_loc,neg_peaks_true_loc,pos_peaks_true_loc];
    all_events_sorted = sort(all_events);
    labeled_events = {};
    for i = 1:length(all_events_sorted)
        if ismember(all_events_sorted(i),sig_true_loc)
            labeled_events{i} = 'Glass Transition';
        elseif ismember(all_events_sorted(i),neg_peaks_true_loc)
            labeled_events{i} = 'Cold Crystallization';
        elseif ismember(all_events_sorted(i),pos_peaks_true_loc)
            labeled_events{i} = 'Crystal Melt';
        end
    end
    events = labeled_events;
end

