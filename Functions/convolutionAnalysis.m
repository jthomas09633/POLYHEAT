function events = convolutionAnalysis(localSegment)
%CONVOLUTIONANALYSIS Summary of this function goes here
%   Detailed explanation goes here
    [positive_peak_kernel,negative_peak_kernel,sigmoidal_kernel] = kernelSetup();
    % data setup
    [norm_yval,norm_deryval] = convDataSetup(localSegment);
    
    % convolutions
    [conv_positive_peaks,conv_negative_peaks,conv_sigmoidal_steps] = ...
        convolutions(norm_yval,norm_deryval,positive_peak_kernel,negative_peak_kernel,sigmoidal_kernel);
    % feature detect
    [positive_peaks,negative_peaks,sigmoidal_steps] = ...
        convPeakFind(conv_positive_peaks,conv_negative_peaks,conv_sigmoidal_steps);
    % true events
    [pos_peaks_true_loc,neg_peaks_true_loc,sig_true_loc] = ...
        truePeak(localSegment,conv_positive_peaks,conv_negative_peaks,conv_sigmoidal_steps,positive_peaks,negative_peaks,sigmoidal_steps);
    % final order of events
    events = eventCountConvolution(pos_peaks_true_loc,neg_peaks_true_loc,sig_true_loc);
end