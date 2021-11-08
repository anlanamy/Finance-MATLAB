% 重新搞一个策略，先随便弄一个随机数买卖
%在DB结构体当中，每个标的都是一个以SH123456形式命名的struct，因此用getfield可以取出来
%输出的signal{i}代表每个标的的处理情况，在这里只给买进或者卖出
function Signal = Strategy_3(Asset,HisDB,windcode)
Signal = [];
for i = 1:length(windcode)
    %调出struct的名字
    namei = windcode{i};
    index = strfind(namei, '.');
    PreName = namei(1:index-1);
    AfterName = namei(index+1:end);
    namecat = [AfterName, PreName];
    db = getfield(HisDB, namecat);
    if length(db.Close) == 1
        return
    end
    %if length(db.Close)>=6 && db.Close(end) < mean(db.Close(1:end))
    if db.Close(end) < mean(db.Close(1:end))
        Signal{i}.Stock = db.Code;
        Signal{i}.Type = 'TodayClose';
        Signal{i}.Volume=0;
        for j = 1:length(Asset.CurrentPosition)
            if isequal(Asset.CurrentStock{j},namei)
                %Signal{i}.Volume = -Asset.CurrentPosition(j);
                Signal{i}.Volume = -Asset.CurrentPosition(j)/2;
                break
            end
        end
%          Signal{i}.Volume = -500;
    else
        Signal{i}.Stock = db.Code;
        Signal{i}.Type = 'TodayClose';
%        Signal{i}.Volume=0;
        if length(db.Close)~=1
            Signal{i}.Volume = Asset.Cash(length(db.Close)-1)/(2*db.Close(end));
        else
            Signal{i}.Volume = Asset.InitCash/(2*db.Close(end));
        end
%        for j = 1:length(Asset.CurrentPosition)
%             if isequal(Asset.CurrentStock{j},namei)
%                 %Signal{i}.Volume = -Asset.CurrentPosition(j);
%                 %Signal{i}.Volume = (Asset.Cash(end)/6)/db.Close(end);
%                 Signal{i}.Volume = 100000/db.Close(end);
%                 break
%             end
%         Signal{i}.Volume = 500;
    end
end