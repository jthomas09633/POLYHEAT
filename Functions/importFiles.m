function data = importFiles()
%IMPORTFILES
%*************NOTE UTF-16 and UTF-16LE are not supported*******************
%
%   Support Machines: 
%       Mettler:        Flash 1
%       TA Instruments: QSeries, Discovery Series
%
%   Inputs:
%   -   N/A
%
%   Outputs:
%   -   data    tpye: Struct
%       -   Fields:
%           - source        The machine that the data came from
%           - file          Full file path to data
%           - sampleName    Filename without path or extensions
%           - data          Raw data stripped of any header
%           - heating       Heating segments in time order of experiment
%           - cooling       Cooling segemnts in time order of experiment
%           - ratesHeating  Heating segments rates in time order of exp.
%           - ratesCooling  Cooling segments rates in time order of exp.
%           - mass          If DSC file is imported, starting mass
%           - iso           If DSC file, iso segements in time order
%           - numSegs       If DSC file, number of thermal segments 
% Assumptions:
%   -   All files being imported are located in the same folder.
%   -   When Importing TA DSC data, the header must be included.
%   -   If an isothermal hold in DSC for TA is 1min or less, it is not
%       logged. This is reflected in the numSegs field of the output
%   -   Temp vs Time is used for determining segments of DSC. Number of
%       segments is determined by the number of Ramp segments + Isothermal
%       segments longer than 1 minute.
%*************************************************************************%
    [baseFileName, folder] = uigetfile('*','Select One or More Files',...
        'MultiSelect','on');
    if ischar(baseFileName)
        data = singleFile(baseFileName,folder);
    else
        data = multiFile(baseFileName,folder);
    end
    function source = parseFile(fFN)
        % checks each file to determine if it is a TA DSC, TA TMDSC, or
        % Mettler FSC file
        taQSeries = {'Q10','Q100','Q1000','Q20','Q200','Q2000'};
        taDSeries = {'DSC25','DSC250','DSC2500'};
        fid = fopen(fFN);
        tline = fgetl(fid);
        while ischar(tline)
            if contains(tline, taQSeries)
                source = 'TA QSeries';
                flag = 1;
                break
            elseif contains(tline, taDSeries)
                source = 'TA Discovery Series';
                flag = 1;
                break
            end
            tline = fgetl(fid);
        end
        if ~exist('flag','var')
            source = 'FSC File';
        end
        fclose(fid);
    end
    function tempMass = findMass(fFN)
        fid = fopen(fFN);
        tline = fgetl(fid);
        while ischar(tline)
            if contains(tline,'Size')
               mass = regexp(tline,'\d+\.?\d*','match');
               floatMass = str2double(mass);
               tempMass = floatMass;
            end
            tline = fgetl(fid);
        end
        fclose(fid);
    end
    function ntbl = fscTable(tbl)
        for i = 1:width(tbl)
            val = tbl{1,i};
            if ~isa(val,'double')
                indexToRemove = i;
            end
        end
        if exist('indexToRemove','var')
            tbl(:,indexToRemove) = [];
        end
        ntbl = table2array(tbl);
    end
    function [segHeating,segCooling,ratesHeating,ratesCooling,minFitLengthH,minFitLengthC] = segFSC(ntbl)
        logik = ~isnan(ntbl(:,1));
        ntbl = ntbl(logik,:);
        xZeros = ntbl(:,1)==0;
        numZeros = sum(xZeros);
        zeroPos = find(xZeros);
        heating = [];
        cooling = [];
        ratesHeating = [];
        ratesCooling = [];
        minFitLengthH = [];
        minFitLengthC = [];
        x = 0;
        y = 0;
        [~,checkDim] = size(ntbl);
        if checkDim == 4
            tempChangeCol = 3;
        else
            tempChangeCol = 4;
        end
        for j = 1:length(zeroPos)
            fprintf("---------------------------------------------------\n")
            fprintf("Starting Segment: "+string(j))
            if ntbl(zeroPos(j)+10,4)-ntbl(zeroPos(j),tempChangeCol) == 0
                continue
            elseif ntbl(zeroPos(j)+10,4)-ntbl(zeroPos(j),tempChangeCol) > 0
                x = x+1;
                fprintf(' Heating Segment\n')
                if j == length(zeroPos)
                    segRate = [];
                    segRate = [ntbl(zeroPos(j):end,2),ntbl(zeroPos(j):end,tempChangeCol)];
                    P = polyfit(segRate(:,1),segRate(:,2),1);
                    ratesHeating(x,1) = P(1,1);
                    seg = [ntbl(zeroPos(j):end,tempChangeCol:end)];
                    [upRes,minFitLength] = resolutionIncrease(seg);
                    heating{x,1} = upRes;
                    minFitLengthH(x,1) = minFitLength;
                else
                    segRate = [];
                    segRate = [ntbl(zeroPos(j):zeroPos(j+1)-1,2),...
                        ntbl(zeroPos(j):zeroPos(j+1)-1,tempChangeCol)];
                    P = polyfit(segRate(:,1),segRate(:,2),1);
                    ratesHeating(x,1) = P(1,1);
                    seg = [ntbl(zeroPos(j):zeroPos(j+1)-1,tempChangeCol:end)];
                    [upRes,minFitLength] = resolutionIncrease(seg);
                    heating{x,1} = upRes;
                    minFitLengthH(x,1) = minFitLength;
                end
            else
                fprintf(" Cooling Segment\n")
                y = y+1;
                if j == length(zeroPos)
                    segRate = [ntbl(zeroPos(j):end,2),ntbl(zeroPos(j):end,tempChangeCol)];
                    P = polyfit(segRate(:,1),segRate(:,2),1);
                    ratesCooling(y,1) = P(1,1);
                    seg = [ntbl(zeroPos(j):end,tempChangeCol:end)];
                    [upRes,minFitLength] = resolutionIncrease(seg);
                    cooling{y,1} = upRes;
                    minFitLengthC(y,1) = minFitLength;
                else
                    segRate = [ntbl(zeroPos(j):zeroPos(j+1)-1,2),...
                        ntbl(zeroPos(j):zeroPos(j+1)-1,tempChangeCol)];
                    P = polyfit(segRate(:,1),segRate(:,2),1);
                    ratesCooling(y,1) = P(1,1);
                    seg = [ntbl(zeroPos(j):zeroPos(j+1)-1,tempChangeCol:end)];
                    fprintf('')
                    [upRes,minFitLength] = resolutionIncrease(seg);
                    cooling{y,1} = upRes;
                    minFitLengthC(y,1) = minFitLength;
                end
            end
        end
        finalHeatingArray = zeros(length(heating),0);
        finalCoolingArray = zeros(length(cooling),0);
        for k = 1:length(heating)
            finalHeatingArray{k,1} = [heating{length(heating)-k+1}];
        end
        for l = 1:length(cooling)
            finalCoolingArray{l,1} = [cooling{length(cooling)-l+1}];
        end
        segHeating = finalHeatingArray;
        segCooling = finalCoolingArray;
    end
    function numSegs = numSegsDSC(fFN)
        taKeyWord = {'OrgMethod'};
        taKeyMethods = {'Ramp','Iso'};
        taKeyWordEnd = {'StartOfData'};
        pattern = 'Isothermal\s+for\s+(\d+\.\d+)\s+min';
        fid = fopen(fFN);
        tline = fgetl(fid);
        x = 0;
        while ischar(tline)
            if contains(tline,taKeyMethods{1})
                x = x+1;
            elseif contains(tline,taKeyMethods{2})
                matches = regexp(tline,pattern,'tokens');
                if str2double(matches{1})>1
                    x = x+1;
                end
            elseif contains(tline,taKeyWordEnd)
                break
            end
            tline = fgetl(fid);
        end
        fclose(fid);
        numSegs = x-1;
    end
    function [segHeating,segCooling,segIso,segModHeating,ratesHeating,ratesCooling,ratesModHeating,minFitLengthH,minFitLengthC,minFitLengthMH] = ...
            segDSC(data,numSegs,tempCol,hfCol,varargin)
        p = inputParser;
        p.addOptional('Modulated',false);
        p.addOptional('ModSig',NaN);
        p.addOptional('ModTemp',NaN);
        p.parse(varargin{:});
        pmod = p.Results.Modulated;
        modSig = p.Results.ModSig;
        modTemp = p.Results.ModTemp;
        ipts = findchangepts(data(:,2),"MaxNumChanges",numSegs,...
            'Statistic','linear');
        segHeating = [];
        segCooling = [];
        segModHeating = [];
        segIso = [];
        ratesHeating = [];
        ratesCooling = [];
        ratesModHeating = [];
        minFitLengthH = [];
        minFitLengthC = [];
        minFitLengthMH = [];
        x = 0; %heating counter
        y = 0; %cooling counter
        z = 0; %iso counter
        m = 0; %mod counter
        for i = 0:length(ipts)
            if i == 0
                startSegPoint = 1;
                endSegPoint = ipts(1)-1;
            elseif i == length(ipts)
                startSegPoint = ipts(i);
                endSegPoint = length(data);
            else
                startSegPoint = ipts(i);
                endSegPoint = ipts(i+1)-1;
            end
            slope = polyfit(data(startSegPoint:endSegPoint,1),...
                data(startSegPoint:endSegPoint,2),1);
            rslope = round(slope,1);
            if rslope(1) > 0
                modCheck = abs(sum(data(startSegPoint:endSegPoint,modSig)));
                if pmod && modCheck > 0
                    m = m+1;
                    seg = [data(startSegPoint:endSegPoint,tempCol),...
                        data(startSegPoint:endSegPoint,modSig)];
                    [upRes,minFitLength] = resolutionIncrease(seg);
                    segModHeating{m,1} = upRes;
                    minFitLengthMH(m,1) = minFitLength;
                    ratesModHeating(m,1) = slope(1)/60;
                else
                    x = x+1;
                    seg = [data(startSegPoint:endSegPoint,tempCol),...
                        data(startSegPoint:endSegPoint,hfCol)];
                    [upRes,minFitLength] = resolutionIncrease(seg);
                    segHeating{x,1} = upRes;
                    minFitLengthH(x,1) = minFitLength;
                    ratesHeating(x,1) = slope(1)/60;
                end
            elseif rslope(1) < 0
                y = y+1;
                seg = [data(startSegPoint:endSegPoint,tempCol),...
                    data(startSegPoint:endSegPoint,hfCol)];
                [upRes,minFitLength] = resolutionIncrease(seg);
                segCooling{y,1} = upRes;
                minFitLengthC(y,1) = minFitLength;
                ratesCooling(y,1) = slope(1)/60;
            elseif rslope(1) == 0
                z = z+1;
                seg = [data(startSegPoint:endSegPoint,tempCol),...
                    data(startSegPoint:endSegPoint,hfCol)];
                [upRes,~] = resolutionIncrease(seg);
                segIso{z,1} = upRes;
            end
        end
    end
    function scanType = dscScan(fFN)
        fid = fopen(fFN);
        tline = fgetl(fid);
        while ischar(tline)
            if contains(tline,'Modulated')
                scanType = 'Modulated';
                break
            end
            tline = fgetl(fid);
        end
        if ~exist('scanType','var')
            scanType = 'Standard';
        end
    end
    function [modSig, modTemp] = modSignal(fFN)
        fid = fopen(fFN);
        tline = fgetl(fid);
        keyWord = 'Rev Heat Flow';
        keyTemp = 'Modulated Temperature';
        pattern = 'Sig(\d+)';
        while ischar(tline)
            if contains(tline,keyWord)
                num = regexp(tline,pattern,'tokens','once');
                modSig = str2double(num);
            elseif contains(tline,keyTemp)
                num = regexp(tline,pattern,'tokens','once');
                modTemp = str2double(num);
            end
            tline = fgetl(fid);
        end
    end
    function modSeg = modSegments(data)
        x = 0;
        for i = 1:length(data)
            for j = 1:length(data(i).heating)
                modCheck = abs(sum(data(i).heating{i}(:,2)));
                if modCheck > 0
                    x = x+1;
                    modSeg(x) = i;
                end
            end
        end
    end


    function [timeCol,tempCol,hfCol] = sigsFSC(data)
        [~,width] = size(data);
        hfCol = width;
        timeCol = 2;
        tempCol = 3;
    end

    function [timeCol,tempCol,hfCol] = sigsDSC(fFN)
        fid = fopen(fFN);
        tline = fgetl(fid);
        keyTime = 'Time';
        keyTemp = 'Temperature';
        keySig = 'Sig';
        keyNotWanted = {'Modulated','Amplitude','Rev','Nonrev','Phase'};
        keyHeatFlow = 'Heat Flow';
        while ischar(tline)
            if contains(tline,keyTime) && contains(tline,keySig)
                numTime = regexp(tline,'Sig(\d+)','tokens','once');
                timeCol = str2double(numTime);
            elseif contains(tline,keyTemp) && ~contains(tline,keyNotWanted)
                numTemp = regexp(tline,'Sig(\d+)\s+Temperature \(.*\)','tokens','once');
                tempCol = str2double(numTemp);
            elseif contains(tline,keyHeatFlow) && ~contains(tline,keyNotWanted)
                numHF = regexp(tline,'Sig(\d+)\s+Heat Flow \(.*\)','tokens','once');
                hfCol = str2double(numHF);
            end
            tline = fgetl(fid);
        end
    end

    function data = singleFile(baseFileName,folder)
        fprintf('Importing: \n')
        fprintf(baseFileName)
        fprintf('\n')
        fFN = fullfile(folder,baseFileName);
        [~,bName] = fileparts(baseFileName);
        machineSource = parseFile(fFN);
        data.source = machineSource;
        data.file = fFN;
        detOpts = detectImportOptions(fFN);
        tbl = readtable(fFN,detOpts);
        if strcmp(data.source,'FSC File')
            ntbl = fscTable(tbl);
            [timeCol,tempCol,hfCol] = sigsFSC(ntbl);
            data.timeCol = timeCol;
            data.tempCol = tempCol;
            data.hfCol = hfCol;
            [segHeating,segCooling,ratesHeating,ratesCooling,minFitLengthH,minFitLengthC] = segFSC(ntbl);
            data.heating = segHeating;
            data.cooling = segCooling;
            data.minFitLengthH = minFitLengthH;
            data.minFitLengthC = minFitLengthC;
            data.ratesHeating = ratesHeating;
            data.ratesCooling = ratesCooling;
        end
        if ~exist('ntbl','var')
            ntbl = table2array(tbl);
        end
        data.data = ntbl;
        data.sampleName = strrep(bName,'_',' ');
        if strcmp(data.source,'TA QSeries')
            data.scanType = dscScan(fFN);
            [timeCol,tempCol,hfCol] = sigsDSC(fFN);
            data.timeCol = timeCol;
            data.tempCol = tempCol;
            data.hfCol = hfCol;
            data.mass = findMass(fFN);
            data.numSegs = numSegsDSC(fFN);
            if strcmp(data.scanType,'Modulated')
                [modSig,modTemp] = modSignal(fFN);
                data.modSig = modSig;
                data.modTemp = modTemp;
                [segHeating,segCooling,segIso,segModHeating,ratesHeating,ratesCooling,ratesModHeating,minFitLengthH,minFitLengthC,minFitLengthMH] = ...
                    segDSC(data.data,data.numSegs,tempCol,hfCol,'Modulated',true,'ModSig',modSig,'ModTemp',modTemp);
                data.heating = segHeating;
                data.cooling = segCooling;
                data.modHeating = segModHeating;
                data.ratesHeating = ratesHeating;
                data.ratesCooling = ratesCooling;
                data.ratesModHeating = ratesModHeating;
                data.minFitLengthH = minFitLengthH;
                data.minFitLengthC = minFitLengthC;
                data.minFitLengthMH = minFitLengthMH;
            else
                [segHeating,segCooling,segIso,~,ratesHeating,ratesCooling,~,minFitLengthH,minFitLengthC] = ...
                    segDSC(data.data,data.numSegs,tempCol,hfCol);
                data.heating = segHeating;
                data.cooling = segCooling;
                data.ratesHeating = ratesHeating;
                data.ratesCooling = ratesCooling;
                data.minFitLengthH = minFitLengthH;
                data.minFitLengthC = minFitLengthC;
            end
            data.iso = segIso;
        end
        fprintf('File Successfully Imported \n')
    end
    function data = multiFile(baseFileName,folder)
        for i = 1:length(baseFileName)
            fprintf('Importing: \n')
            fprintf(baseFileName{i})
            fprintf('\n')
            fFN = fullfile(folder,baseFileName{i});
            [~,bName] = fileparts(baseFileName{i});
            machineSource = parseFile(fFN);
            data(i).source = machineSource;
            data(i).file = bName;
            data(i).sampleName = strrep(bName,'_',' ');
            detOpts = detectImportOptions(fFN);
            tbl = readtable(fFN,detOpts);
            if strcmp(data(i).source,'FSC File')
                ntbl = fscTable(tbl);
                data(i).data = ntbl;
                [timeCol,tempCol,hfCol] = sigsFSC(ntbl);
                data(i).timeCol = timeCol;
                data(i).tempCol = tempCol;
                data(i).hfCol = hfCol;
                [segHeating,segCooling,ratesHeating,ratesCooling,minFitLengthH,minFitLengthC] = segFSC(ntbl);
                data(i).heating = segHeating;
                data(i).cooling = segCooling;
                data(i).minFitLengthH = minFitLengthH;
                data(i).minFitLengthC = minFitLengthC;
                data(i).ratesHeating = ratesHeating;
                data(i).ratesCooling = ratesCooling;
            end
            if ~exist('ntbl','var')
                ntbl = table2array(tbl);
                data(i).data = ntbl;
            end
            
            if strcmp(data(i).source,'TA QSeries')
                data(i).scanType = dscScan(fFN);
                [timeCol,tempCol,hfCol] = sigsDSC(fFN);
                data(i).timeCol = timeCol;
                data(i).tempCol = tempCol;
                data(i).hfCol = hfCol;
                data(i).mass = findMass(fFN);
                data(i).numSegs = numSegsDSC(fFN);
                if strcmp(data(i).scanType,'Modulated')
                    [modSig,modTemp] = modSignal(fFN);
                    data(i).modSig = modSig;
                    data(i).modTemp = modTemp;
                    [segHeating,segCooling,segIso,segModHeating,ratesHeating,ratesCooling,ratesModHeating,minFitLengthH,minFitLengthC,minFitLengthMH] = ...
                        segDSC(data(i).data,data(i).numSegs,tempCol,hfCol,'Modulated',true,'ModSig',modSig,'ModTemp',modTemp);
                    data(i).heating = segHeating;
                    data(i).cooling = segCooling;
                    data(i).modHeating = segModHeating;
                    data(i).ratesHeating = ratesHeating;
                    data(i).ratesCooling = ratesCooling;
                    data(i).ratesModHeating = ratesModHeating;
                    data(i).minFitLengthH = minFitLengthH;
                    data(i).minFitLengthC = minFitLengthC;
                    data(i).minFitLengthMH = minFitLengthMH;
                else
                    [segHeating,segCooling,segIso,~,ratesHeating,ratesCooling,~,minFitLengthH,minFitLengthC] = ...
                        segDSC(data.data,data.numSegs,tempCol,hfCol);
                    data(i).heating = segHeating;
                    data(i).cooling = segCooling;
                    data(i).ratesHeating = ratesHeating;
                    data(i).ratesCooling = ratesCooling;
                    data(i).minFitLengthH = minFitLengthH;
                    data(i).minFitLengthC = minFitLengthC;
                end
                data(i).iso = segIso;
            end
            fprintf('File Successfully Imported \n \n')
            clear('ntbl');
        end
    end
end

