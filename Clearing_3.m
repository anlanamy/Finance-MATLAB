function Asset = Clearing_3(Asset,DB,Options)
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

%先执行卖，后买
% negindex = find(Asset.OrderVolume{I} < 0);
% posindex = find(Asset.OrderVolume{I} >= 0);

[Asset.OrderVolume{I}, seq] = sort(Asset.OrderVolume{I});
Asset.OrderPrice{I} = Asset.OrderPrice{I}(seq);
Asset.OrderStock{I} = Asset.OrderStock{I}(seq);

% tempvol = [Asset.OrderVolume{I}(negindex) Asset.OrderVolume{I}(posindex)];
% temppri = [Asset.OrderPrice{I}(negindex) Asset.OrderPrice{I}(posindex)];
% Asset.OrderVolume{I} = tempvol;
% Asset.OrderPrice{I} = temppri;

for i = 1:length(Asset.OrderPrice{I})
    dealprice = Asset.OrderPrice{I}(i);
    dealvolume = Asset.OrderVolume{I}(i);

    if dealvolume > 0 && AvaCash - dealvolume*dealprice < 0
        dealvolume = AvaCash/dealprice;
    end

    Asset.DealStock{I} = [Asset.DealStock{I} Asset.OrderStock{I}(i)];
    Asset.DealVolume{I} = [Asset.DealVolume{I} dealvolume];
    Asset.DealPrice{I} = [Asset.DealPrice{I} dealprice];
    dealfee = 0;
    Asset.DealFee{I} = [Asset.DealFee{I} dealfee];

    ind = strcmp(Asset.OrderStock{I}{i},Asset.CurrentStock);
    if sum(ind) > 1
        disp('!!! 当前持仓错误 !!!');
    end
    if sum(ind) > 0 %交易股票已有仓位
        if ( sum(Asset.CurrentPosition(ind)) + dealvolume >= 0 ) || ( sum(Asset.CurrentPosition(ind)) + dealvolume < 0 && Options.Short == 1 )
            if sum(Asset.CurrentPosition(ind)) + dealvolume ~= 0
                Asset.CurrentPosition(ind) = sum(Asset.CurrentPosition(ind))+dealvolume;
            else
                Asset.CurrentPosition(ind) = [];
                Asset.CurrentStock(ind) = [];
            end
        else %要卖，order量穿仓又不许卖空，则直接卖光
            dealvolume = -sum(Asset.CurrentPosition(ind));
            Asset.CurrentPosition(ind) = [];
            Asset.CurrentStock(ind) = [];
        end
    else %交易股票没有仓位
        if ( dealvolume > 0 ) || ( dealvolume < 0 && Options.Short == 1 )
            Asset.CurrentStock = [Asset.CurrentStock Asset.OrderStock{I}(i)];
            Asset.CurrentPosition = [Asset.CurrentPosition dealvolume];
        end
    end
    AvaCash = AvaCash - dealvolume*dealprice - dealfee;
    if AvaCash < 0
        AvaCash = 0;
    end
end

[~, revseq] = sort(seq);
Asset.OrderVolume{I} = Asset.OrderVolume{I}(revseq);
Asset.OrderPrice{I} = Asset.OrderPrice{I}(revseq);
Asset.OrderStock{I} = Asset.OrderStock{I}(revseq);

Asset.Stock{I} = Asset.CurrentStock;
Asset.Position{I} = Asset.CurrentPosition;
Asset.Cash(I) = AvaCash;