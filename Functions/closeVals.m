function reduced_array = closeVals(array,threshold)
%CLOSEVALS Summary of this function goes here
%   Detailed explanation goes here
    reduced_array = [];
    i = 1;
    while i <= length(array)
        current_group = array(i);
        j = i+1;
        while j <= length(array) && (array(j)-array(i)) <= threshold
            current_group = [current_group,array(j)];
            j = j+1;
        end
        group_average = ceil(mean(current_group));
        reduced_array = [reduced_array,group_average];
        i = j;
    end
end

