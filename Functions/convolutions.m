function [conv_positive_peaks,conv_negative_peaks,conv_sigmoidal_steps] = convolutions(norm_yval,norm_deryval,positive_peak_kernel,negative_peak_kernel,sigmoidal_kernel)
%CONVOLUTIONS Summary of this function goes here
%   Detailed explanation goes here
    conv_positive_peaks = conv(norm_yval, positive_peak_kernel,'same');
    conv_negative_peaks = conv(norm_yval, negative_peak_kernel,'same');
    conv_sigmoidal_steps = conv(norm_deryval, sigmoidal_kernel,'same');
    conv_sigmoidal_steps = sgolayfilt(conv_sigmoidal_steps,1,21);
end

