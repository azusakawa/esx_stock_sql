local stocktable = {}
ESX                             = nil

--[[    ESX Base    ]]
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

--[[    Get server data    ]]
RegisterNetEvent('esx_stock:currentstocks')
AddEventHandler('esx_stock:currentstocks', function(stock)     
    stocktable = json.decode(stock)
end)

--[[    Create Bilps    ]]
Citizen.CreateThread(function()
    for k, v in pairs(Config.Company) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite (blip, 476)
        SetBlipScale  (blip, 1.0)
        SetBlipColour (blip, 25)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("證卷所")
        EndTextCommandSetBlipName(blip)
    end
end)

--[[    Open Menu   ]]
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local clock = GetClockHours()
        local day = GetClockDayOfWeek()
        if nearStock() then
            DisplayText3D("按 ~INPUT_PICKUP~ 開啟股票商店")
            if IsControlJustPressed(0,38) then
                --OpenStockMenu()
                if day >= 1 and day <= 5 then
                    if clock >= 8 and clock <=18 then
                        OpenStockMenu()
                    else
                        TriggerEvent('esx:showNotification', '~r~很抱歉~w~, 現在並不是~g~交易~w~與~b~營業~w~時間')
                    end
                end
            end
        end
    end
end)

function OpenStockMenu()
    local elements = {}
    local elements2 = {}
    for i=1, #stocktable.Stocks, 1 do
        local ldata = stocktable.Stocks
        local stockvalue = ldata[i].value
        local stockname = ldata[i].name
        table.insert(elements2, {
            label = ('%s - <span style="color:green;">%s</span>'):format(stockname, stockvalue), 
            name = stockname, 
            price = stockvalue,

            value = 1,
			type = 'slider',
			min = 1,
			max = 100
        })
    end
    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'stock_info',
        {
        title    = '股票',
        align    = 'bottom-right',
        elements = elements2,
        },
        function(data, menu)
        
        local stockamount = data.current.value
        local currentstock = data.current.name
        local currentstockvalue = data.current.price
        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'stock_buy_info',
            {
            title    = '名稱: ' .. currentstock .. ' 單價 $: '.. currentstockvalue .. ' 張數: ' .. stockamount,
            align    = 'bottom-right',
            elements = {
                {label = '購買', value = 'Buy_Stock' },
                {label = '出售', value = 'Sell_Stock' },
                {label = '關閉', value = 'Close_Menu' },
                },
            },
            function(data, menu)
            
            if data.current.value == 'Buy_Stock' then
                TriggerServerEvent('esx_stock:buystock',currentstock, currentstockvalue, stockamount)
            elseif data.current.value == 'Sell_Stock' then
				TriggerServerEvent('esx_stock:sellstocksql',currentstock, currentstockvalue, stockamount)
            end
            ESX.UI.Menu.CloseAll()
        end)
    end)
end

--[[    Function    ]]
function nearStock()
    local player = GetPlayerPed(-1)
    local playerloc = GetEntityCoords(player, 0)

    for _, search in pairs(Config.Company) do
        local distance = GetDistanceBetweenCoords(search.x, search.y, search.z, playerloc['x'], playerloc['y'], playerloc['z'], true)
        if distance <= 3 then
			return true
        end
	end
end

function DisplayText3D(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
