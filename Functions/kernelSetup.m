function [positive_peak_kernel,negative_peak_kernel,sigmoidal_kernel] = kernelSetup()
%KERNELSETUP Intialization of the three kernels. kernel widths are
%proportional to the expected widths of the signal itself. 
    % setting up kernels
    % positive kernel is a step function which is broad to capture the
    % relative width of a melt structure
    positive_peak_kernel(1:50) = zeros(50,1);
    positive_peak_kernel(51:100) = ones(50,1);
    
    % negative kernel is the inverse of the positive as it is used to
    % detect cold crystalization
    negative_peak_kernel = -positive_peak_kernel;

    % sigmoid kernel is a norrow version of the positive kernel to detect
    % glass transitions while being used to avoid melt peaks
    sigmoidal_kernel = positive_peak_kernel(45:55);

    % Normalizing Kernels 
    positive_peak_kernel = positive_peak_kernel/max(abs(positive_peak_kernel));
    negative_peak_kernel = negative_peak_kernel/max(abs(negative_peak_kernel));
    sigmoidal_kernel = sigmoidal_kernel/max(abs(sigmoidal_kernel));
end

