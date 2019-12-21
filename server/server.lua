local serverdata = {}
serverdata.Stocks = {}

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--[[    Send to client    ]]
function refreshclients()
    local data = json.encode(serverdata)
    TriggerClientEvent('esx_stock:currentstocks', -1,data)
end

--[[    Buy and sell    ]]
RegisterServerEvent('esx_stock:buystock')
AddEventHandler('esx_stock:buystock', function(name, value, amount)
    local cost = 0
    local xPlayer = ESX.GetPlayerFromId(source)
    local ticket = xPlayer.getInventoryItem('proof_assets').count
    local price = value * amount
    cost = xPlayer.getAccount('bank').money
    if false then
        TriggerClientEvent('esx:showNotification', source, '你~r~未持有~g~資產證明書~w~! 請洽~b~相關單位~w~申請取得')
    else
        if cost < price then
            TriggerClientEvent('esx:showNotification', source, '你的~g~銀行~w~沒有~r~足夠~w~的錢!')
        else
            xPlayer.removeAccountMoney('bank', price)
            TriggerClientEvent('chatMessage', source, '購買通知', {0,255,0}, '你購買了^5名稱: ^7' .. name .. ' 單價 ^2$: ' .. value .. ' ^7張數: ^4' .. amount .. ' ^7總計 ^2$:' .. price)
            sendToDiscord(StockWeb, StockWebName, GetPlayerName(source) .. ' 購買了名稱: ' .. name .. ' 單價 $: ' .. value .. ' 張數: ' .. amount .. ' 總計 $: ' .. price, 32768)   
            TriggerEvent('esx_stock:buystocksql', xPlayer, name, value, amount)         
        end
    end
end)

RegisterServerEvent('esx_stock:sellstock')
AddEventHandler('esx_stock:sellstock', function(name, value, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ticket = xPlayer.getInventoryItem('proof_assets').count
    local price = value * amount
    if ticket ~= 1 then
        TriggerClientEvent('esx:showNotification', source, '你~r~未持有~g~資產證明書~w~! 請洽~b~相關單位~w~申請取得')
    elseif stock_name ~= name then
        TriggerClientEvent('esx:showNotification', source, '你~r~未持有~w~該股份')
    elseif stock_amount < amount then
        TriggerClientEvent('esx:showNotification', source, '你身上未持有~r~足夠~w~的股票~g~張數')
    else
        xPlayer.addAccountMoney('bank', price)
        TriggerClientEvent('chatMessage', source, '販售通知', {0,255,0}, '你販售了^5名稱: ^7' .. name .. ' 單價 ^2$: ' .. value .. ' ^7張數: ^4' .. amount .. ' ^7總計 ^2$:' .. price)
        sendToDiscord(StockWeb, StockWebName, GetPlayerName(source) .. '\n購買了名稱: ' .. name .. '\n單價 $: ' .. value .. '\n張數: ' .. amount .. '\n總計 $: ' .. price, 16711680)
    end
end)

--[[    Buy and sell SQL   ]]
RegisterServerEvent('esx_stock:buystocksql')
AddEventHandler('esx_stock:buystocksql', function(xPlayer, name, value, amount)
    MySQL.Async.fetchAll('SELECT * FROM stock WHERE identifier = @identifier and stock_name=@stock_name',
    {
        ['@identifier'] = xPlayer.identifier,
		['@stock_name'] = name
    },
    function(check)
        if check[1] ~= nil then
            MySQL.Async.fetchAll('SELECT stock_name, stock_value, stock_amount FROM stock WHERE identifier = @identifier and stock_name=@stock_name', {
                ['@identifier'] = xPlayer.identifier,
				['@stock_name'] = name,
            }, 
            function(result)
                local stkname = result[1].stock_name
                local stkvalue = result[1].stock_value
                local stkamount = result[1].stock_amount
                MySQL.Async.execute('UPDATE stock SET stock_value = @stock_value,stock_amount = @stock_amount WHERE identifier = @identifier and stock_name=@stock_name', 
                {
                        ['@identifier'] = xPlayer.identifier,
                        ['@stock_value'] = value,
                        ['@stock_amount'] = stkamount+amount,
						['@stock_name'] = name,
                })
            end)
        else
            MySQL.Async.execute('INSERT INTO stock (identifier, stock_name, stock_value, stock_amount) VALUES (@identifier, @stock_name, @stock_value, @stock_amount)',
            {
                ['@identifier'] = xPlayer.identifier,
                ['@stock_name'] = name,
                ['@stock_value'] = value,
                ['@stock_amount'] = amount,
            })
        end
    end)
end)

RegisterServerEvent('esx_stock:sellstocksql')
AddEventHandler('esx_stock:sellstocksql', function(name, value, amount)
	local xPlayer= ESX.GetPlayerFromId(source).identifier
	local tPlayer= ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM stock where `identifier` = @identifier and stock_name=@stockName', {
		['@identifier'] = xPlayer,
		['@stockName'] = name,
	
	}, function(result)
	result[1].amount = amount
	result[1].name = name
	result[1].value = value
	result[1].xPlayer = tPlayer
	TriggerEvent('esx_stock:sell',result)
    end)
end)


RegisterServerEvent('esx_stock:sell')
AddEventHandler('esx_stock:sell', function(result)
	local stamount = result[1].stock_amount
	local name = result[1].name
	local value = result[1].value
	local amount = result[1].amount
	local xPlayer = result[1].xPlayer
	local price = value * amount
    if false then
        TriggerClientEvent('esx:showNotification', source_, '你~r~未持有~g~資產證明書~w~! 請洽~b~相關單位~w~申請取得')
    elseif stamount < amount then
        TriggerClientEvent('esx:showNotification', -1, '你身上未持有~r~足夠~w~的股票~g~張數,或者未持有該股票')
    else
        xPlayer.addAccountMoney('bank', price)
		TriggerEvent('esx_stock:updatestockvalue',xPlayer,name,amount)
        TriggerClientEvent('chatMessage',-1, '販售通知', {0,255,0}, '你販售了^5名稱: ^7' .. name .. ' 單價 ^2$: ' .. value .. ' ^7張數: ^4' .. amount .. ' ^7總計 ^2$:' .. price)
        sendToDiscord(StockWeb, StockWebName, xPlayer.name .. ' \n出售了名稱: ' .. name .. ' \n單價 $: ' .. value .. ' \n張數: ' .. amount .. '\n 總計 $: ' .. price, 16711680)
    end
end)

RegisterServerEvent('esx_stock:updatestockvalue')
AddEventHandler('esx_stock:updatestockvalue', function(xPlayer, name, amount)
	MySQL.Async.fetchAll('SELECT stock_name, stock_amount FROM stock WHERE identifier = @identifier and stock_name=@stock_name', {
                ['@identifier'] = xPlayer.identifier,
				['@stock_name'] = name,
            }, 
            function(result)
                local stkname = result[1].stock_name
                local stkamount = result[1].stock_amount
                MySQL.Async.execute('UPDATE stock SET stock_amount = @stock_amount WHERE identifier = @identifier and stock_name=@stock_name', 
                {
                        ['@identifier'] = xPlayer.identifier,
                        ['@stock_amount'] = stkamount - amount,
						['@stock_name'] = stkname,
                })
            end)
end)


--[[    Ramdom stocks value    ]]
function randomstockvalue()
    for i=1, #serverdata.Stocks, 1 do
        local stockchange = 0
		local randomint = 0
		local randomfloat = 0
		local stock = nil
		local stockname = nil
		stock = serverdata.Stocks[i]
		stockname = stock.name
		randomint = math.random(0,10)
        
        local stockvalue = stock.value
		local randomnum = nil
        local randomnum = math.random(1,4)

        if randomnum <= 2 then
            stockchange = stockvalue - randomint
        elseif randomnum == 3 then
            stockchange = stockvalue
        elseif randomnum == 4 then
            stockchange = stockvalue + randomint
        end
        if stockchange < 0 then
            stockchange = 0
        end
        serverdata.Stocks[i].value = stockchange
        Wait(1)
    end
    refreshclients()
end

Citizen.CreateThread(function()
    serverdata = Config
    while true do
        Citizen.Wait(30*1000)
        randomstockvalue()
    end
end)

function sendToDiscord(WebHook, Name, Message, color)
	local connect = {
        {
            ['color'] = color,
            ['title'] = '**'.. Name ..'**',
            ['description'] = Message,
            ['footer'] = {
                ['text'] = '',
            },
        }
    }
	PerformHttpRequest(WebHook, function(Error, Content, Head) end, 'POST', json.encode({username = Name, embeds = connect}), {['Content-Type'] = 'application/json'})
end