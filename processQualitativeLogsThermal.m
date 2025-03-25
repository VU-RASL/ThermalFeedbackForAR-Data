function [data] = processQualitativeLogsThermal()
    
    filename = {dir(['**\','ThermalQualitative','.csv']).name};
    filefolder = {dir(['**\','ThermalQualitative','.csv']).folder};
    filename = [filefolder{1}, '\', filename{1}];
    
    bootfun = @(x) mean(x);
    
    q = readtable(filename);
    q = table2array(q);
    q1.wo= q(:,1);
    q1.woMean = mean(q1.wo);
    q1.woCI = bootci(75,bootfun,q1.wo);
    q1.w = q(:,2);
    q1.wMean = mean(q1.w);
    q1.wCI = bootci(75,bootfun,q1.w);
    q1.groupNames = {'Without', 'With'};
    
    q2.wo = q(:,3);
    q2.woMean = mean(q2.wo);
    q2.woCI = bootci(75,bootfun,q2.wo);
    q2.w = q(:,4);
    q2.wMean = mean(q2.w);
    q2.wCI = bootci(75,bootfun,q2.w);
    
    q2.groupNames = {'Without', 'With'};
    
    q4.realism = q(:,5);
    q4.mean = mean(q4.realism);
    q4.ci = bootci(75,bootfun,q4.realism);
    
    q3.preference = q(:,6);
    
    data.q1 = q1;
    data.q2 = q2;
    data.q3 = q3;
    data.q4 = q4;

end