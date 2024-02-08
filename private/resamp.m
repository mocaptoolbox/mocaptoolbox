function d2 = resamp(d1,freq,newfreq,method)
    t1 = (0:(size(d1,1)-1))/freq;
    t2 = 0:(1/newfreq):t1(end);
    d2 = interp1(t1, d1, t2, method);
end
