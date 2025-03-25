function data = processThermalSpatial()
    data.warm = processThermalFiles('Warm');
    data.cool= processThermalFiles('Cool');
    
end

function q = processThermalFiles(filename)
    filenames = {dir(['**\Spatial_',filename,'*.csv']).name};
    filefolders = {dir(['**\Spatial_',filename,'*.csv']).folder};
    
    N = length(filenames);
    q.data = zeros(6,6,N);
    q.matrix = zeros(6,6);
    q.CI = zeros(6,6,2);
    
    for j=1:N
        filename = [filefolders{j}, '\', filenames{j}];
        tbl = readtable(filename);
        q.data(:,:,j) = table2array(tbl);
    end
    xs = 0;
    xn = 0;
    for i=1:5
        for j=i+1:6
            [phat, pci] = binofit(sum(q.data(i,j,:)),N);
            q.matrix(i,j) = phat;
            q.CI(i,j,:) = pci;
            xs = xs + sum(q.data(i,j,:));
            xn = xn + 1;
        end
    end
    [phat, pci] = binofit(xs,xn*N);
    q.mean = phat;
    q.meanci = pci;
    q.N = N;    
end