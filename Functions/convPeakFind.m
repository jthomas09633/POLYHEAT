function [positive_peaks,negative_peaks,sigmoidal_steps] = convPeakFind(conv_positive_peaks,conv_negative_peaks,conv_sigmoidal_steps)
%CONVPEAKFIND finding the parts of the signal that respond to each kernel.
% Positive peaks correspond to positive peak kernel with the 90 percentile, 
% same for the negative peaks. Sigmoidal peaks are given a lower thershold
% as the first derivative of the heat capacity returns small peaks for Tg
% and the signal is dominated by potential crystal melting or cold
% crystalization. 
%
%*************************************************************************%
    % thresholds for detection 
    threshold_pos_peaks = prctile(conv_positive_peaks,90);
    threshold_neg_peaks = prctile(conv_negative_peaks,90);
    threshold_sig_steps = prctile(conv_sigmoidal_steps,65);
    
    % detecting features
    positive_peaks = find(conv_positive_peaks > threshold_pos_peaks);
    negative_peaks = find(conv_negative_peaks > threshold_neg_peaks);
    sigmoidal_steps = find(conv_sigmoidal_steps > threshold_sig_steps);
end

