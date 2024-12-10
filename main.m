%% Main Script for Automated Analysis
dataStruct = importFiles();

dataStruct = cpArray(dataStruct);
dataStruct = trimData(dataStruct);

for i = 1:length(dataStruct)
    for j = 1:length(dataStruct(i).cpHeating)
        min_fit_length = dataStruct(i).minFitLengthH(j);
        localSegment = [dataStruct(i).cpHeating{j}(:,1),dataStruct(i).cpHeating{j}(:,2)];
        phaseDynamic = phaseIdentify(localSegment);
        if strcmp(phaseDynamic,'No event')
            dataStruct(i).qualResults{j} = 'No Event';
        elseif strcmp(phaseDynamic,'Glass Transition')
            dataStruct(i).qualResults{j} = 'Glass Transition Only';
            continue %do this for now, will come back for Tg only assessment
        else
            j
            dataStruct(i).qualResults{j} = 'Complex Case';
            %dynamic checking
            tic
            result = twoPhaseAnalysis(localSegment,min_fit_length);
            result.orgIndex = j;
            toc
            if ~isfield(dataStruct,'twoPhaseResult')
                dataStruct(i).twoPhaseResult = result;
            else
                dataStruct(i).twoPhaseResult(end+1) = result;
            end
        end
    end
end