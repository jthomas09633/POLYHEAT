%% Main Script for Automated Analysis
dataStruct = importFiles();

dataStruct = cpArray(dataStruct);
dataStruct = trimData(dataStruct);

for i = 1:length(dataStruct)
    fprintf("\nStarting the analysis of: "+dataStruct(i).sampleName+"... \n \n")
    for j = 1:length(dataStruct(i).cpHeating)
        min_fit_length = dataStruct(i).minFitLengthH(j);
        localSegment = [dataStruct(i).cpHeating{j}(:,1),dataStruct(i).cpHeating{j}(:,2)];
        phaseDynamic = phaseIdentify(localSegment);
        if strcmp(phaseDynamic,'No event')
            dataStruct(i).qualResults{j} = 'No Event';
        elseif strcmp(phaseDynamic,'Glass Transition')
            dataStruct(i).qualResults{j} = 'Glass Transition Only';
            result = singlePhaseTg(localSegment,min_fit_length);
            result.orgIndex = j;
            if ~isfield(dataStruct,'singlePhaseResult')
                dataStruct(i).singlePhaseResult = result;
            else
                dataStruct(i).singlePhaseResult(end+1) = result;
            end
            %continue %do this for now, will come back for Tg only assessment
        else
            dataStruct(i).qualResults{j} = 'Complex Case';
            %dynamic checking
            result = twoPhaseAnalysis(localSegment,min_fit_length);
            result.orgIndex = j;
            if ~isfield(dataStruct,'twoPhaseResult')
                dataStruct(i).twoPhaseResult = result;
            else
                dataStruct(i).twoPhaseResult(end+1) = result;
            end
        end
    end
end
fprintf('Analysis Complete! \n \n')
fprintf('Result are stored in the variable "dataStruct". \n')