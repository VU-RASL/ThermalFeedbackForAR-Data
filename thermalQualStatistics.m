function data = thermalQualStatistics()

    data = processQualitativeLogsThermal();

    [p, h, stats] = signrank(data.q1.w, data.q1.wo);

    data.q1.p = p;
    data.q1.h = h;
    data.q1.V = stats.signedrank;

    [p, h, stats] = signrank(data.q2.w, data.q2.wo);

    data.q2.p = p;
    data.q2.h = h;
    data.q2.V = stats.signedrank;

    data.q3.p = binopdf(sum(data.q3.preference==2)+sum(data.q3.preference==1), length(data.q3.preference), 0.5);

    [p, h, stats] = signrank(data.q4.realism - 4);
    
    data.q4.p = p;
    data.q4.h = h;
    data.q4.V = stats.signedrank;
    
end
