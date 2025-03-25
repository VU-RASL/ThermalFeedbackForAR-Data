function data = processThermalThresholds()
    
    lw = 2;
    fontsize = 17;
    ymax = 10;

    data.lineWarm = processThermalFiles('4_Line');
    data.allWarm = processThermalFiles('4_All');
    data.lineCool = processThermalFiles('-4_Line');
    data.allCool = processThermalFiles('-4_All');
    
    t = tiledlayout(2,2);
    txt = title(t,'Thermal Device JND Results');
    txt.FontSize = fontsize;

    nexttile;
    errorbar(1:data.lineWarm.N,data.lineWarm.avg,data.lineWarm.CI(2,:)-data.lineWarm.avg, 'o','LineWidth', lw);
    hold on;
    errorbar(data.lineWarm.N+1,data.lineWarm.overallAvg, data.lineWarm.overallCI(2)-data.lineWarm.overallAvg, 'o','LineWidth', lw);
    xlim(gca,[0,data.lineWarm.N+2]);
    ylim(gca,[0,ymax]);
    set(gca,'xtick',[mean([1,data.lineWarm.N]),data.lineWarm.N+1], 'xticklabels', {'Participants', 'Mean'});
    title("LineWarm");
    box off;
    set(gcf,'color', 'w');
    set(gca, 'YGrid', 'on', 'XGrid', 'off');
    set(gca,'YTick',0:1:ymax);
    set(gca,'yticklabels', {'0', '', '2', '', '4', '', '6', '', '8', '', '10'});
    ylabel('Degrees (C)');
    ax = gca;
    ax.FontSize = fontsize;
    
    nexttile;
    errorbar(1:data.lineCool.N,data.lineCool.avg,data.lineCool.CI(2,:)-data.lineCool.avg, 'o','LineWidth', lw);
    hold on;
    errorbar(data.lineCool.N+1,data.lineCool.overallAvg, data.lineCool.overallCI(2)-data.lineCool.overallAvg, 'o','LineWidth', lw);
    xlim(gca,[0,data.lineCool.N+2]);
    ylim(gca,[0,ymax]);
    set(gca,'xtick',[mean([1,data.lineCool.N]),data.lineCool.N+1], 'xticklabels', {'Participants', 'Mean'});
    title("LineCool");
    box off;
    set(gcf,'color', 'w');
    set(gca, 'YGrid', 'on', 'XGrid', 'off');
    set(gca,'YTick',0:1:ymax);
    set(gca,'yticklabels', {'0', '', '2', '', '4', '', '6', '', '8', '', '10'});
    ylabel('Degrees (C)');
    ax = gca;
    ax.FontSize = fontsize;
    
    nexttile;
    errorbar(1:data.allWarm.N,data.allWarm.avg,data.allWarm.CI(2,:)-data.allWarm.avg, 'o','LineWidth', lw);
    hold on;
    errorbar(data.allWarm.N+1,data.allWarm.overallAvg, data.allWarm.overallCI(2)-data.allWarm.overallAvg, 'o','LineWidth', lw);
    xlim(gca,[0,data.allWarm.N+2]);
    ylim(gca,[0,ymax]);
    set(gca,'xtick',[mean([1,data.allWarm.N]),data.allWarm.N+1], 'xticklabels', {'Participants', 'Mean'});
    title("AllWarm");
    box off;
    set(gcf,'color', 'w');
    set(gca, 'YGrid', 'on', 'XGrid', 'off');
    set(gca,'YTick',0:1:ymax);
    set(gca,'yticklabels', {'0', '', '2', '', '4', '', '6', '', '8', '', '10'});
    ylabel('Degrees (C)');
    ax = gca;
    ax.FontSize = fontsize;
    
    nexttile;
    errorbar(1:data.allCool.N,data.allCool.avg,data.allCool.CI(2,:)-data.allCool.avg, 'o','LineWidth', lw);
    hold on;
    errorbar(data.allCool.N+1,data.allCool.overallAvg, data.allCool.overallCI(2)-data.allCool.overallAvg, 'o','LineWidth', lw);
    xlim(gca,[0,data.allCool.N+2]);
    ylim(gca,[0,ymax]);
    set(gca,'xtick',[mean([1,data.allCool.N]),data.allCool.N+1], 'xticklabels', {'Participants', 'Mean'});
    title("AllCool");
    box off;
    set(gcf,'color', 'w');
    set(gca, 'YGrid', 'on', 'XGrid', 'off');
    set(gca,'YTick',0:1:ymax);
    set(gca,'yticklabels', {'0', '', '2', '', '4', '', '6', '', '8', '', '10'});
    ylabel('Degrees (C)');
    ax = gca;
    ax.FontSize = fontsize;
end

function q = processThermalFiles(filename)
    filenames = {dir(['**\*_',filename,'*.json']).name};
    filefolders = {dir(['**\*_',filename,'*.json']).folder};
    
    N = length(filenames);
    reversals = NaN(8,N);
    CI = NaN(2,N);
    avg = NaN(1,N);
    
    for j=1:length(filenames)
        filename = [filefolders{j}, '\', filenames{j}];
        fid = fopen(filename);
        raw = fread(fid,inf);
        str = char(raw');
        fclose(fid);
        vals = jsondecode(str);
        x = length(vals);
        if(x < 8)
            reversals(1:x,j) = vals;
        else
            reversals(:,j) = vals(end-7:end);
        end
        pd = fitdist(reversals(:,j),'Normal');
        avg(j) = pd.mu;
        ci = paramci(pd);
        CI(:,j) = ci(:,1);
    end
    
    x = reshape(reversals, 8*N,1);
    pd = fitdist(x,'Normal');
    ci = paramci(pd);
    q.N = N;
    q.reversals = reversals;
    q.CI = CI;
    q.avg = avg;
    q.overallAvg = pd.mu;
    q.overallCI = ci(:,1);
end