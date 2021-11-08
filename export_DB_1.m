%% 生成DB数据（本部分不用运行，直接从下部分开始即可
clear
clc
Context.fast = 5;
Context.slow = 20;

%windcode = {'600000.SH','600300.SH','600301.SH', '600302.SH'};
%下一行依次：申万大盘指数，中证500，中信证券大盘成长，中信证券小盘成长,中信证券大盘价值，中信证券小盘价值
windcode = {'801811.SI', '000905.SH','CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI'};
start_time = '2014-12-02 09:00:00';
end_time = '2015-7-31 12:00:00';

Options.InitCash = 100000000;
Options.Benchmark = '000300.SH'; % 设置基准
Options.VolumeRatio = 0.25; % 成交量限制不得超过当日成交量的固定比例
Options.RiskFreeReturn = 0.05; % 无风险收益率
Options.MinCommission = 5; % 最小佣金
Options.Commission = 0.0008; % 佣金
Options.StampTax = 0.001; % 卖出时征收的印花税
Options.Slippage = 0.00246; % 滑点
Options.PartialDeal = 1; % 开启自动部分成交模式

Options.Short = 1; % 允许对交易标的进行做空
Options.DelayDays = 3; % 交易失败则最大延迟交易天数，超过则放弃交易
%补一下strategy
StrategyFunc = @Strategy_1;
%% backtest代码
w = windmatlab;
% 加载K线数据
if ischar(windcode)
    % 定位游标位置到第一条K线
    DB.CurrentK = 1;
    [Data flag] = LoadData_1(w,windcode,start_time,end_time,Options);
    %调整命名规则，以.为分割
    namei = windcode;
    index = strfind(namei, '.');
    PreName = namei(1:index-1);
    AfterName = namei(index+1:end);
    namecat = [AfterName, PreName];
    DB=setfield(DB,namecat,Data);
    if flag==0
        disp('=== Back test shutting down! ===')
        return;
    end
end
if iscell(windcode)
    % 定位游标位置到第一条K线
    DB.CurrentK = 1;
    for i=1:max(size(windcode))
        [Data flag] = LoadData_1(w,windcode{i},start_time,end_time,Options);
        %调整命名规则，以.为分割
        namei = windcode{i};
        index = strfind(namei, '.');
        PreName = namei(1:index-1);
        AfterName = namei(index+1:end);
        namecat = [AfterName, PreName];
        DB=setfield(DB,namecat,Data);
        %{
        %add
        indi_info = {};
        indi_info = setfield(indi_info,[windcode{i}(8:9) windcode{i}(1:6)],Data);
        DB.cat{i} = indi_info;
        %}
        if flag==0
            disp('=== Back test shutting down! ===')
            return;
        end
    end
end
% 加载回测基准行情数据
[w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times_0,w_wsd_errorid_0,w_wsd_reqid_0]= ...
    w.wsd(Options.Benchmark,'close',start_time,end_time,'PriceAdj=F');
if w_wsd_errorid_0~=0
    disp(['!!! 加载' Options.Benchmark '行情数据错误: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    return;
end
DB.Benchmark = w_wsd_data_0;
DB.BenchmarkStock = Options.Benchmark;
% 时间轴
DB.Times = Data.Times;
DB.TimesStr = datestr(Data.Times,'yymmdd');%按年月日格式的时间戳（交易日）
% K线总数
DB.NK = length(Data.Close);

save('DB_mid.mat', "DB" )
%% 继续走完整个backtest函数
%clear DB
%load('DB_mid.mat')

Context.fast = 5;
Context.slow = 20;

%windcode = {'600000.SH','600300.SH','600301.SH', '600302.SH'};
%下一行依次：申万大盘指数，中证500，中信证券大盘成长，中信证券小盘成长,中信证券大盘价值，中信证券小盘价值
windcode = {'801811.SI', '000905.SH','CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI'};
start_time = '2014-12-02 09:00:00';
end_time = '2015-7-31 12:00:00';

Options.InitCash = 100000000;
Options.Benchmark = '000300.SH'; % 设置基准
Options.VolumeRatio = 0.25; % 成交量限制不得超过当日成交量的固定比例
Options.RiskFreeReturn = 0.05; % 无风险收益率
Options.MinCommission = 5; % 最小佣金
Options.Commission = 0.0008; % 佣金
Options.StampTax = 0.001; % 卖出时征收的印花税
Options.Slippage = 0.00246; % 滑点
Options.PartialDeal = 1; % 开启自动部分成交模式

Options.Short = 1; % 允许对交易标的进行做空
Options.DelayDays = 3; % 交易失败则最大延迟交易天数，超过则放弃交易
%补一下strategy
StrategyFunc = @Strategy_1;
Asset = InitAsset(DB,Options);

% 按交易日遍历
for K = 1:DB.NK
    DB.CurrentK = K; %当前日期
    HisDB = HisData_1(DB,windcode,Options);
    Signal = StrategyFunc(Asset,HisDB,windcode); %运行策略函数，生成交易信号
    if ~isempty(Signal)
        for sig=1:length(Signal) %按信号顺序落单
            if sum(strcmp(Signal{sig}.Stock, windcode))
                Asset = Order_1(DB,Asset,Signal{sig}.Stock,Signal{sig}.Volume,Signal{sig}.Type,Options); % 落单
            else
                disp(['!!! 未订阅' Signal{sig}.Stock '数据，请加入股票订阅池后再次运行回测 !!!']);
                return;
            end
        end
    end
    
    % 每条K线在运行结束时都要清算
    Asset = Clearing_1(Asset,DB,Options);
end

Asset=Summary_1(Asset,DB,Options);
disp('=== Back test complete! ===')
