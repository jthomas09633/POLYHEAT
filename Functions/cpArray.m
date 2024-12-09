function allFilesStruct = cpArray(allFilesStruct)
%CPARRAY takes each heating and cooling segment and converts it to heat
%capacity
%   
%
%
    for i = 1:length(allFilesStruct)
        cpHeating = [];
        cpCooling = [];
        x = 0;
        if isfield(allFilesStruct,'scanType') && ...
                strcmp(allFilesStruct(i).scanType,'Modulated')
            M = allFilesStruct(i).mass;
            for k = 1:length(allFilesStruct(i).modHeating)
                rate = allFilesStruct(i).ratesModHeating(k);
                cpModHeating{k,1}(:,2) = ...
                    allFilesStruct(i).modHeating{k}(:,2)/(M*-rate);
                cpModHeating{k,1}(:,1) = ...
                    allFilesStruct(i).modHeating{k}(:,1);
            end
            allFilesStruct(i).cpModHeating = cpModHeating;
        end
        for j = 1:length(allFilesStruct(i).heating)
            rate = allFilesStruct(i).ratesHeating(j);
            cpHeating{j,1}(:,1) = allFilesStruct(i).heating{j}(:,1);
            if strcmp(allFilesStruct(i).source,'TA QSeries')
                M = allFilesStruct(i).mass;
                cpHeating{j,1}(:,2) = allFilesStruct(i).heating{j}(:,2)/(M*-rate);
            else
                cpHeating{j,1}(:,2) = allFilesStruct(i).heating{j}(:,2)/-rate;
        
            end
        end
        for k = 1:length(allFilesStruct(i).cooling)
            rate = allFilesStruct(i).ratesCooling(k);
            cpCooling{k,1}(:,1) = allFilesStruct(i).cooling{k}(:,1);
            if strcmp(allFilesStruct(i).source,'TA QSeries')
                M = allFilesStruct(i).mass;
                cpCooling{k,1}(:,2) = allFilesStruct(i).cooling{k}(:,2)/(M*-rate);
            else
                cpCooling{k,1}(:,2) = allFilesStruct(i).cooling{k}(:,2)/-rate;
        
            end
        end
        allFilesStruct(i).cpHeating = cpHeating;
        allFilesStruct(i).cpCooling = cpCooling;
    end
end

