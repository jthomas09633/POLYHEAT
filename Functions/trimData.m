function allFilesStruct = trimData(allFilesStruct)
%TRIMDATA this function trims the leading start up hook from heating
%segments and the end hook. Two different methods are used for FSC and DSC.
%DSC is based on rule of thumb, 1 C removed for every 1 C/min (a scan at 10
%C/min would have the first 10 C removed.) Then an additional 2 C is
%removed for robustness. 
%
%FSC is trimmed using the startUpHookEstimator built on empirical evidence
%of the average length per rate of a large sample of sensors
    for i = 1:length(allFilesStruct)
        if strcmp(allFilesStruct(i).source,'FSC File')
            for j = 1:length(allFilesStruct(i).cpHeating)
                rate = allFilesStruct(i).ratesHeating(j);
                startTemp = startUpHookEstimator(rate);
                trimTemp = allFilesStruct(i).cpHeating{j}(1,1)+startTemp;
                [~,startLoc] = min(abs(allFilesStruct(i).cpHeating{j}(:,1)-trimTemp));
                trimmedData = allFilesStruct(i).cpHeating{j}(startLoc:end,:);
                allFilesStruct(i).cpHeating{j} = [];
                allFilesStruct(i).cpHeating{j} = trimmedData;
            end
    
        elseif strcmp(allFilesStruct(i).source,'TA QSeries')...
            && isfield(allFilesStruct,'scanType') && ...
                    strcmp(allFilesStruct(i).scanType,'Modulated')
            for j = 1:length(allFilesStruct(i).cpModHeating)
                step = 1/allFilesStruct(i).ratesModHeating(j);
                startTrim = ceil(60/step)+10;
                endTrim = ceil(3/step);
                startTemp = allFilesStruct(i).cpModHeating{j}(1,1)+startTrim;
                endTemp = allFilesStruct(i).cpModHeating{j}(end,1)-endTrim;
                [~,startPos] = min(abs(allFilesStruct(i).cpModHeating{j}(:,1)-startTemp));
                [~,endPos] = min(abs(allFilesStruct(i).cpModHeating{j}(:,1)-endTemp));
                trimmedData = allFilesStruct(i).cpModHeating{j}(startPos:endPos,:);
                allFilesStruct(i).cpModHeating{j} = [];
                allFilesStruct(i).cpModHeating{j} = trimmedData;
            end
            for j = 1:length(allFilesStruct(i).cpHeating)
                step = 1/allFilesStruct(i).ratesHeating(j);
                startTrim = ceil(60/step)+ceil(2/step);
                endTrim = ceil(3/step);
                startTemp = allFilesStruct(i).cpHeating{j}(1,1)+startTrim;
                endTemp = allFilesStruct(i).cpHeating{j}(end,1)-endTrim;
                [~,startPos] = min(abs(allFilesStruct(i).cpHeating{j}(:,1)-startTemp));
                [~,endPos] = min(abs(allFilesStruct(i).cpHeating{j}(:,1)-endTemp));
                trimmedData = allFilesStruct(i).cpHeating{j}(startPos:endPos,:);
                allFilesStruct(i).cpHeating{j} = [];
                allFilesStruct(i).cpHeating{j} = trimmedData;
            end
        else
            for j = 1:length(allFilesStruct(i).cpHeating)
                step = 1/allFilesStruct(i).ratesHeating(j);
                startTrim = ceil(60/step)+ceil(2/step);
                endTrim = ceil(3/step);
                startTemp = allFilesStruct(i).cpHeating{j}(1,1)+startTrim;
                endTemp = allFilesStruct(i).cpJeating{j}(end,1)-endTrim;
                [~,startPos] = min(abs(allFilesStruct(i).cpHeating{j}(:,1)-startTemp));
                [~,endPos] = min(abs(allFilesStruct(i).cpHeating{j}(:,1)-endTemp));
                trimmedData = allFilesStruct(i).cpHeating{j}(startPos:endPos,:);
                allFilesStruct(i).cpHeating{j} = [];
                allFilesStruct(i).cpHeating{j} = trimmedData;
            end
        end
    end
end