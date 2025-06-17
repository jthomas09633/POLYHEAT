%% Main Script for Automated Analysis
dataStruct = importFiles();

dataStruct = cpArray(dataStruct);

dataStruct = trimData(dataStruct);

dataStruct = cpAnalysis(dataStruct);

fprintf('Analysis Complete! \n \n')
fprintf('Result are stored in the variable "dataStruct". \n')