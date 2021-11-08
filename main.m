%% main
% 回测模型主脚本
clear
clc
Context.fast = 5;
Context.slow = 20;

%下一行依次：中信证券大盘成长，中信证券小盘成长,中信证券大盘价值，中信证券小盘价值，易方达黄金ETF，中证国债指数
windcode = {'CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI','159934.SZ','H11006.CSI'};

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
%% period 1 201505-201603
%clear DB
load('DB_12.mat')
%strategy
StrategyFunc = @Strategy;%追涨杀跌

% bond
windcode = {'H11006.CSI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% bond+gold
windcode =  {'159934.SZ','H11006.CSI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% overall
windcode =  {'CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI','159934.SZ','H11006.CSI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);


%% period 3 202006-202010
%clear DB
load('DB_18.mat')

%strategy
StrategyFunc = @Strategy;%追涨杀跌

%stock only
windcode = {'CIS08302.WI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% stock+bond
windcode = {'CIS08302.WI','H11006.CSI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% stock+gold
windcode = {'CIS08302.WI','159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% gold+bond
windcode = {'H11006.CSI','159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% overall
windcode = {'CIS08302.WI','H11006.CSI','159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);


%% period 5 201801-201806
%clear DB
load('DB_15.mat')
%strategy
StrategyFunc = @Strategy;%追涨杀跌

% gold
windcode = {'159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);
% gold+bond
windcode = {'H11006.CSI','159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);
% overall
windcode = {'CIS08302.WI','159934.SZ','H11006.CSI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);



%% period 6 201807-202002
%clear DB
load('DB_16.mat')
%strategy
StrategyFunc = @Strategy;%追涨杀跌

% gold
windcode = {'159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);
% gold+bond
windcode = {'H11006.CSI','159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);
% overall
windcode =  {'H11006.CSI','159934.SZ','CIS08302.WI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);



%% long period 2015-2021
%clear DB
load('DB_long.mat')

% stock only
windcode = {'CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% stock+bond
windcode = {'CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI','H11006.CSI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% stock+gold
windcode = {'CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI','159934.SZ'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);

% stock+bond+gold
windcode = {'CIS08302.WI','CIS08342.WI','CIS08301.WI','CIS08341R.WI','159934.SZ','H11006.CSI'};
[Asset] = Backtest(DB,StrategyFunc,windcode,Options);
