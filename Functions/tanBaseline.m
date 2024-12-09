function ytanhData = tanBaseline(xtanhdata,slopeLeft,yIntLeft,slopeRight,yIntRight,critVal,width)
%TANBASELINE tanBaseline takes in the the xtanhdata (full temperature span
%from start of rubbery/semi-solid state to end of liquid state, the
%properties of the linear fits from the left (entry) and right (exit) and
%the width of the inflection and the mid point.
    ytanhData = zeros(length(xtanhdata),1);    
    for i = 1:length(xtanhdata)
        g(i,1) = xtanhdata(i)*slopeRight+yIntRight;
        h(i,1) = xtanhdata(i)*slopeLeft+yIntLeft;
        s = 0.5+0.5*tanh((xtanhdata(i)-critVal)/width);
        ytanhData(i,1) = s*(h(i,1))+(1-s)*g(i,1);
    end
end

