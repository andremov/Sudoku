-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )
system.setIdleTimer( false )

	
local y = display.contentHeight - 20
local fullText = "Developed by Andres Movilla"
local rightsText = display.newText(fullText,display.contentCenterX,y,native.systemFont,15)
rightsText:setFillColor(0.3,0.3,0.3)

local menu=require("menu")
menu.start()



