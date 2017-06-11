-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)

local underline
local group

function start()
	group = display.newGroup()

	local midW = display.contentCenterX
	local title = display.newText("Sudoku",midW,35,native.systemFont,40)
	group:insert(title)

	underline = display.newRect(midW,65,0,2)
	group:insert(underline)

	timer.performWithDelay(10,expand)
end

function expand() 
	underline.width = underline.width + 6

	if (underline.width < 180) then
		timer.performWithDelay(10,expand)
	else
		underline:setFillColor(0,1,0)
		showFullMenu()
	end
end

function showFullMenu()
	local midW = display.contentCenterX
	
	local y = 190
	local playBtn = display.newRect(midW, y, 210, 50)
	playBtn:addEventListener("tap", playCall)
	local playText = display.newText("Play",midW,y,native.systemFont,35)
	playText:setFillColor(0,0,0)
	group:insert(playBtn)
	group:insert(playText)

	y = 270
	local solveBtn = display.newRect(midW, y, 210, 50)
	solveBtn:addEventListener("tap", solveCall)
	local solveText = display.newText("Solve",midW,y,native.systemFont,35)
	solveText:setFillColor(0,0,0)
	group:insert(solveBtn)
	group:insert(solveText)
	
end

function playCall()
	dispose()
	local play = require("game")
	play.init()
end

function solveCall()
	dispose()
	local solver = require("solver")
	solver.init()
end

function dispose()
	display.remove(group)
	underline = nil
end
