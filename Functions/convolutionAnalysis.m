function events = convolutionAnalysis(localSegment)
%CONVOLUTIONANALYSIS returns the events associated with a given segment
%through convolutional analysis. Three kernels are used to amplify the
%following signals, positive peaks, negative peaks, sigmoidal steps.
%
%   Positive Peak Kernel    - Step function using 5 C of width set to 0 and
%                               5 C of width set to 1
%   Negative Peak Kernel    - Step function using 5 C of width set to 0 and 
%                               5 C of width set to -1
%   Sigmoidal Peak Kernel   - Step function using 0.5 C of width set to 0
%                               and 0.5 C of width set to 1 (applied to 
%                               first derivative of the data) 
%
%*************************************************************************%

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