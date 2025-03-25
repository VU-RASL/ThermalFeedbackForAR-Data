function data = processPassThroughData()

    file = dir('**/PassThroughData.csv');
    filepath = [file.folder '\' file.name];

    opts = detectImportOptions(filepath);
    opts = setvartype(opts, {'double', 'logical', 'logical',...
        'logical', 'logical', 'logical', 'logical', 'logical', 'logical',...
        'logical', 'logical', 'logical', 'logical', 'double'});
    
    q = readtable(filepath, opts);
    N = size(q,1);

    c = table;
    c.warm = repelem("Warm",N)';
    c.cool = repelem("Cool",N)';
    c.rv = repelem("RV",N)';
    c.lr = repelem("LR",N)';
    c.d0= repelem("0C",N)';
    c.d1 = repelem("5C",N)';
    c.d2 = repelem("10C",N)';
    p = q.Participant;

    d = table;
    d.Response = [q.WarmDiff_1;q.WarmDiff_2; q.WarmRVSimilar;...
                    q.WarmLRSimilar; q.WarmLRDif_1; q.WarmLRDif_2;...
                    q.CoolDiff_1; q.CoolDiff_2; q.CoolRVSimilar;...
                    q.CoolLRSimilar; q.CoolLRDif_1; q.CoolLRDif_2];
    d.WvC = [repmat(c.warm,[6,1]);repmat(c.cool,[6,1])];
    d.RVvLR = [repmat(c.rv,[3,1]);repmat(c.lr,[3,1]);...
                 repmat(c.rv,[3,1]);repmat(c.lr,[3,1])];
    d.Delta = [c.d1; c.d2; c.d0; c.d0; c.d1; c.d2;...
                  c.d1; c.d2; c.d0; c.d0; c.d1; c.d2];
    d.Subject = repmat(p,[12,1]);
    
    d.WvC = categorical(d.WvC, {'Cool','Warm'});
    d.RVvLR = categorical(d.RVvLR, {'LR', 'RV'});
    d.Delta = categorical(d.Delta, {'0C', '5C', '10C'});
    d.Subject = categorical(d.Subject);

    formula = 'Response ~ WvC*RVvLR + (Delta|Subject)';
    
    data.glme = fitglme(d, formula,...
                'Distribution', 'Binomial',...
                'Link', 'Logit',...
                'DummyVarCoding', 'effects');
    data.raw = d;

    data.anova = anova(data.glme);

    iRVW = strcmp(data.glme.Coefficients.Name, '(Intercept)');
    iLRW = strcmp(data.glme.Coefficients.Name, 'RVvLR_LR');
    iRVC = strcmp(data.glme.Coefficients.Name, 'WvC_Cool');
    iLRC = strcmp(data.glme.Coefficients.Name, 'WvC_Cool:RVvLR_LR');

    % base level RV and Warm
    inter = data.glme.Coefficients.Estimate(iRVW);
    intL = data.glme.Coefficients.Lower(iRVW);
    intH = data.glme.Coefficients.Upper(iRVW);
    ci = [intL, intH];
    data.RVW.accuracy = exp(inter) / (1 + exp(inter));
    data.RVW.beta = inter;
    data.RVW.betaci = [data.glme.Coefficients.Lower(iRVW), data.glme.Coefficients.Upper(iRVW)];
    data.RVW.ci = exp(ci) ./ (1+exp(ci));
    data.RVW.p = data.glme.Coefficients.pValue(iRVW);
    

    % LR as compared to RV (LR+Warm vs RV+Warm)
    lr = inter + data.glme.Coefficients.Estimate(iLRW);
    lrL = intL + data.glme.Coefficients.Lower(iLRW);
    lrH = intH + data.glme.Coefficients.Upper(iLRW);
    ci = [lrL, lrH];
    data.LRW.beta = lr - inter;
    data.LRW.betaci = [data.glme.Coefficients.Lower(iLRW), data.glme.Coefficients.Upper(iLRW)];
    data.LRW.base = data.RVW.accuracy;
    data.LRW.accuracy = exp(lr) / (1 + exp(lr));
    data.LRW.ci = exp(ci) ./ (1+exp(ci));
    data.LRW.p = data.glme.Coefficients.pValue(iLRW);
    

    % Cool as compared to Warm (RV+Cool vs RV+Warm)
    cool = inter + data.glme.Coefficients.Estimate(iRVC);
    cL = intL + data.glme.Coefficients.Lower(iRVC);
    cH = intH + data.glme.Coefficients.Upper(iRVC);
    ci = [cL, cH];
    data.RVC.beta = cool - inter;
    data.RVC.betaci = [data.glme.Coefficients.Lower(iRVC), data.glme.Coefficients.Upper(iRVC)];
    data.RVC.base = data.RVW.accuracy;
    data.RVC.accuracy = exp(cool) / (1 + exp(cool));
    data.RVC.ci = exp(ci) ./ (1+exp(ci));
    data.RVC.p = data.glme.Coefficients.pValue(iRVC);

    % Interaction effects (LR+Cool vs RV+Warm)
    % lr and cool both have inter added in so remove one
    lrc = -inter + lr + cool + data.glme.Coefficients.Estimate(iLRC);
    lrcL = -intL + lrL + cL + data.glme.Coefficients.Lower(iLRC);
    lrcH = -intH + lrH + cH + data.glme.Coefficients.Upper(iLRC);
    ci = [lrcL, lrcH];
    data.LRC.beta = data.glme.Coefficients.Estimate(iLRC);
    data.LRC.betaci = [data.glme.Coefficients.Lower(iLRC), data.glme.Coefficients.Upper(iLRC)];
    data.LRC.base = data.RVW.accuracy;
    data.LRC.accuracy = exp(lrc) / (1 + exp(lrc));
    data.LRC.ci = exp(ci) ./ (1+exp(ci));
    data.LRC.p = data.glme.Coefficients.pValue(iLRC);

    % create summary table
    stats = table;
    stats.Condition = ["RVW"; "LRW"; "RVC"; "LRC"];
    stats.Accuracy = [data.RVW.accuracy; data.LRW.accuracy; data.RVC.accuracy; data.LRC.accuracy] * 100;
    stats.CI = [data.RVW.ci; data.LRW.ci; data.RVC.ci; data.LRC.ci]*100;
    stats.Beta = [data.RVW.beta; data.LRW.beta; data.RVC.beta; data.LRC.beta];
    stats.BetaCI = [data.RVW.betaci; data.LRW.betaci; data.RVC.betaci; data.LRC.betaci];
    stats.P = [data.RVW.p; data.LRW.p; data.RVC.p; data.LRC.p];
    data.stats = stats;

    data.Realism.Score = mean(q.Realism);
    data.Realism.p = signrank(q.Realism,4);
    
end