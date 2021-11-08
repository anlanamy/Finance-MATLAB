function Asset = Clearing_1(Asset,DB,Options)
I = DB.CurrentK;
if I == 1
    AvaCash = Asset.InitCash;
    PreStock = [];
    PrePosition = [];
else
    AvaCash = Asset.Cash(I-1);
    PreStock = Asset.Stock{I-1};
    PrePosition = Asset.Position{I-1};
end
Asset.CurrentStock = PreStock;
Asset.CurrentPosition = PrePosition;
for i = 1:length(Asset.OrderPrice{I})
    dealvolume = [];
    if Asset.OrderVolume{I}(i) > 0
        dealprice = Asset.OrderPrice{I}(i) * (1+Options.Slippage);
    else
        dealprice = Asset.OrderPrice{I}(i) * (1-Options.Slippage);
    end
    %{
    %调整命名规则，以.为分割
    namei = Asset.OrderStock{I}{i};
    index = strfind(namei, '.');
    PreName = namei(1:index-1);
    AfterName = namei(index+1:end);
    namecat = [AfterName, PreName];
    Data=getfield(DB,namecat);
    %}
    dealvolume = Asset.OrderVolume{I}(i);
    %整百买入可以放松
%     if dealvolume > 0
%         dealvolume = floor(dealvolume/100)*100; % 必须整百买入
%     end

    if dealvolume > 0 && AvaCash - dealvolume*dealprice - max(Options.MinCommission,dealvolume*dealprice*Options.Commission) < 0
        if Options.PartialDeal == 1 % 买入资金量不足时部分成交
            dealvolume = floor(AvaCash/dealprice/(1+Options.Commission)/100)*100;
            if dealvolume*dealprice*Options.Commission < Options.MinCommission
                dealvolume = floor((AvaCash - Options.MinCommission)/dealprice/100)*100;
            end
            if dealvolume > 0
                disp(['Bar' num2str(I) '@' DB.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，' Asset.OrderStock{I}{i} '买入' num2str(dealvolume) '股，交易部分成交']);
            else
                disp(['Bar' num2str(I) '@' DB.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，不足一手，' Asset.OrderStock{I}{i} '买入失败']);
            end
        else
            dealvolume = 0;
            disp(['Bar' num2str(I) '@' DB.TimesStr(I,:) ' Message: 可用资金量为' num2str(AvaCash) '，不足一手，' Asset.OrderStock{I}{i} '买入失败']);
        end
    end
    
    if dealvolume ~= 0
        Asset.DealStock{I} = [Asset.DealStock{I} Asset.OrderStock{I}(i)];
        Asset.DealVolume{I} = [Asset.DealVolume{I} dealvolume];
        Asset.DealPrice{I} = [Asset.DealPrice{I} dealprice];
        if dealvolume > 0
            dealfee = max(Options.MinCommission,dealvolume*dealprice*Options.Commission);
        else
            dealfee = max(Options.MinCommission,-dealvolume*dealprice*Options.Commission) + (-dealvolume)*dealprice*Options.StampTax;
        end
        Asset.DealFee{I} = [Asset.DealFee{I} dealfee];
        AvaCash = AvaCash - dealvolume*dealprice - dealfee;
        
        ind = strcmp(Asset.OrderStock{I}{i},Asset.CurrentStock);
        if sum(ind) > 1
            disp('!!! 当前持仓错误 !!!');
        end
        if sum(ind) > 0
            if ( sum(Asset.CurrentPosition(ind)) + dealvolume >= 0 ) || ( sum(Asset.CurrentPosition(ind)) + dealvolume < 0 && Options.Short == 1 )
                Asset.CurrentPosition(ind) = sum(Asset.CurrentPosition(ind))+dealvolume;
            end
        else
            if ( dealvolume > 0 ) || ( dealvolume < 0 && Options.Short == 1 )
                Asset.CurrentStock = [Asset.CurrentStock Asset.OrderStock{I}(i)];
                Asset.CurrentPosition = [Asset.CurrentPosition dealvolume];
            end
        end
    end
end
Asset.Stock{I} = Asset.CurrentStock;
Asset.Position{I} = Asset.CurrentPosition;
Asset.Cash(I) = AvaCash;