function [norm_yval,norm_deryval] = convDataSetup(localSegment)
%CONVDATASETUP Summary of this function goes here
%   Detailed explanation goes here
    xval = localSegment(:,1);
    yval = localSegment(:,2);
    derY = sgolayfilt(gradient(yval)./gradient(xval),1,21);
    norm_deryval = derY/max(derY);
    norm_yval = yval/max(yval);
end

