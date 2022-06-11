local displayminutes = 0
local displayhours = 0
local leader = 0
local carnbr = 0
local color1 = rgbm(1, .55, .2, 1)
local color2 = rgbm(1, 1, 1, 1)
local color3 = rgbm(1, .2, 0, 1)
local lastlaptime = 0

local LineHeight = 122.5
local yPos = 124
local carname={}
local char_128=string.char(195)..string.char(128)
local char_129=string.char(195)..string.char(129)
local char_130=string.char(195)..string.char(130)
local char_131=string.char(195)..string.char(131)
local char_132=string.char(195)..string.char(132)
local char_133=string.char(195)..string.char(133)
local char_134=string.char(195)..string.char(134)
local char_135=string.char(195)..string.char(135)
local char_136=string.char(195)..string.char(136)
local char_137=string.char(195)..string.char(137)
local char_138=string.char(195)..string.char(138)
local char_139=string.char(195)..string.char(139)
local char_140=string.char(195)..string.char(140)
local char_141=string.char(195)..string.char(141)
local char_142=string.char(195)..string.char(142)
local char_143=string.char(195)..string.char(143)
local char_144=string.char(195)..string.char(144)
local char_145=string.char(195)..string.char(145)
local char_146=string.char(195)..string.char(146)
local char_147=string.char(195)..string.char(147)
local char_148=string.char(195)..string.char(148)
local char_149=string.char(195)..string.char(149)
local char_150=string.char(195)..string.char(150)
local char_151=string.char(195)..string.char(151)
local char_152=string.char(195)..string.char(152)
local char_153=string.char(195)..string.char(153)
local char_154=string.char(195)..string.char(154)
local char_155=string.char(195)..string.char(155)
local char_156=string.char(195)..string.char(156)
local char_157=string.char(195)..string.char(157)
local char_158=string.char(195)..string.char(158)
local char_159=string.char(195)..string.char(159)
local char_160=string.char(195)..string.char(160)
local char_161=string.char(195)..string.char(161)
local char_162=string.char(195)..string.char(162)
local char_163=string.char(195)..string.char(163)
local char_164=string.char(195)..string.char(164)
local char_165=string.char(195)..string.char(165)
local char_166=string.char(195)..string.char(166)
local char_167=string.char(195)..string.char(167)
local char_168=string.char(195)..string.char(168)
local char_169=string.char(195)..string.char(169)
local char_170=string.char(195)..string.char(170)
local char_171=string.char(195)..string.char(171)
local char_172=string.char(195)..string.char(172)
local char_173=string.char(195)..string.char(173)
local char_174=string.char(195)..string.char(174)
local char_175=string.char(195)..string.char(175)
local char_176=string.char(195)..string.char(176)
local char_177=string.char(195)..string.char(177)
local char_178=string.char(195)..string.char(178)
local char_179=string.char(195)..string.char(179)
local char_180=string.char(195)..string.char(180)
local char_181=string.char(195)..string.char(181)
local char_182=string.char(195)..string.char(182)
local char_183=string.char(195)..string.char(183)
local char_184=string.char(195)..string.char(184)
local char_185=string.char(195)..string.char(185)
local char_186=string.char(195)..string.char(186)
local char_187=string.char(195)..string.char(187)
local char_188=string.char(195)..string.char(188)
local char_189=string.char(195)..string.char(189)
local char_190=string.char(195)..string.char(190)
local char_191=string.char(195)..string.char(191)

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

    display.text{ pos=vec2(0,0) , letter=vec2(37, 135), text=string.format("%02d", math.floor(ac.getSim().timeHours)%24), font="fonts/dotmatrix", spacing = 7, color = color3 }
	display.text{ pos=vec2(77,0), letter=vec2(37,135), text=":", font="fonts/dotmatrix", spacing = 25, color = color3 }
	display.text{ pos=vec2(112,0) , letter=vec2(37,135), text=string.format("%02d", math.floor(ac.getSim().timeMinutes)%60), font="fonts/dotmatrix", spacing = 7, color = color3 }

	display.text{ pos=vec2(263,0) , letter=vec2(37, 135), text=displayhours, font="fonts/dotmatrix", spacing = 7, color = color3 }
	display.text{ pos=vec2(342,0), letter=vec2(37,135), text=":", font="fonts/dotmatrix", spacing = 25, color = color3 }
	display.text{ pos=vec2(376,0) , letter=vec2(37,135), text=displayminutes, font="fonts/dotmatrix", spacing = 7, color = color3 }

    if init~=true then
		carcount=ac.getSim().carsCount-1
		for i=0,carcount do
			name=string.upper(ac.getDriverName(i))
			:gsub(char_128,"A"):gsub(char_129,"A"):gsub(char_130,"A"):gsub(char_131,"A"):gsub(char_132,"A"):gsub(char_133,"A"):gsub(char_134,"A")
			:gsub(char_135,"C")
			:gsub(char_136,"E"):gsub(char_137,"E"):gsub(char_138,"E"):gsub(char_139,"E")
			:gsub(char_140,"I"):gsub(char_141,"I"):gsub(char_142,"I"):gsub(char_143,"I")
			:gsub(char_144,"D")
			:gsub(char_145,"N")
			:gsub(char_146,"O"):gsub(char_147,"O"):gsub(char_148,"O"):gsub(char_149,"O"):gsub(char_150,"O"):gsub(char_152,"O")
			:gsub(char_151,"X")
			:gsub(char_153,"U"):gsub(char_154,"U"):gsub(char_155,"U"):gsub(char_156,"U")
			:gsub(char_157,"Y")
			:gsub(char_158,"P")
			:gsub(char_159,"S")

			:gsub(char_160,"A"):gsub(char_161,"A"):gsub(char_162,"A"):gsub(char_163,"A"):gsub(char_164,"A"):gsub(char_165,"A"):gsub(char_166,"A")
			:gsub(char_167,"C")
			:gsub(char_168,"E"):gsub(char_169,"E"):gsub(char_170,"E"):gsub(char_171,"E")
			:gsub(char_172,"I"):gsub(char_173,"I"):gsub(char_174,"I"):gsub(char_175,"I")
			:gsub(char_176,"D")
			:gsub(char_177,"N")
			:gsub(char_178,"O"):gsub(char_179,"O"):gsub(char_180,"O"):gsub(char_181,"O"):gsub(char_182,"O"):gsub(char_184,"O")
			:gsub(char_183,"X")
			:gsub(char_185,"U"):gsub(char_186,"U"):gsub(char_187,"U"):gsub(char_188,"U")
			:gsub(char_189,"Y")
			:gsub(char_190,"P")
			:gsub(char_191,"Y")
			x=0
			index=0
			repeat
				index2=index
				index=x+1
				x=string.find(name," ",index)
			until (x==nil)	
			length=name.len(name)
			if string.sub(name,length-1,length)=="%)" then
				index=index2
			end
			carname[i]=string.sub(name,index,index+2)
		end
		init=true
	end
	
	for carnbr=0,carcount do
		carpos=ac.getCar(carnbr).racePosition-1

		lastlaptime = ac.getCar(carnbr).previousLapTimeMs
		formattedTimeM = string.format("%01d", math.floor((lastlaptime/(1000*60)))%60)
		formattedTimeS = string.format("%02d", math.floor((lastlaptime/1000))%60)
		formattedTimeTS = string.format("%01d", math.floor((lastlaptime/100%10)))

		if carpos<7 then
			display.text{pos=vec2(0,carpos*LineHeight+yPos), letter=vec2(37, 135), text=carpos, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color1 }
			display.text{pos=vec2(114,carpos*LineHeight+yPos), letter=vec2(37, 135), text=carname[carnbr], font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(262,carpos*LineHeight+yPos), letter=vec2(37, 135), text=formattedTimeM, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(290,carpos*LineHeight+yPos), letter=vec2(37, 135), text=":", font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(319,carpos*LineHeight+yPos), letter=vec2(37, 135), text=formattedTimeS, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(391,carpos*LineHeight+yPos), letter=vec2(37, 135), text=".", font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(419,carpos*LineHeight+yPos), letter=vec2(37, 135), text=formattedTimeTS, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
		end
        if carpos>=7 and carpos<15 then
			display.text{pos=vec2(0,carpos*LineHeight+yPos+34), letter=vec2(37, 135), text=carpos, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color1 }
			display.text{pos=vec2(114,carpos*LineHeight+yPos+34), letter=vec2(37, 135), text=carname[carnbr], font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(262,carpos*LineHeight+yPos+34), letter=vec2(37, 135), text=formattedTimeM, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(290,carpos*LineHeight+yPos+34), letter=vec2(37, 135), text=":", font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(319,carpos*LineHeight+yPos+34), letter=vec2(37, 135), text=formattedTimeS, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(391,carpos*LineHeight+yPos+34), letter=vec2(37, 135), text=".", font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
			display.text{pos=vec2(419,carpos*LineHeight+yPos+34), letter=vec2(37, 135), text=formattedTimeTS, font="fonts/dotmatrix", spacing = 7, alignment=0, color=color2 }
		end
	end
end