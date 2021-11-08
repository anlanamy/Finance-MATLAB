function [Asset,DB] = Backtest(DB,StrategyFunc,windcode,Options)
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
    Asset = Clearing_3(Asset,DB,Options);
end

Asset=Summary_1(Asset,DB,Options);
disp('=== Back test complete! ===')
end