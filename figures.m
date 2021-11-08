clear

filename = 'data_descriptive.xlsx';
[~,name] = xlsread(filename, 'B2:B68');
id = xlsread(filename, 'A2:A68');

%catname = zeros(length(id), 1);

for i = 1:length(id)
    idstr = num2str(id(i));
    if length(idstr) == 1
        idstr = ['0' idstr];
    end
    namei = name{i};
    catname{i} = [idstr, ' ', namei];
end

[~, sheetname] = xlsfinfo(filename);

startdate = datenum('2018-10-08');
enddate = datenum('2021-10-08');
dateseries = startdate:enddate;
datestrseries = datestr(dateseries);
load('data1.mat');
%% s2
%cd 'C:\Users\Admin\Desktop';
[~,graphname] = xlsread('order.xlsx', 'A1:A16');
graphcontent = xlsread('order.xlsx', 'B1:H16');
for g = 1:length(graphname)
    tic
    scale = graphcontent(g, :);
    scale = scale(~isnan(scale));
    %cd 'C:\Users\Admin\Desktop';
    close
    DisplayName = [];
    for j = 1:length(scale) %4:length(sheetname)
        i = scale(j) + 4;
        %sheetname = catname{i};
        sheetnamei = sheetname{i};
        data = readtable(filename, 'Sheet', sheetname{i});
        start = find(~isnan(data{:,5}));
        validdate = data{start:end, 1};
        validdata = data{start:end, 5};
        %validdata(:,1) = validdata(:,1) + 693960;
        figure(1)
        %line([0 1000000],[100 100]);
        DisplayName = [DisplayName, string(name{i-3})];
        hold on
        plot(validdate, validdata);
        datetick('x', 'yyyy-mm', 'keepticks');
    end
    hold off
    %cd 'figures_withlegend';
    legend(DisplayName,'Location','northwest');
    title(graphname{g});
    print(graphname{g}, '-djpeg');
    tt = toc;
end