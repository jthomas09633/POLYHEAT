function result = twoPhaseAnalysis(localSegment,min_fit_length)
%TWOPHASEANALYSIS
%   This function takes in the local segment of a known 2-phase system
%   containg 1 glass transition and one crystal melt

% iniitializing the result
    result = struct('solidStateBaseline',[],...
        'startOfTg',[],...
        'endOfTg',[],...
        'semiSolidBaseline',[],...
        'liquidStateBaseline',[],...
        'tanhBaseline',[],...
        'fictiveTemp',[],...
        'deltaCp',[],...
        'meltTemp',[],...
        'heatOfFusionTotal',[],...
        'heatOfFusionFirstContact',[],...
        'heatOfFusionSecondary',[],...
        'orgIndex',[]);
    
    % preparing the data, computing the first and second derivatives, and the
    % melt peak position
    [melt_peak,first_der,sec_der] = prep2PhaseData(localSegment);
    result.meltTemp = localSegment(melt_peak.peakPos,1);
    melt_peak.peakPos
    % finding the peak positions of the first and second derivatives that are
    % significantly gearter than the noise level
    [localSegment_peaks_int,fder_peaks_int,sec_der_peaks_int] = ...
        peakFinder(localSegment,first_der,sec_der);
    
    % fits data from the start of the data growing toward the melt peak, will
    % pass through the glass transition
    solid_state_SOD = fitsStartOfData(localSegment,min_fit_length,sec_der_peaks_int);
    whos("solid_state_SOD")
    % finding the end of the glass transition which is the start of the rubbery
    % or semi-solid state, this will also return the best solid state baseline
    [best_solid_state_fit,rubbery_state_start] = endOfSSPoint(min_fit_length,solid_state_SOD);
    
    % first set of results, solid state baseline, start of Tg and end of Tg
    result.solidStateBaseline = best_solid_state_fit.bestFitParam;
    result.startOfTg = localSegment(best_solid_state_fit.length,1);
    result.endOfTg = localSegment(rubbery_state_start,1);
    
    % now initializing the liquid state fits
    liquid_state_eod = finalLiquidStateFit(localSegment,min_fit_length,sec_der_peaks_int);
    
    % trimming bad liquid state fits
    trimmed_liquid_state = trimLiquid(liquid_state_eod);
    clear('liquid_state_eod'); % no longer needed
    
    % doing this process again but from the end of the glass transition going
    % towards the melt peak
    rubbery_state_eot = rubberyStateBaseline(localSegment,min_fit_length,rubbery_state_start,sec_der_peaks_int);
    
    % trimming bad rubbery/semi-solid state fits
    trimmed_rubbery_state = trimRubbery(rubbery_state_eot);
    clear('rubbery_state_eot'); %no longer needed
    
    % creating the fits from the perspective of the liquid state finding the
    % ideal rubbery/semi-solid state (Li2Ru is Liquid to Rubbery)
    full_melt_fits_Li2Ru = peakFitFromLiquidToRubbery(localSegment,...
        trimmed_rubbery_state,trimmed_liquid_state,sec_der_peaks_int);
    
    % creating the fir from the perspective of the rubbery state finding the
    % ideal liquid state (Ru2Li is Rubbery to Liquid)
    full_melt_fitsRu2Li = peakFitFromRubberyToLiquid(localSegment,...
        trimmed_rubbery_state,trimmed_liquid_state,sec_der_peaks_int);
    
    % finding the best baseline based on the results from full melts
    [best_baseline,best_rubbery_fit,best_liquid_fit] = bestBaseline(localSegment,...
        trimmed_rubbery_state,trimmed_liquid_state,...
        full_melt_fits_Li2Ru,full_melt_fitsRu2Li,sec_der_peaks_int);
    
    result.semiSolidBaseline = trimmed_rubbery_state(best_rubbery_fit).short;
    result.liquidStateBaseline = trimmed_liquid_state(best_liquid_fit).short;
    result.tanhBaseline = best_baseline;
    
    
    
    % calculating the heat of fusion of the crystal melt
    [heat_of_fusion_total,heat_of_fusion_first_contact,heat_of_fusion_secondary] = ...
        heatOfFusion(localSegment,best_baseline,sec_der_peaks_int);
    result.heatOfFusionTotal = heat_of_fusion_total;
    result.heatOfFusionFirstContact = heat_of_fusion_first_contact;
    result.heatOfFusionSecondary = heat_of_fusion_secondary;
    
    solid_state_end = result.startOfTg;
    rubbery_state_start = result.endOfTg;
    best_solid_state = best_solid_state_fit.baseline;
    best_rubbery_state = trimmed_rubbery_state(best_rubbery_fit).short;
    clear('trimmed_liquid_state','trimmed_rubbery_state')
    [fictive_temp,deltaCp] = fictiveTemp(localSegment,solid_state_end,...
        rubbery_state_start,best_solid_state,best_rubbery_state);
    result.fictiveTemp = fictive_temp;
    result.deltaCp = deltaCp;
end

