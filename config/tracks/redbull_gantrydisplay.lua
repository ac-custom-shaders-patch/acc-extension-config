local displayminutes = 0
local displayhours = 0
local leader = 0
local carnbr = 0

function update(dt)

	if ac.getCar(carnbr).racePosition == 1 then
		leader = carnbr
	end

    if ac.getSim().raceSessionType == 3 then
        displayhours = "LP"
        displayminutes = string.format("%02d", (ac.getCar(leader).sessionLapCount+1))
    else
        displayhours = string.format("%02d", math.floor((ac.getSim().sessionTimeLeft)/(1000*60))%60)
        displayminutes = string.format("%02d", math.floor((ac.getSim().sessionTimeLeft)/1000)%60)
    end

    carnbr=carnbr<ac.getSim().carsCount-1 and carnbr+1 or 0

    display.text{ pos=vec2(10,2) , letter=vec2(50, 90), text=string.format("%02d", math.floor(ac.getSim().timeHours)%24), font="digital_big", spacing = 0, color = rgbm(1, 1, 1, 1) }
	display.text{ pos=vec2(95,2), letter=vec2(50,90), text=":", font="digital_big", spacing = 25, color = rgbm(1, 1, 1, 1) }
	display.text{ pos=vec2(130,2) , letter=vec2(50,90), text=string.format("%02d", math.floor(ac.getSim().timeMinutes)%60), font="digital_big", spacing = 0, color = rgbm(1, 1, 1, 1) }

	display.text{ pos=vec2(310,2) , letter=vec2(50, 90), text=displayhours, font="digital_big", spacing = 0, color = rgbm(1, 1, 1, 1) }
	display.text{ pos=vec2(395,2), letter=vec2(50,90), text=":", font="digital_big", spacing = 25, color = rgbm(1, 1, 1, 1) }
	display.text{ pos=vec2(430,2) , letter=vec2(50,90), text=displayminutes, font="digital_big", spacing = 0, color = rgbm(1, 1, 1, 1) }
end