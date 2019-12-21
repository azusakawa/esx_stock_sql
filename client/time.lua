local month, DayOfMonth, DayOfWeek, hour, minute, second

--[[    Show Text   ]]
function DrawTxt(text, x, y)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.3, 0.3)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

--[[    Display Time    ]]
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local clock = GetClockHours()
        local day = GetClockDayOfWeek()
        if day >= 1 and day <= 5 then
            if clock >= 8 and clock <=18 then
                DrawTxt("~y~股市 ~w~: ~g~開", 0.7, 0.02)
            else
                DrawTxt("~y~股市 ~w~: ~r~關", 0.7, 0.02)
            end
        else
            DrawTxt("~y~股市 ~w~: ~r~關", 0.7, 0.02)
        end
        DisplayTime()
        DrawTxt(month .." / ".. DayOfMonth .." | ".. hour ..":".. minute .." | ".. DayOfWeek, 0.7, 0.0)
    end
end)

--[[    Hour Minute Second    ]]
function DisplayTime()
	hour = GetClockHours()
    minute = GetClockMinutes()
    second = GetClockSeconds()
    DayOfWeek = GetClockDayOfWeek()
    month = GetClockMonth()
	DayOfMonth = GetClockDayOfMonth()

    -- if hour == 0 or hour == 24 then
    --     hour = 12 
    -- elseif hour >= 13 then
    --     hour = hour - 12 
    -- end

	if hour <= 9 then
		hour = "0" .. hour
	end
	if minute <= 9 then
		minute = "0" .. minute
    end
--[[    Date    ]]
	if DayOfWeek == 1 then
		DayOfWeek = "周一"
	elseif DayOfWeek == 2 then
		DayOfWeek = "周二"
	elseif DayOfWeek == 3 then
		DayOfWeek = "周三"
	elseif DayOfWeek == 4 then
		DayOfWeek = "周四"
	elseif DayOfWeek == 5 then
		DayOfWeek = "周五"
	elseif DayOfWeek == 6 then
		DayOfWeek = "周六"
	else 
		DayOfWeek = "周日"
    end
--[[    Year Month Date    ]]
	if month == 0 then
		month = "一月"
	elseif month == 1 then
		month = "二月"
	elseif month == 2 then
		month = "三月"
	elseif month == 3 then
		month = "四月"
	elseif month == 4 then
		month = "五月"
	elseif month == 5 then
		month = "六月"
	elseif month == 6 then
		month = "七月"
	elseif month == 7 then
		month = "八月"
	elseif month == 8 then
		month = "九月"
	elseif month == 9 then
		month = "十月"
	elseif month == 10 then
		month = "十一月"
	elseif month == 11 then
		month = "十二月"
    end
end