function [norm_yval,norm_deryval] = convDataSetup(localSegment)
%CONVDATASETUP setting up the data to be convolved. Normalizing the data.
    xval = localSegment(:,1);
    yval = localSegment(:,2);
    derY = sgolayfilt(gradient(yval)./gradient(xval),1,21);
    norm_deryval = derY/max(derY);
    norm_yval = yval/max(yval);
end

