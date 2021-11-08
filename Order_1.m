function Asset = Order_1(DB,Asset,stock,volume,type,Options)
I = DB.CurrentK;
if strcmp(type,'TodayClose')==1
    OrderDay = 0;
elseif strcmp(type, 'NextOpen')==1
    if I+1<=DB.NK
        OrderDay = 1;
    else
        return;
    end
end
if volume > 0
    ordertype = '买入';
else
    ordertype = '卖出';
end
%调整命名规则，以.为分割
namei = stock;
index = strfind(namei, '.');
PreName = namei(1:index-1);
AfterName = namei(index+1:end);
namecat = [AfterName, PreName];
Data=getfield(DB,namecat);

if I+OrderDay <= DB.NK
    Asset.OrderStock{I+OrderDay} = [Asset.OrderStock{I+OrderDay},{stock}];
    Asset.OrderPrice{I+OrderDay} = [Asset.OrderPrice{I+OrderDay} Data.Close(I+OrderDay)];
    Asset.OrderVolume{I+OrderDay} = [Asset.OrderVolume{I+OrderDay} volume];
end
end