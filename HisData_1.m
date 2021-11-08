function HisDB = HisData(DB,windcode,Options)
%HisDB是包含当天的数据的
I = DB.CurrentK;
HisDB = DB;
HisDB.Benchmark = HisDB.Benchmark(1:I,:);
HisDB.Times = HisDB.Times(1:I,:);
HisDB.TimesStr = HisDB.TimesStr(1:I,:);
for i=1:max(size(windcode))
    stock = windcode{i};
    %调整命名规则，以.为分割
    namei = stock;
    index = strfind(namei, '.');
    PreName = namei(1:index-1);
    AfterName = namei(index+1:end);
    namecat = [AfterName, PreName];
    Data=getfield(HisDB,namecat);
    Data.Times = Data.Times(1:I,:);
    Data.TimesStr = Data.TimesStr(1:I,:);
    %Data.Sec_status = Data.Sec_status(1:I,:);
    %Data.Trade_status = Data.Trade_status(1:I,:);
    Data.Pct_chg = Data.Pct_chg(1:I,:);
    %Data.Open = Data.Open(1:I,:);
    %Data.High = Data.High(1:I,:);
    %Data.Low = Data.Low(1:I,:);
    Data.Close = Data.Close(1:I,:);
    %Data.Volume = Data.Volume(1:I,:);
    HisDB=setfield(HisDB,namecat,Data);
end