function [tgResult,params,yValsFit] = tgSearch(localSegment)
%TGSEARCH fits the tanh function for to see which case the data falls under
%       function to fit:
%           f(T) = (0.5 + 0.5*tanh((T-Tmax)/-w))*a*T+b + 
%                           (1-(0.5+0.5*tanh((T-Tmax)/-w)))*c*T+d
%
%               Tmax        - Peak of first derivative
%               a           - Entry slope
%               b           - Entry y-int
%               c           - Exit slope
%               d           - Exit y-int
%
%
%   Three checks:   1) high r^2 (> 0.9)
%                   2) y-ints signficantly different (implies step height)   
%                   3) y-ints must be the same sign (either + or -)
%
%   Case 1: No event, fails on 1 check
%           Case 1A) High r^2, abs(b-d)~=0, a and c both + or -
%                   Fails Check 2
%           Case 1B) High r^2, abs(b-d) >> 0, a and c not same sign
%                   Fails Check 3
%
%   Case 2: Tg only, passes all 3 checks
%
%   Case 3: More complex (not just a Tg, maybe multiple, maybe melt, cold
%   crystalization, maybe a random amount of each), fails 2 checks
%           Will typically fail check 1 and check 3 (by extension this mean
%           you pass check 2 implicitly when you fail check 3)
%
%************************************************************************%
    xvals = localSegment(:,1);
    yvals = sgolayfilt(localSegment(:,2),1,11);
    derYvals = gradient(yvals)./gradient(xvals);
    [~,maxLoc] = max(derYvals);
    maxT = xvals(maxLoc,1);
    customFunc = @(params,x) ...
        (0.5 +0.5*tanh((x-maxT)/-params(1))).*(params(2)*x+params(3))+...
        (1-(0.5+0.5*tanh((x-maxT)/-params(1)))).*(params(4)*x+params(5));
    
    initialGuess = [5,1,1,1,1];
    lb = [-Inf,-Inf,-Inf,-Inf,-Inf];
    ub = [Inf,Inf,Inf,Inf,Inf];
    options = optimoptions('lsqcurvefit', 'Display', 'off');
    [params,resnormFit] = lsqcurvefit(customFunc,initialGuess,xvals,yvals,lb,ub,options);
    tgFit = @(x) customFunc(params,x);
    yValsFit = tgFit(xvals);
    residualManual = yvals-yValsFit;
    SSR = sum(residualManual.^2); % total sum of residuals
    SST = sum((yvals-mean(yvals)).^2);
    rsqrd = 1-(SSR/SST);
        function direction = isPositive(value)
            if value < 0
                direction = false;
            else
                direction = true;
            end
        end
    if rsqrd > 0.95 && abs(log10(params(5))-log10(params(3))) > 0.09 && isPositive(params(2)) == isPositive(params(4))
        tgResult = 1;
    elseif rsqrd > 0.95
        %error('No Event Detected')
        tgResult = -1;
    else
        tgResult = 0;
    end
end