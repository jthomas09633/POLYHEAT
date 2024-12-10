function [pos_peaks_true_loc,neg_peaks_true_loc,sig_true_loc] = ...
    truePeak(localSegment,conv_positive_peaks,conv_negative_peaks,conv_sigmoidal_steps,positive_peaks,negative_peaks,sigmoidal_steps)
%TRUEPEAK Finds the real events corresponding to the convolved signals
%   The variables: conv_positive_peaks, conv_negative_peaks, and
%   conv_sigmoidial_steps are arrays of values that cleared the
%   thresholding after convolution. this means they contain ranges of
%   values but we want only a single value for each event. to do this we
%   find the peaks in these arrays. this will then return the number of
%   events corresponding to the dynamic
%
%       Example 1:              | v.s.  | Example 2:
%                               |       |
%           ^                   |       |
%                               |       |       ^
%          ^ ^         ^        | v.s.  |      ^  ^
%                               |       |     ^      ^
%         ^   ^       ^ ^       |       |    ^          ^
%  .......     .......    ....  |       |....              ........
%
% Imagine the ^ correspond to data points that pass the threshold while .
% corresponds to data that did not meet the threshold, Example 1 we
% would say there are two event as there is a distinct separation and in
% Example 2 there is only 1 event. 
%
%
% A complex dynamic arises when searching for Tg as any signal that
% corresponds with a peak in the first derivative would corresspond to the
% two peaks associated with peak in the original data
%
%
%
%
%                                Single Melt Peak
%
%                                |**************|
%     Tg                          ^            ^
%    |***|                       ^ ^          ^ ^
%      ^                        ^   ^        ^   ^
% ....^ ^......................^     ^......^     ^.............
%
% Finding Tg without isolating the melt "doublet" can be performed by using
% a spatial association with the found melt peak from the
% positive_peak_kernel. For every one peak found in the
% positive_peak_kernel, then two peaks should be seen in the
% sigmoidal_peak_kernel. If there is an odd number then the remainder would
% be Tg. Then between peak intensity and peak positioning, the two peaks
% corresponding to a melt will be relatively close to the position of the
% one peak in the positive_peak_kernel. This leaves us with just the peak
% corresponding to the glass transition.
%
%************************************************************************%
    temp_step = mean(gradient(localSegment(:,1)));
    [~,pos_peak_loc] = findpeaks(conv_positive_peaks(positive_peaks));
    [~,neg_peak_loc] = findpeaks(conv_negative_peaks(negative_peaks));
    [~,sig_peak_loc] = findpeaks(conv_sigmoidal_steps(sigmoidal_steps));
    pos_peaks_true_loc = [];
    x = 0;
    for i = 1:length(pos_peak_loc)
        index = positive_peaks(pos_peak_loc(i));
        if index <= length(conv_positive_peaks)-ceil(3/temp_step)
            x = x+1;
            pos_peaks_true_loc(x) = index;
        end
    end
    
    neg_peaks_true_loc = [];
    x = 0;
    rms_neg = rms(conv_negative_peaks(conv_negative_peaks > 0));
    for i = 1:length(neg_peak_loc)
        index = negative_peaks(neg_peak_loc(i));
        if conv_negative_peaks(index) > rms_neg
            x = x+1;
            neg_peaks_true_loc(x) = index;
        end
    end

    rms_tg_start = rms(conv_sigmoidal_steps(1:ceil(10/temp_step)));
    rms_tg = rms(conv_sigmoidal_steps);
    x = 0;
    sig_peak_int = [];
    for i = 1:length(sig_peak_loc)
        index = sigmoidal_steps(sig_peak_loc(i));
        x = x+1;
        sig_peak_int(x) = index;
    end

    threshold = ceil(10/temp_step);
    reduced_array = closeVals(sig_peak_int,threshold);
    sig_true_loc = [];
    x = 0;

    for i = 1:length(reduced_array)
        if log10(conv_sigmoidal_steps(reduced_array(i)))-log10(rms_tg_start) > 0.9 && conv_sigmoidal_steps(reduced_array(i)) < rms_tg
            for j = 1:length(pos_peaks_true_loc)
                if abs(reduced_array(i)-pos_peaks_true_loc(j)) > ceil(10/temp_step)
                    if ~isempty(neg_peaks_true_loc)
                        for k = 1:length(neg_peaks_true_loc)
                            if abs(reduced_array(i)-neg_peaks_true_loc(k)) > ceil(10/temp_step)
                                x = x+1;
                                sig_true_loc(x) = reduced_array(i);
                            end
                        end
                    else
                        x = x+1;
                        sig_true_loc(x) = reduced_array(i);
                    end
                end
            end
        end
    end
end

