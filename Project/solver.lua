-----------------------------------------------------------------------------------------
--
-- solver.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)

local ACTION_PAUSE = 0
local ACTION_UNPAUSE = 1
local ACTION_BACK = 2

local board
local boardGroup
local isSolving
local tileSetupMenuGroup
local boardSetupMenuGroup
local solvingMenuGroup
local currentProcess
local history
local isPaused
local currentAction
local puzzles={
	{

		{ 1,0,0, 0,0,7, 0,9,0, },
		{ 0,3,0, 0,2,0, 0,0,8, },
		{ 0,0,9, 6,0,0, 5,0,0, },
		
		{ 0,0,5, 3,0,0, 9,0,0, },
		{ 0,1,0, 0,8,0, 0,0,2, },
		{ 6,0,0, 0,0,4, 0,0,0, },
		
		{ 3,0,0, 0,0,0, 0,1,0, },
		{ 0,4,0, 0,0,0, 0,0,7, },
		{ 0,0,7, 0,0,0, 3,0,0, },
	
	}, {
	
		{ 8,0,0, 0,0,0, 0,0,0, },
		{ 0,0,3, 6,0,0, 0,0,0, },
		{ 0,7,0, 0,9,0, 2,0,0, },
		
		{ 0,5,0, 0,0,7, 0,0,0, },
		{ 0,0,0, 0,4,5, 7,0,0, },
		{ 0,0,0, 1,0,0, 0,3,0, },
		
		{ 0,0,1, 0,0,0, 0,6,8, },
		{ 0,0,8, 5,0,0, 0,1,0, },
		{ 0,9,0, 0,0,0, 4,0,0, },
	
	}, {
	
		{ 1,6,0, 0,9,0, 0,0,0, },
		{ 0,0,9, 0,0,0, 0,0,2, },
		{ 0,0,0, 0,0,2, 0,0,0, },
		
		{ 9,0,0, 0,8,1, 0,0,0, },
		{ 0,0,0, 2,0,0, 0,0,7, },
		{ 0,0,0, 0,6,0, 0,3,0, },
		
		{ 0,0,7, 3,0,4, 0,0,6, },
		{ 0,0,0, 6,0,0, 8,0,0, },
		{ 4,0,0, 0,0,9, 5,0,0, },
	
	},
}

function deleteEverything()
	display.remove(boardGroup)
	boardGroup = nil
	display.remove(boardSetupMenuGroup)
	boardSetupMenuGroup = nil
	local menu = require("menu")
	menu.start()
end


function init()
	initBoard()
	initUI()
	-- initPuzzle(2)
end

function initUI()
	boardSetupMenuGroup = display.newGroup()

	local midW = display.contentCenterX

	local resetBtn=display.newRect(0,0,210,40)
	resetBtn.x=midW
	resetBtn.y=display.contentHeight-70
	resetBtn:setFillColor(0.8,0.5,0.5)
	resetBtn:addEventListener("tap",resetSudoku)
	boardSetupMenuGroup:insert(resetBtn)
	
	local resetText=display.newText("Reset",0,0,native.systemFont,30)
	resetText.x=midW
	resetText.y=resetBtn.y
	resetText:setTextColor(0,0,0)
	boardSetupMenuGroup:insert(resetText)


	local solveBtn=display.newRect(0,0,210,40)
	solveBtn.x=midW
	solveBtn.y=display.contentHeight-130
	solveBtn:setFillColor(0.5,0.8,0.5)
	solveBtn:addEventListener("tap",attemptSolve)
	boardSetupMenuGroup:insert(solveBtn)
	
	local solveText=display.newText("Solve",0,0,native.systemFont,30)
	solveText.x=midW
	solveText.y=solveBtn.y
	solveText:setTextColor(0,0,0)
	boardSetupMenuGroup:insert(solveText)

	local backBtn=display.newRect(0,0,120,100)
	backBtn.x=-20
	backBtn.y=display.contentHeight-100
	backBtn:setFillColor(0.4,0.4,0.4)
	backBtn:addEventListener("tap",deleteEverything)
	boardSetupMenuGroup:insert(backBtn)
	
	local backText=display.newText("Back",0,0,native.systemFont,15)
	backText.x=10
	backText.y=backBtn.y
	backText:setTextColor(0.7,0.7,0.7)
	boardSetupMenuGroup:insert(backText)

end

function initBoard()

	board = { }
	boardGroup = display.newGroup()
	isSolving = false
	for y = 1, 9 do
		board[y] = { }
		for x = 1, 9 do
			local square = display.newRect(0,0,30,30)
			square.x=-2+	(x*31)+		((x-((x-1)%3))*2)
			square.y=		(y*31)+		((y-((y-1)%3))*2)
			square.tileX = x
			square.tileY = y
			square.quad = (math.ceil(x/3)) + ((math.floor((y-1)/3))*3)
			square.finalNum = 0
			square.finalDisplay = display.newText("",0,0,nativeSystemFont,40)
			square.finalDisplay.x=square.x
			square.finalDisplay.y=square.y
			square.isStaticFinal = false
			square.isGuess = false
			square.finalDisplay:setTextColor(0,0,0)

			square.chances = { }
			square.chancesDisplay = { }
			for n = 1, 9 do
				square.chances[n] = true
				square.chancesDisplay[n]=display.newText("",0,0,native.systemFont,11)
				square.chancesDisplay[n].x=square.x - 10 + (((n-1)%3)*10)
				square.chancesDisplay[n].y=square.y - 10 + (math.floor((n-1)/3)*10)
				square.chancesDisplay[n]:setTextColor(0,0,0)
			end

			square.isSolved = function(self)
				return (self.finalNum ~= 0)
			end

			square.hideChances = function(self)
				for n = 1, 9 do
					self.chancesDisplay[n].text = ""
				end
			end

			square.showChances = function(self)
				if (self.finalNum == 0) then
					for n = 1, 9 do
						if (self.chances[n]) then
							self.chancesDisplay[n].text = n
						end
					end
				end
			end

			square.setStaticFinal = function(self, num)
				self.finalNum = num
				self.finalDisplay.text = num
				square.isStaticFinal = true
				square.isGuess = false
				for n = 1, 9 do
					if (n ~= num) then
						self.chances[n] = false
					end
					self.chancesDisplay[n].text = ""
				end
			end

			square.getNumChances = function(self)
				local count = 0
				for n = 1, 9 do
					if (self.chances[n]) then
						count = count + 1
					end
				end
				return count
			end

			square.setGuess = function(self, num)
				self.finalNum = num
				self.finalDisplay.text = num
				self.finalDisplay:setFillColor(0,0.7,0)
				square.isStaticFinal = false
				square.isGuess = true
				resetProcess()
				for n = 1, 9 do
					if (n ~= num) then
						self.chances[n] = false
					else
						self.chances[n] = true
					end
					self.chancesDisplay[n].text = ""
				end
			end

			square.setFinal = function(self, num)
				self.finalNum = num
				self.finalDisplay.text = num
				self.finalDisplay:setFillColor(0,0,0.7)
				square.isStaticFinal = false
				square.isGuess = false
				resetProcess()
				for n = 1, 9 do
					if (n ~= num) then
						self.chances[n] = false
					end
					self.chancesDisplay[n].text = ""
				end
			end

			square.removeChance = function(self, index)
				if (self.chances[index]) then
					resetProcess()
				end
				self.chances[index] = false
				self.chancesDisplay[index].text = ""
				self:checkUnique()
			end

			square.reset = function(self)
				self.finalNum = 0
				self.finalDisplay.text = ""
				self.finalDisplay:setFillColor(0,0,0)
				square.isStaticFinal = false
				square.isGuess = false
				for n = 1, 9 do
					self.chances[n] = true
					self.chancesDisplay[n].text = n
				end
			end

			square.checkUnique = function(self)
				if (self:getNumChances() == 1 and self.finalNum == 0) then
					for n = 1, 9 do
						if (self.chances[n]) then
							self:setFinal(n)
						end
					end
				end
			end

			square.tap = function(self)
				if not (isSolving) then
					openTileSetupMenuGroup(self)
				end
			end
			square:addEventListener("tap",square)

			board[y][x] = square
			boardGroup:insert(board[y][x])
		end
	end

end

function initPuzzle(index)
	for y = 1, 9 do for x = 1,9 do
		if (puzzles[index][y][x] ~= 0) then
			board[y][x]:setStaticFinal(puzzles[index][y][x])
		end
	end end
end

function openTileSetupMenuGroup(tile)
	if not (tileSetupMenuGroup and isSolving) then
		if (tile.finalNum ~= 0) then
			tile:reset()
			tile:hideChances()
		else
			boardGroup.isVisible = false
			boardSetupMenuGroup.isVisible = false

			tileSetupMenuGroup=display.newGroup()

			local positionText=display.newText(("Modifying tile "..tile.tileX..","..tile.tileY),0,0,native.systemFont,30)
			positionText.x=display.contentCenterX
			positionText.y=display.contentHeight-130
			tileSetupMenuGroup:insert(positionText)
			
			local cancelbtn=display.newRect(0,0,150,50)
			cancelbtn.x=display.contentWidth*0.5
			cancelbtn.y=display.contentHeight-65
			cancelbtn:setFillColor(0.7,0.7,0.7)
			cancelbtn:addEventListener("tap",closeTileSetupMenuGroup)
			tileSetupMenuGroup:insert(cancelbtn)
			
			local canceltxt=display.newText("Cancel",0,0,native.systemFont,20)
			canceltxt.x=cancelbtn.x
			canceltxt.y=cancelbtn.y
			canceltxt:setTextColor(0,0,0)
			tileSetupMenuGroup:insert(canceltxt)
			
			local numsquares={}
			local numsquarestxt={}
			for n = 1,9 do
				function changeval()
					tile:setStaticFinal(n)
					timer.performWithDelay(200,closeTileSetupMenuGroup)
				end
			
				numsquares[n]=display.newRect(0,0,75,75)
				numsquares[n].x=display.contentCenterX+((((n-1)%3)-1)*90)
				numsquares[n].y=display.contentCenterY+(((math.floor((n-1)/3))-1.85)*90)
				numsquares[n]:setFillColor(0.7,0.7,0.7)
				numsquares[n]:addEventListener("tap",changeval)
				tileSetupMenuGroup:insert(numsquares[n])
				
				numsquarestxt[n]=display.newText(n,0,0,native.systemFont,90)
				numsquarestxt[n].x=numsquares[n].x
				numsquarestxt[n].y=numsquares[n].y
				numsquarestxt[n]:setTextColor(0,0,0)
				tileSetupMenuGroup:insert(numsquarestxt[n])
			end
			
			tileSetupMenuGroup:toFront()
		end
	end
end

function closeTileSetupMenuGroup() 
	display.remove(tileSetupMenuGroup)
	tileSetupMenuGroup = nil
	boardGroup.isVisible = true
	boardSetupMenuGroup.isVisible = true
end

function openSolvingMenuGroup()
	if not (solvingMenuGroup) then
		solvingMenuGroup=display.newGroup()

		local midW = display.contentCenterX
		local allY = display.contentHeight

		local bkg=display.newRect(midW,allY-100,midW*1.75, 80)
		bkg:setFillColor(1,1,1)
		solvingMenuGroup:insert(bkg)
		
		local labelDisplay = display.newText("",0,0,native.systemFont,20)
		labelDisplay.x = midW
		labelDisplay.y = allY-115
		labelDisplay:setFillColor(0,0,0)
		solvingMenuGroup:insert(labelDisplay)

		local tapAction = display.newText("Tap to pause",0,0,native.systemFont,12)
		tapAction.x = midW
		tapAction.y = allY-70
		tapAction:setFillColor(0.6,0.6,0.6)
		solvingMenuGroup:insert(tapAction)

		solvingMenuGroup.setLabel = function(self, message)
			labelDisplay.text = message
		end

		solvingMenuGroup.changeAction = function(self, action)
			tapAction.text = "Tap to "..action
		end

		solvingMenuGroup:toFront()
	end
end

function setMessage(text)
	if (solvingMenuGroup) then
		solvingMenuGroup:setLabel(text)
	end
end

function setAction(action)
	if (solvingMenuGroup) then
		solvingMenuGroup:changeAction(action)
	end
end

function closeSolvingMenuGroup()
	display.remove(solvingMenuGroup)
	solvingMenuGroup = nil
end

function attemptSolve()
	if (isValid()) then
		history = { }
		isSolving = true
		boardSetupMenuGroup.isVisible = false
		currentProcess = 1
		isPaused = false
		currentAction = ACTION_PAUSE
		Runtime:addEventListener("tap",tapEvent)
		openSolvingMenuGroup()
		showAllChances()
		advanceProcess()
	end
end

function showAllChances()
	for y = 1, 9 do for x = 1, 9 do
		board[y][x]:showChances()
	end end
end

function hideAllChances()
	for y = 1, 9 do for x = 1, 9 do
		board[y][x]:hideChances()
	end end
end

function isValid()
	local foundMistake = false
	for y = 1,9 do for x = 1,9 do
		if (board[y][x]:isSolved()) then
			-- ROW CHECK
			for sx = 1, 9 do
				if (sx ~= x and board[y][sx]:isSolved()) then
					foundMistake = foundMistake or (board[y][sx].finalNum == board[y][x].finalNum)
				end
			end

			-- COL CHECK
			for sy = 1, 9 do
				if (sy ~= y and board[sy][x]:isSolved()) then
					foundMistake = foundMistake or (board[sy][x].finalNum == board[y][x].finalNum)
				end
			end

			-- QUAD CHECK
			local searchQ = board[y][x].quad

			local quadX = ((searchQ-1)%3)+1
			local quadY = math.floor((searchQ-1)/3)+1

			local startSearchX = ((quadX-1)*3)+1
			local endSearchX = quadX*3

			local startSearchY = ((quadY-1)*3)+1
			local endSearchY = quadY*3
			for sx = startSearchX, endSearchX do for sy = startSearchY, endSearchY do
				if (sy ~= y and sx ~= x and board[sy][sx]:isSolved()) then
					foundMistake = foundMistake or (board[sy][sx].finalNum == board[y][x].finalNum)
				end
			end end
		end
	end end
	return not foundMistake
end

function isValidEnhanced()
	local foundMistake = false
	for y = 1, 9 do for x = 1,9 do
		if (board[y][x]:getNumChances() == 0) then
			foundMistake = true
		end
	end end
	return isValid() and not foundMistake
end

function resetProcess()
	currentProcess = 1
end

function advanceProcess()
	if (not isValidEnhanced()) then
		if (table.maxn(history) == 0) then
			setMessage("Can't be solved.")
			setAction("go back")
			currentAction = ACTION_BACK
		else
			removeBruteForce()
		end
	elseif (isFull()) then
		setMessage("Done.")
		setAction("go back")
		currentAction = ACTION_BACK
	elseif not(isPaused) then
		local delay = 10
		local calls = {
			lineReduction, quadReduction, lineUniqueX, 
			lineUniqueY, quadUnique, quadChanceReductionX, 
			quadChanceReductionY, lineChanceReductionX,
			lineChanceReductionY, bruteForce
		}
		local callNames = {
			"Reducing by Lines", "Reducing by Quads",
			"Setting Uniques in X", "Setting Uniques in Y",
			"Setting Uniques in Quads", "Reducing by Quad X Chances",
			"Reducing by Quad Y Chances", "Reducing by Line X Chances",
			"Reducing by Line Y Chances", "Applying Brute Force"
		}
		currentProcess = currentProcess + 1
		setMessage(callNames[currentProcess-1])
		timer.performWithDelay(delay,calls[currentProcess-1])
	end
end

function tapEvent()
	if (currentAction == ACTION_BACK) then
		goDefault()
		boardSetupMenuGroup.isVisible = true
		closeSolvingMenuGroup()
		hideAllChances()
		Runtime:removeEventListener("tap",tapEvent)
	elseif (currentAction == ACTION_PAUSE) then
		setAction("unpause")
		setMessage("Solving paused.")
		currentAction = ACTION_UNPAUSE
		isPaused = true
	elseif (currentAction == ACTION_UNPAUSE) then
		setAction("pause")
		isPaused = false
		currentAction = ACTION_PAUSE
		advanceProcess()
	end
end

function isFull()
	local emptySpace = false
	for y = 1,9 do for x = 1,9 do
		if (board[y][x].finalNum == 0) then
			emptySpace = true
		end
	end end
	return not emptySpace
end

function quadPresence(quad)

	local counts = {0,0,0, 0,0,0, 0,0,0}
	
	local startSearchX = quadStartX(quad)
	local endSearchX = quadEndX(quad)

	local startSearchY = quadStartY(quad)
	local endSearchY = quadEndY(quad)

	for x = startSearchX, endSearchX do for y = startSearchY, endSearchY do
		if (board[y][x].finalNum == 0) then
			for n = 1, 9 do
				if (board[y][x].chances[n]) then
					counts[n] = counts[n] + 1
				end
			end
		end
	end end
		
	return counts
end

function linePresenceX(x)
	-- COUNT PRESENCE OF NUMBER
	local counts = {0,0,0, 0,0,0, 0,0,0}

	for y = 1, 9 do
		if (board[y][x].finalNum == 0) then
			for n = 1, 9 do
				if (board[y][x].chances[n]) then
					counts[n] = counts[n] + 1
				end
			end
		end
	end
	return counts
end

function linePresenceY(y)
	-- COUNT PRESENCE OF NUMBER
	local counts = {0,0,0, 0,0,0, 0,0,0}
	for x = 1, 9 do
		if (board[y][x].finalNum == 0) then
			for n = 1, 9 do
				if (board[y][x].chances[n]) then
					counts[n] = counts[n] + 1
				end
			end
		end
	end
	return counts
end

function quadStartX(quad)
	local quadX = ((quad-1)%3)+1
	return (((quadX-1)*3)+1)
end

function quadEndX(quad)
	local quadX = ((quad-1)%3)+1
	return (quadX*3)
end

function quadStartY(quad)
	local quadY = math.floor((quad-1)/3)+1
	return (((quadY-1)*3)+1)
end

function quadEndY(quad)
	local quadY = math.floor((quad-1)/3)+1
	return (quadY*3)
end

function lineReduction()
	for y=1,9 do for x=1,9 do
		if (board[y][x]:isSolved()) then
			local chance = board[y][x].finalNum

			-- ROW CHECK
			for sx = 1, 9 do
				if (x ~= sx) then
					board[y][sx]:removeChance(chance)
				end
			end

			-- COL CHECK
			for sy = 1, 9 do
				if (y ~= sy) then
					board[sy][x]:removeChance(chance)
				end
			end
		end
	end end
	advanceProcess()
end

function quadReduction()
	for y=1,9 do for x=1,9 do
		if (board[y][x]:isSolved()) then
			local chance = board[y][x].finalNum
			-- QUAD CHECK
			local searchQ = board[y][x].quad

			local quadX = ((searchQ-1)%3)+1
			local quadY = math.floor((searchQ-1)/3)+1

			local startSearchX = ((quadX-1)*3)+1
			local endSearchX = quadX*3

			local startSearchY = ((quadY-1)*3)+1
			local endSearchY = quadY*3
			for sx = startSearchX, endSearchX do for sy = startSearchY, endSearchY do
				if (sy ~= y and sx ~= x) then
					board[sy][sx]:removeChance(chance)
				end
			end end
		end
	end end
	advanceProcess()
end

function lineUniqueX()
	for x = 1, 9 do
		local counts = linePresenceX(x)
		
		-- CHECK UNIQUENESS
		for n = 1, 9 do
			if (counts[n] == 1) then
				for y = 1, 9 do
					if (board[y][x].chances[n]) then
						board[y][x]:setFinal(n)
					end
				end
			end
		end
	end
	advanceProcess()
end

function lineUniqueY()
	for y = 1, 9 do
		local counts = linePresenceY(y)

		-- CHECK UNIQUENESS
		for n = 1, 9 do 
			if (counts[n] == 1) then
				for x = 1, 9 do
					if (board[y][x].chances[n]) then
						board[y][x]:setFinal(n)
					end
				end
			end
		end
	end
	advanceProcess()
end

function quadUnique()
	for quad = 1, 9 do
		-- COUNT PRESENCE OF NUMBER
		local counts = quadPresence(quad)
	
		local startSearchX = quadStartX(quad)
		local endSearchX = quadEndX(quad)

		local startSearchY = quadStartY(quad)
		local endSearchY = quadEndY(quad)
		
		-- CHECK UNIQUENESS
		for n = 1, 9 do 
			if (counts[n] == 1) then
				for x = startSearchX, endSearchX do for y = startSearchY, endSearchY do
					if (board[y][x].chances[n]) then
						board[y][x]:setFinal(n)
					end
				end end
			end
		end
	end
	advanceProcess()
end

function quadChanceReductionX()
	for quad = 1, 9 do 
		-- COUNT PRESENCE OF NUMBER
		local counts = quadPresence(quad)
	
		local startSearchX = quadStartX(quad)
		local endSearchX = quadEndX(quad)

		local startSearchY = quadStartY(quad)
		local endSearchY = quadEndY(quad)
		
		-- CHECK UNIQUENESS
		for n = 1, 9 do
			if (counts[n] == 2 or counts[n] == 3) then
				for qx = startSearchX, endSearchX do
					local count = 0
					for qy = startSearchY, endSearchY do
						if (board[qy][qx].chances[n]) then
							count = count + 1
						end
					end
					if (count == counts[n]) then
						for y = 1, 9 do
							if (board[y][qx].quad ~= quad) then
								board[y][qx]:removeChance(n)
							end
						end
					end
				end
			end
		end
	end
	advanceProcess()
end

function quadChanceReductionY()
	for quad = 1, 9 do 
		-- COUNT PRESENCE OF NUMBER
		local counts = quadPresence(quad)
	
		local startSearchX = quadStartX(quad)
		local endSearchX = quadEndX(quad)

		local startSearchY = quadStartY(quad)
		local endSearchY = quadEndY(quad)
		
		-- CHECK UNIQUENESS
		for n = 1, 9 do 
			if (counts[n] == 2 or counts[n] == 3) then
				for qy = startSearchY, endSearchY do
					local count = 0
					for qx = startSearchX, endSearchX do
						if (board[qy][qx].chances[n]) then
							count = count + 1
						end
					end
					if (count == counts[n]) then
						for x = 1, 9 do
							if (board[qy][x].quad ~= quad) then
								board[qy][x]:removeChance(n)
							end
						end
					end
				end
			end
		end
	end
	advanceProcess()
end

function lineChanceReductionX()
	for x = 1, 9 do
		local counts = linePresenceX(x)
		for n = 1, 9 do
			if (counts[n] == 2 or counts[n] == 3) then

				local count = 0
				
				for y = 1, 9 do
					if (board[y][x].chances[n]) then
						count = count + 1
					end

					if (count == counts[n]) then
					
						local quad = board[y][x].quad
						
						local startSearchX = quadStartX(quad)
						local endSearchX = quadEndX(quad)

						local startSearchY = quadStartY(quad)
						local endSearchY = quadEndY(quad)

						for qx = startSearchX, endSearchX do for qy = startSearchY, endSearchY do
							if (qx ~= x) then
								board[qy][qx]:removeChance(n)
							end
						end end
					end

					if (y%3 == 0) then
						count = 0
					end
				end
				
			end
		end
	end
	advanceProcess()
end

function lineChanceReductionY()
	for y = 1, 9 do
		local counts = linePresenceY(y)
		for n = 1, 9 do
			if (counts[n] == 2 or counts[n] == 3) then

				local count = 0
				
				for x = 1, 9 do
					if (board[y][x].chances[n]) then
						count = count + 1
					end

					if (count == counts[n]) then
						-- print ("Y "..y)
						-- print ("N "..n)
						local quad = board[y][x].quad
						-- print ("QUAD "..quad)
						local startSearchX = quadStartX(quad)
						local endSearchX = quadEndX(quad)

						local startSearchY = quadStartY(quad)
						local endSearchY = quadEndY(quad)

						for qy = startSearchY, endSearchY do for qx = startSearchX, endSearchX do
							if (qy ~= y) then
								board[qy][qx]:removeChance(n)
							end
						end end
					end

					if (x%3 == 0) then
						count = 0
					end
				end
				
			end
		end
	end
	advanceProcess()
end

function bruteForce()
	local nextTry = table.maxn(history)+1
	local x = 1
	local y = 1
	while (history[nextTry] == nil and x <= 9 and y <= 9) do
		if (board[y][x]:getNumChances() == 2) then
			local try = {}
			try.x = x
			try.y = y
			try.chances = {}
			for n = 1, 9 do
				if (board[y][x].chances[n]) then
					try.chances[table.maxn(try.chances)+1] = n
				end
			end
			history[nextTry] = try
		end
		x = x + 1
		if (x == 10) then
			y = y + 1
			x = 1
		end
	end
	if (history[nextTry] ~= nil) then
		local y = history[nextTry].y
		local x = history[nextTry].x
		local n = history[nextTry].chances[1]
		board[y][x]:setGuess(n)
		advanceProcess()
	else
		-- help
	end
end

function removeBruteForce()
	local y = history[table.maxn(history)].y
	local x = history[table.maxn(history)].x
	local n = history[table.maxn(history)].chances[1]
	local m = history[table.maxn(history)].chances[2]
	if (board[y][x].finalNum == n) then
		board[y][x]:setGuess(m)
		goGuesses()
		advanceProcess()
	elseif (board[y][x].finalNum == m) then
		board[y][x]:reset()
		history[table.maxn(history)] = nil
		removeBruteForce()
	end
end

function goGuesses()
	for y = 1, 9 do for x = 1, 9 do
		if not(board[y][x].isStaticFinal or board[y][x].isGuess) then
			board[y][x]:reset()
		end
	end end
end

function goDefault()
	for y = 1, 9 do for x = 1, 9 do
		if (not board[y][x].isStaticFinal) then
			board[y][x]:reset()
		end
	end end
end

function goBlank()
	for y = 1, 9 do for x = 1, 9 do
			board[y][x]:reset()
	end end
end

function resetSudoku()
	goBlank()
	hideAllChances()
end
