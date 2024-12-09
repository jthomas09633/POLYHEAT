%% Main Script for Automated Analysis
dataStruct = importFiles();
dataStruct = cpArray(dataStruct);
dataStruct = trimData(dataStruct);

for i = 1:length(dataStruct)
    for j = 1:length(dataStruct(i).cpHeating)
        min_fit_length = dataStruct(i).minFitLengthH(j);
        localSegment = dataStruct(i).cpHeating(j);
        phaseDynamic = phaseIdentify(localSegment);
        if isnan(phaseDynamic)
            dataStruct(i).qualResults(j) = 'No Event';
        elseif istring(phaseDynamic)
            dataStruct(i).qualResults(j) = 'Glass Transition Only';
            continue %do this for now, will come back for Tg only assessment
        else
            twoPhaseResult = twoPhaseAnalysis(localSegment,min_fit_length);
        end
    end
end