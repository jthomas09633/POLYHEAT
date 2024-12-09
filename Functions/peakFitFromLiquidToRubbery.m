function fullMeltFits = peakFitFromLiquidToRubbery(data,rsTrimmed,lsTrimmed,sdPeaksInt)
%PEAKFITFROMLIQUIDTORUBBERY Summary of this function goes here
%   Detailed explanation goes here
    tic    
    funcData = data;
    
    [~,peakIndex] = max(funcData(:,2));
    critVal = funcData(peakIndex,1);
    width = -(funcData(sdPeaksInt(2,2),1)-funcData(sdPeaksInt(1,2),1))/2;
    loopLength = length(lsTrimmed);
    fullMeltFits = [];
    f = griddedInterpolant(funcData(:,1),funcData(:,2));
    F = @(t) f(t);
    x = 0;
    left_peak_temp = funcData(sdPeaksInt(1,2),1);
    right_peak_temp = funcData(sdPeaksInt(end,2),1);
    left_peak_pos = sdPeaksInt(1,2);
    right_peak_pos = sdPeaksInt(end,2);
    parfor i = 1:loopLength
        fprintf('Starting Fit Set '+string(i)+'/'+string(loopLength)+'---- \n')
        fullmeltArea = zeros(length(rsTrimmed),1);
        specific_area = zeros(length(rsTrimmed),1);
        startEndTemps = zeros(length(rsTrimmed),2);
        slopeRight = lsTrimmed(i).polyFit(1,1);
        yIntRight = lsTrimmed(i).polyFit(1,2);
        tanhBaselines = [];
        endPoint = lsTrimmed(i).short(end,1);
        for j = 1:length(rsTrimmed)
            slopeLeft = rsTrimmed(j).slope(1,1);
            yIntLeft = rsTrimmed(j).slope(1,2);
            startPoint = rsTrimmed(j).short(1,1);
            xtanhData = linspace(startPoint,endPoint,1000)';
            ytanhData = tanBaseline(xtanhData,slopeLeft,yIntLeft,slopeRight,yIntRight,critVal,width);
            tanhBaseline = [xtanhData,ytanhData];
            tanhBaselines{j} = tanhBaseline;
            g = griddedInterpolant(tanhBaseline(:,1),tanhBaseline(:,2));
            G = @(t) g(t);
            fulltanhArea = integral(G,tanhBaseline(1,1),tanhBaseline(end,1));
            fulldataArea = integral(F,startPoint,endPoint);
            fullmeltArea(j) = fulldataArea-fulltanhArea;
            specific_area_xvals = linspace(startPoint,endPoint,10000)';
            [~,start_loc] = min(abs(funcData(:,1)-startPoint));
            [~,end_loc] = min(abs(funcData(:,1)-endPoint));
            specific_data_yvals = interp1(funcData(start_loc:end_loc,1),funcData(start_loc:end_loc,2),specific_area_xvals,'linear');
            specific_baseline_yvals = interp1(tanhBaseline(:,1),tanhBaseline(:,2),specific_area_xvals,'linear');
            diff = specific_data_yvals-specific_baseline_yvals;
            [~,firstPeakPos] = min(abs(specific_area_xvals(:,1)-left_peak_temp));
            [~,secondPeakPos] = min(abs(specific_area_xvals(:,1)-right_peak_temp));
            for k = firstPeakPos:-1:1
                if diff(k) <= 10^(floor(log10(G(critVal)))-6)
                    meltStart = k;
                    break
                end
            end
            for m = secondPeakPos:length(diff)
                if diff(m) <= 10^(floor(log10(G(critVal)))-6)
                    meltEnd = m;
                    break
                end
            end
            % mag = 10^(floor(log10(G(critVal)))-4);
            % zero_crossings = find(abs(diff(1:end-1).*diff(2:end)) <= mag);
            % [~,firstPeakPos] = min(abs(specific_area_xvals(:,1)-left_peak_temp));
            % [~,secondPeakPos] = min(abs(specific_area_xvals(:,1)-right_peak_temp));
            % meltStart = find(zero_crossings < firstPeakPos,1,'last');
            % meltEnd = find(zero_crossings > secondPeakPos,1,'first');
            specific_temp_start = specific_area_xvals(meltStart,1);
            specific_temp_end = specific_area_xvals(meltEnd,1);
            specific_data_int = integral(F,specific_temp_start,specific_temp_end);
            specific_baseline_int = integral(G,specific_temp_start,specific_temp_end);
            specific_area(j) = specific_data_int-specific_baseline_int;
            startEndTemps(j,1) = specific_area_xvals(meltStart,1);
            startEndTemps(j,2) = specific_area_xvals(meltEnd,1);
        end

        [midNormAreaFull,midNormAreaFullLoc] = midMeltArea(fullmeltArea);
        [midNormAreaSpecific,midNormAreaSpecificLoc] = midMeltArea(specific_area);
        fullMeltFits(i).bestFullFitIndex = midNormAreaFullLoc;
        fullMeltFits(i).bestFullArea = midNormAreaFull;
        fullMeltFits(i).specificArea = specific_area;
        fullMeltFits(i).bestSpecMatchRubbery = rsTrimmed(midNormAreaSpecificLoc).short;
        fullMeltFits(i).bestSpecFitIndex = midNormAreaSpecificLoc;
        fullMeltFits(i).bestSpecArea = midNormAreaSpecific;
        fullMeltFits(i).bestSpecMatchRubbery = rsTrimmed(midNormAreaSpecificLoc).short;
        fullMeltFits(i).specificMeltTemps = startEndTemps;
        fprintf('----Fit Set '+string(i)+': Completed ---- \n')
    end
    toc
end