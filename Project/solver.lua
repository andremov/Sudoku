-----------------------------------------------------------------------------------------
--
-- solver.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)

-- NEW VARS
local board
local isSolving
local tileSetupMenuGroup
local boardSetupMenuGroup
local currentProcess

-- OLD VARS
local setup={

		0,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		
		0,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		
		0,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		0,0,0, 0,0,0, 0,0,0,
		
		-- 1,0,0, 0,0,7, 0,9,0, 
		-- 0,3,0, 0,2,0, 0,0,8,
		-- 0,0,9, 6,0,0, 5,0,0,
		
		-- 0,0,5, 3,0,0, 9,0,0,
		-- 0,1,0, 0,8,0, 0,0,2,
		-- 6,0,0, 0,0,4, 0,0,0,
		
		-- 3,0,0, 0,0,0, 0,1,0,
		-- 0,4,0, 0,0,0, 0,0,7,
		-- 0,0,7, 0,0,0, 3,0,0,
		
		
		-- 8,0,0, 0,0,0, 0,0,0,
		-- 0,0,3, 6,0,0, 0,0,0,
		-- 0,7,0, 0,9,0, 2,0,0,
		
		-- 0,5,0, 0,0,7, 0,0,0,
		-- 0,0,0, 0,4,5, 7,0,0,
		-- 0,0,0, 1,0,0, 0,3,0,
		
		-- 0,0,1, 0,0,0, 0,6,8,
		-- 0,0,8, 5,0,0, 0,1,0,
		-- 0,9,0, 0,0,0, 4,0,0,
		
		
		-- 1,6,0, 0,9,0, 0,0,0,
		-- 0,0,9, 0,0,0, 0,0,2,
		-- 0,0,0, 0,0,2, 0,0,0,
		
		-- 9,0,0, 0,8,1, 0,0,0,
		-- 0,0,0, 2,0,0, 0,0,7,
		-- 0,0,0, 0,6,0, 0,3,0,
		
		-- 0,0,7, 3,0,4, 0,0,6,
		-- 0,0,0, 6,0,0, 8,0,0,
		-- 4,0,0, 0,0,9, 5,0,0,
	}
	
-- local tile={}
local done={}
local xySpread={}
local xLines={}
local yLines={}
local xDust={}
local yDust={}
local areaSpread={}
local areaTiles={}
local unqLineSpread=false
local unqQuadSpread=false
local flying=false
local magicSpread={}
local xPosLines={}
local yPosLines={}
local process=1
local isWrong=false
local ogre={}
local bfOrder={}
local smash=false
local selected={1,1}
local nums2choose
local texts2choose
local processdisplay={}
local started
local interrupt=false

function init()
	initBoard()
	initUI()
end

function initUI()
	boardSetupMenuGroup = display.newGroup()

	local midW = display.contentCenterX

	local resetBtn=display.newRect(0,0,210,40)
	resetBtn.x=midW
	resetBtn.y=display.contentHeight-70
	resetBtn:setFillColor(0.8,0.5,0.5)
	-- resetBtn:addEventListener("tap",prevStep)
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

end

function initBoard()

	board = { }
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

			square.setFinal = function(self, num)
				self.finalNum = num
				self.finalDisplay.text = num
				self.finalDisplay:setFillColor(0,0,0.7)
				square.isStaticFinal = false
				resetProcess()
				for n = 1, 9 do
					if (n ~= num) then
						self.chances[n] = false
					end
					self.chancesDisplay[n].text = ""
				end
			end

			square.removeChance = function(self, index)
				self.chances[index] = false
				self.chancesDisplay[index].text = ""
				self:checkUnique()
			end

			square.reset = function(self)
				self.finalNum = 0
				self.finalDisplay.text = ""
				self.finalDisplay:setFillColor(0,0,0)
				square.isStaticFinal = false
				for n = 1, 9 do
					self.chances[n] = true
					self.chancesDisplay[n].text = ""
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
		end
	end

end

function openTileSetupMenuGroup(tile)
	if not (tileSetupMenuGroup) then
		if (tile.finalNum ~= 0) then
			tile:reset()
		else
			tileSetupMenuGroup=display.newGroup()
			
			local bkg=display.newRect(display.contentCenterX,display.contentCenterY,display.contentWidth,display.contentHeight)
			bkg:setFillColor(0,0,0,0.9)
			tileSetupMenuGroup:insert(bkg)

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
					timer.performWithDelay(100,closeTileSetupMenuGroup)
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
end

function attemptSolve()
	if (isValid()) then
		boardSetupMenuGroup.isVisible = false
		currentProcess = 1
		displayAllChances()
		advanceProcess()
	end
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

function displayAllChances()
	for y = 1, 9 do for x = 1, 9 do
		board[y][x]:showChances()
	end end
end

function resetProcess()
	currentProcess = 1
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

function advanceProcess()
	if (not isValidEnhanced()) then
		print "invalid"
		cleanNonStatics()
		boardSetupMenuGroup.isVisible = true
	else
		currentProcess = currentProcess + 1
		if (currentProcess == 2) then
			timer.performWithDelay(300,lineReduction)
		elseif (currentProcess == 3) then
			-- timer.performWithDelay(100,quadReduction)
		end
	end
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

function cleanNonStatics()
	for y = 1, 9 do for x = 1, 9 do
		if (not board[y][x].isStaticFinal) then
			board[y][x]:reset()
		end
		board[y][x]:hideChances()
	end end
end

-- OLD FUNCS

function acceptNum()
	local tilex=selected[1]
	local tiley=selected[2]
	local danum=tonumber(newvalnum.text)
	local oldnum=tonumber(curvalnum.text)
	if oldnum~=0 then
		display.remove(tile[tilex][tiley].num[oldnum])
		tile[tilex][tiley].num[oldnum]=nil
	end
	setup[((selected[2]-1)*9)+selected[1]]=danum
	if danum~=0 then
		tile[tilex][tiley].num[danum]=display.newText(danum,0,0,native.systemFont,40)
		tile[tilex][tiley].num[danum].x=tile[tilex][tiley].x
		tile[tilex][tiley].num[danum].y=tile[tilex][tiley].y
		tile[tilex][tiley].num[danum]:setTextColor(0,0,0)
	end
	
	chooseMenu()
end

function Display()
	started=true
	for x=1,9 do
		areaTiles[x]={}
		xLines[x]={false,false,false, false,false,false, false,false,false}
		yLines[x]={false,false,false, false,false,false, false,false,false}
		xDust[x]={0,0,0, 0,0,0, 0,0,0}
		yDust[x]={0,0,0, 0,0,0, 0,0,0}
		yPosLines[x]={false,false,false, false,false,false, false,false,false}
		xPosLines[x]={false,false,false, false,false,false, false,false,false}
		-- tile[x]={}
		done[x]={}
		ogre[x]={}
		xySpread[x]={}
		magicSpread[x]={}
		areaSpread[x]={}
		for y=1,9 do
			tile[x][y]:removeEventListener("tap",selectTile)
			-- tile[x][y]
			ogre[x][y]={false,false,false, false,false,false, false,false,false}
			xySpread[x][y]=false
			magicSpread[x][y]=false
			areaSpread[x][y]=false
			areaTiles[x][y]=false
			
			-- print ("("..x..","..y..")".." - "..tile[x][y].quad)
			-- tile[x][y].t=display.newText(("("..x..","..y..")"),0,0,native.systemFont,15)
			-- tile[x][y].t.x=tile[x][y].x
			-- tile[x][y].t.y=tile[x][y].y
			-- tile[x][y].t:setTextColor(1,0,0)
			
			if setup[((y-1)*9)+x]==0 then
				for n=1,9 do
					tile[x][y].num[n]=display.newText(n,0,0,native.systemFont,10)
					tile[x][y].num[n].x=tile[x][y].x+(((n-1)%3)*10)-10
					tile[x][y].num[n].y=tile[x][y].y+(math.floor((n-1)/3)*10)-10
					tile[x][y].num[n]:setTextColor(0,0,1)
				end
				done[x][y]=false
			else
				done[x][y]=true
			end
		end
	end
	
	Runtime:addEventListener("enterFrame",updateCount)
	
	function doInt()
		interrupt=true
	end
	
	squarei=display.newRect(0,0,40,40)
	squarei.x=30
	squarei.y=display.contentHeight-140
	squarei:setFillColor(0.7,0.7,0.7)
	squarei:addEventListener("tap",doInt)
	
	texti=display.newText("X",0,0,native.systemFont,50)
	texti.x=squarei.x
	texti.y=squarei.y
	texti:setTextColor(0,0,0)
	
	
	timer.performWithDelay(250,doneCheck)
end

function updateCount()
	if not (bfcount) then
		bfcount=display.newText(#bfOrder,0,0,native.systemFont,50)
		bfcount.x=processdisplay[7].x+40
		bfcount.y=processdisplay[7].y+20
	else
		bfcount.text=#bfOrder
	end
end 

function doneCheck()
	if interrupt==false then
	local finished=true
	local finished2=true
	local finished3=true
	local finished4=true
	local finished5=true
	local finished6=true
	local finished7=true
	local finished8=true
	for x=1,9 do
		for y=1,9 do
			if done[x][y]==false then
				finished=false
				-- print ("("..x..","..y..") -- UnDone")
				if magicSpread[x][y]==false then
					finished6=false
					for i=5,table.maxn(processdisplay) do
						processdisplay[i]:setFillColor(0.6,0.6,0.6)
					end
					-- print ("("..x..","..y..") -- UnMagic")
				end
			else
				if xySpread[x][y]==false then
					finished2=false
					for i=1,table.maxn(processdisplay) do
						processdisplay[i]:setFillColor(0.6,0.6,0.6)
					end
					-- print ("("..x..","..y..") -- UnSpread")
				end
				if areaSpread[x][y]==false then
					finished3=false
					for i=2,table.maxn(processdisplay) do
						processdisplay[i]:setFillColor(0.6,0.6,0.6)
					end
					-- print ("("..x..","..y..") -- UnAreaSpread")
				end
			end
		end
	end
	if unqQuadSpread==false then
		finished4=false
		for i=3,table.maxn(processdisplay) do
			processdisplay[i]:setFillColor(0.6,0.6,0.6)
		end
	end
	if unqLineSpread==false then
		finished5=false
		for i=4,table.maxn(processdisplay) do
			processdisplay[i]:setFillColor(0.6,0.6,0.6)
		end
	end
	if flying==false then
		finished7=false
		for i=6,table.maxn(processdisplay) do
			processdisplay[i]:setFillColor(0.6,0.6,0.6)
		end
	end
	if smash==false then
		finished8=false
		for i=7,table.maxn(processdisplay) do
			processdisplay[i]:setFillColor(0.6,0.6,0.6)
		end
	end
	if finished==false then
		process=0
		if finished2==true then
			processdisplay[1]:setFillColor(0,1,0)
			if finished3==true then
				processdisplay[2]:setFillColor(0,1,0)
				if finished4==true then
					processdisplay[3]:setFillColor(0,1,0)
					if finished5==true then
						processdisplay[4]:setFillColor(0,1,0)
						if finished6==true then
							processdisplay[5]:setFillColor(0,1,0)
							if finished7==true then
								processdisplay[6]:setFillColor(0,1,0)
								if finished8==true then
									processdisplay[7]:setFillColor(0,1,0)
									-- print "!!"
								elseif finished8==false then
									processdisplay[7]:setFillColor(0,0,1)
									process=7
								end
							elseif finished7==false then
								processdisplay[6]:setFillColor(0,0,1)
								process=6
							end
						elseif finished6==false then
							processdisplay[5]:setFillColor(0,0,1)
							process=5
						end
					elseif finished5==false then
						processdisplay[4]:setFillColor(0,0,1)
						process=4
					end
				elseif finished4==false then
					processdisplay[3]:setFillColor(0,0,1)
					process=3
				end
			elseif finished3==false then
				processdisplay[2]:setFillColor(0,0,1)
				process=2
			end
		elseif finished2==false then
			processdisplay[1]:setFillColor(0,0,1)
			process=1
		end
		
		-- print (process)
		
			
			textmain.text=""
			textline1.text=""
			textline2.text=""
		if process==1 then
			textline1.text="OPCIONES"
			textline2.text="EN LINEA"
			timer.performWithDelay(100,tileSelect)
		elseif process==2 then
			textline1.text="OPCIONES"
			textline2.text="EN CUADRANTE"
			timer.performWithDelay(100,areaSelect)
		elseif process==3 then
			textline1.text="UNICO"
			textline2.text="EN CUADRANTE"
			timer.performWithDelay(100,quadSelect)
		elseif process==4 then
			textline1.text="UNICO"
			textline2.text="EN LINEA"
			timer.performWithDelay(100,lineSelect)
		elseif process==5 then
			textmain.text="MAGIA NEGRA!"
			timer.performWithDelay(100,magicSelect)
		elseif process==6 then
			textline1.text="POLVO DE"
			textline2.text="HADAS!"
			timer.performWithDelay(100,dustSelect)
		elseif process==7 then
			textline1.text="FUERZA BRUTA"
			textline2.text="NOJODA"
			timer.performWithDelay(250,bruteSelect)
		else
			print "NO PUDE MAS"
			textmain.text="NO PUDE MK"
			textline1.text=""
			textline2.text=""
	
			display.remove(squarei)
			squarei=nil
			
			display.remove(texti)
			texti=nil
	
			Runtime:addEventListener("tap",ShamWow)
			
			-- print "GO AGAIN"
			-- mrClean()
			-- doneCheck()
		end
	else
	
		textmain.text="PERA Y REVISO"
		textline1.text=""
		textline2.text=""
		-- revise()
		timer.performWithDelay(250,revise)
	end
	else
		interrupt=false
	
		function back1()
			ShamWow()
			display.remove(square1)
			display.remove(text1)
			display.remove(square2)
			display.remove(text2)
			display.remove(squarei)
			display.remove(texti)
			squarei=nil
			texti=nil
			square1=nil
			text1=nil
			square2=nil
			text2=nil
		end
		
		function resume1()
			doneCheck()
			display.remove(square1)
			display.remove(text1)
			display.remove(square2)
			display.remove(text2)
			square1=nil
			text1=nil
			square2=nil
			text2=nil
		end
		
		square1=display.newRect(0,0,75,75)
		square1.x=display.contentCenterX*0.5
		square1.y=display.contentHeight-65
		square1:setFillColor(0.7,0.7,0.7)
		square1:addEventListener("tap",back1)
		
		text1=display.newText("Back",0,0,native.systemFont,20)
		text1.x=square1.x
		text1.y=square1.y
		text1:setTextColor(0,0,0)
		
		square2=display.newRect(0,0,75,75)
		square2.x=display.contentCenterX*1.5
		square2.y=display.contentHeight-65
		square2:setFillColor(0.7,0.7,0.7)
		square2:addEventListener("tap",resume1)
		
		text2=display.newText("Resume",0,0,native.systemFont,20)
		text2.x=square2.x
		text2.y=square2.y
		text2:setTextColor(0,0,0)
	end
end



function magicSelect()
	orderedPairs={}
	for q=1,9 do 
		orderedPairs[q]={0,0,0,0,0,0,0,0,0}
		orderedPairs[q].xQuads={}
		orderedPairs[q].yQuads={}
		for a=1,3 do
			orderedPairs[q].xQuads[a]={0,0,0, 0,0,0, 0,0,0}
			orderedPairs[q].yQuads[a]={0,0,0, 0,0,0, 0,0,0}
		end
	end
	
	for x=1,9 do for y=1,9 do
		local quadx=((x-1)%3)+1
		local quady=((y-1)%3)+1
		if done[x][y]==false then
			for n=1,9 do
				if (tile[x][y].num[n]) then
					if orderedPairs[tile[x][y].quad][n]~=false and orderedPairs[tile[x][y].quad][n]~=true then 
						orderedPairs[tile[x][y].quad][n]=orderedPairs[tile[x][y].quad][n]+1
						if orderedPairs[tile[x][y].quad].xQuads[quadx][n]~=false and 
						 orderedPairs[tile[x][y].quad].xQuads[quadx][n]~=true then
							orderedPairs[tile[x][y].quad].xQuads[quadx][n]=orderedPairs[tile[x][y].quad].xQuads[quadx][n]+1
						end
						if orderedPairs[tile[x][y].quad].yQuads[quady][n]~=false and 
						 orderedPairs[tile[x][y].quad].yQuads[quady][n]~=true then
							orderedPairs[tile[x][y].quad].yQuads[quady][n]=orderedPairs[tile[x][y].quad].yQuads[quady][n]+1
						end
					end
				else
					
				end
			end
		else
			for n=1,9 do
				if (tile[x][y].num[n]) then
					
					orderedPairs[tile[x][y].quad][n]=false
					orderedPairs[tile[x][y].quad].xQuads[quadx][n]=false
					orderedPairs[tile[x][y].quad].yQuads[quady][n]=false
				end
			end
		end
	end end
	
	for q=1,9 do
		for n=1,9 do
			if orderedPairs[q][n]~=2 and orderedPairs[q][n]~=3 then
				orderedPairs[q][n]=false
				for x=1,3 do
					orderedPairs[q].xQuads[x][n]=false
				end
				for y=1,3 do
					orderedPairs[q].yQuads[y][n]=false
				end
			else
				if orderedPairs[q][n]~=false then
					for x=1,3 do
						if orderedPairs[q].xQuads[x][n]==orderedPairs[q][n] then
							orderedPairs[q].xQuads[x][n]=true
						else
							orderedPairs[q].xQuads[x][n]=false
						end
					end
					for y=1,3 do
						if orderedPairs[q].yQuads[y][n]==orderedPairs[q][n] then
							orderedPairs[q].yQuads[y][n]=true
						else
							orderedPairs[q].yQuads[y][n]=false
						end
					end
				end
			end
		end
	end
	
	for x=1,9 do for y=1,9 do
			local quadx=((x-1)%3)+1
			local quady=((y-1)%3)+1
		for n=1,9 do
			if done[x][y]==false then
				if (orderedPairs[tile[x][y].quad].xQuads[quadx][n]~=false or 
					orderedPairs[tile[x][y].quad].yQuads[quady][n]~=false) and
					(tile[x][y].num[n]) then
				end
			end
		end
	end end
	
	local canDo=false
	for q=1,9 do
		for n=1,9 do
			if orderedPairs[q][n]~=false then
				canDo=true
			end
		end
	end
	
	for x=1,9 do for y=1,9 do
		local nomagic=true
		for n=1,9 do
		-- orderedpairs[q][n]
			if (tile[x][y].num[n]) then
				if orderedPairs[tile[x][y].quad][n]==true then
					nomagic=false
				end
			end
		end
		magicSpread[x][y]=nomagic
	end end
	if canDo==true then
		timer.performWithDelay(10,magicOptions)
	else
		timer.performWithDelay(1,Assign)		
	end
end

function magicOptions()
	local didChange=false
	for curx=1,9 do for cury=1,9 do
		if (tile[curx][cury]) then
			for n=1,9 do
				local sq=((math.ceil(tile[curx][cury].quad/3)-1)*3)+1
				for q=sq,sq+2 do
					if tile[curx][cury].quad~=q then
						if orderedPairs[q][n]~=false then
							local quady=((cury-1)%3)+1
							if orderedPairs[q].yQuads[quady][n]==true then
								if (tile[curx][cury].num[n]) then
									didChange=true
									display.remove (tile[curx][cury].num[n])
									tile[curx][cury].num[n]=nil
								end
							end
						end
					end
				end
				local sq=((tile[curx][cury].quad-1)%3)+1
				for q=sq,9,3 do
					if tile[curx][cury].quad~=q then
						if orderedPairs[q][n]~=false then
							local quadx=((curx-1)%3)+1
							if orderedPairs[q].xQuads[quadx][n]==true then
								if (tile[curx][cury].num[n]) then
									didChange=true
									display.remove (tile[curx][cury].num[n])
									tile[curx][cury].num[n]=nil
								end
							end
						end
					end
				end
			end
		end
	end end
	if didChange==true then
		mrClean()
	end
	for x=1,9 do for y=1,9 do
		magicSpread[x][y]=true
	end end
	timer.performWithDelay(100,Assign)
end

function dustSelect()

	xlineinfo={}
	ylineinfo={}
	for a=1,9 do
		ylineinfo[a]={0,0,0, 0,0,0, 0,0,0,}
		xlineinfo[a]={0,0,0, 0,0,0, 0,0,0,}
	end
	for y=1,9 do
		for x=1,9 do
			if done[x][y]==false then
				for n=1,9 do
					if (tile[x][y].num[n]) then
						xlineinfo[x][n]=xlineinfo[x][n]+1
						ylineinfo[y][n]=ylineinfo[y][n]+1
					end
				end
			end
		end
	end
	
	for x=1,9 do for n=1,9 do
		if xlineinfo[x][n]>4  or xlineinfo[x][n]==0 or xlineinfo[x][n]==1 then
			xlineinfo[x][n]=false
		end
		if xlineinfo[x][n]~=false then
			local selTiles={}
			for y=1,9 do
				if (tile[x][y].num[n]) then
					selTiles[#selTiles+1]={}
					selTiles[#selTiles].x=x
					selTiles[#selTiles].y=x
					selTiles[#selTiles].quad=tile[x][y].quad
				end
			end
			local canDo=true
			for a=1,table.maxn(selTiles) do
				local pasta=a-1
				if pasta==0 then
					pasta=table.maxn(selTiles)
				end
				if selTiles[a].quad~=selTiles[pasta].quad then
					canDo=false
				end
			end
			if canDo==false then
				xlineinfo[x][n]=false
			end
		end
	end end
	
	for y=1,9 do for n=1,9 do
		if ylineinfo[y][n]>4 or ylineinfo[y][n]==0 or ylineinfo[y][n]==1 then
			ylineinfo[y][n]=false
		end
		if ylineinfo[y][n]~=false then
			local selTiles={}
			for x=1,9 do
				if (tile[x][y].num[n]) then
					selTiles[#selTiles+1]={}
					selTiles[#selTiles].x=x
					selTiles[#selTiles].y=y
					selTiles[#selTiles].quad=tile[x][y].quad
				end
			end
			local canDo=true
			for a=1,table.maxn(selTiles) do
				local pasta=a-1
				if pasta==0 then
					pasta=table.maxn(selTiles)
				end
				if selTiles[a].quad~=selTiles[pasta].quad then
					canDo=false
				end
			end
			if canDo==false then
				ylineinfo[y][n]=false
			end
		end
	end end
	
	local canDo=false
	for a=1,9 do
		for n=1,9 do
			if xlineinfo[a][n]~=false then
				-- print ("IN X LINE "..a.." NUMBER "..n.." WITH "..xlineinfo[a][n].." POSSIBILITIES")
				canDo=true
			end
			if ylineinfo[a][n]~=false then
				-- print ("IN Y LINE "..a.." NUMBER "..n.." WITH "..ylineinfo[a][n].." POSSIBILITIES")
				canDo=true
			end
		end
	end
	
	if canDo==true then
		timer.performWithDelay(10,dustOptions)
	else
		flying=true
		timer.performWithDelay(1,Assign)		
	end
end

function dustOptions()
	local didChange=false
	for curx=1,9 do for cury=1,9 do
		if (tile[curx][cury]) then
			if done[curx][cury]==false then
			for n=1,9 do
				if (tile[curx][cury].num[n]) then
					if xlineinfo[curx][n]~=false then
						for x=1,9 do for y=1,9 do
							if tile[x][y].quad==tile[curx][cury].quad then
								if x~=curx then
									didChange=true
									display.remove (tile[x][y].num[n])
									tile[x][y].num[n]=nil
								end
							end
						end end
					end
					if ylineinfo[cury][n]~=false then
						for x=1,9 do for y=1,9 do
							if tile[x][y].quad==tile[curx][cury].quad then
								if y~=cury then
									didChange=true
									display.remove (tile[x][y].num[n])
									tile[x][y].num[n]=nil
								end
							end
						end end
					end
				end
			end
			end
		end
	end end
	if didChange==true then
		mrClean()
	end
	flying=true
	timer.performWithDelay(100,Assign)
end

function bruteSelect()

	brutePos={}
	for x=1,9 do
		brutePos[x]={}
		for y=1,9 do
			brutePos[x][y]=0
			for n=1,9 do
				if tile[x][y].num[n] then
					brutePos[x][y]=brutePos[x][y]+1
				end
			end
		end
	end
	local canDo=false
	for x=1,9 do for y=1,9 do
		if brutePos[x][y]==2 then
			brutePos[x][y]=true
			canDo=true
		else
			brutePos[x][y]=false
		end
	end end
	
	if canDo==true then
		timer.performWithDelay(10,bruteOptions)
	else
		smash=true
		timer.performWithDelay(1,Assign)		
	end
end

function bruteOptions()
	local didChange=false
	local xChange
	local yChange
	for curx=1,9 do for cury=1,9 do
		if (tile[curx][cury]) then
			if done[curx][cury]==false and brutePos[curx][cury]==true then
			for n=1,9 do
				if (tile[curx][cury].num[n]) then
					if didChange==false then
							print ("("..curx..","..cury..") -- INCEPTION LEVEL "..#bfOrder+1 .." - POSSIBLE "..n.." PLACED")
							display.remove(tile[curx][cury].num[n])
							tile[curx][cury].num[n]=nil
							bfOrder[#bfOrder+1]={curx,cury,n}
							
							tile[curx][cury].num[n]=display.newText(n,0,0,native.systemFont,40)
							tile[curx][cury].num[n].x=tile[curx][cury].x
							tile[curx][cury].num[n].y=tile[curx][cury].y
							tile[curx][cury].num[n]:setTextColor(0,1,0)
							done[curx][cury]=true
							clean()
							didChange=true
							xChange=curx
							yChange=cury
					elseif xChange==curx and yChange==cury then
						display.remove(tile[curx][cury].num[n])
						tile[curx][cury].num[n]=nil
						bfOrder[#bfOrder][4]=n
						-- print ("OTHER POSSIBILITY - "..n)
					end
				end
			end
			end
		end
	end end
	if didChange==true then
		mrClean()
	end
	smash=true
	timer.performWithDelay(100,Assign)
	-- Runtime:addEventListener("tap",Assign)
end

function reduceBrutes()
	-- Runtime:removeEventListener("tap",reduceBrutes)
	if table.maxn(bfOrder)==0 then
		print "IMPOSSIBLE (?)"
		textmain.text=""
		textline1.text="ESTA CAGA"
		textline2.text="NO SE PUEDE"
	
		display.remove(squarei)
		squarei=nil
		
		display.remove(texti)
		texti=nil
		
		Runtime:addEventListener("tap",ShamWow)
	else
		-- bfOrder[#bfOrder+1]={curx,cury,n}
		local tilex=bfOrder[#bfOrder][1]
		local tiley=bfOrder[#bfOrder][2]
		local oldnum=bfOrder[#bfOrder][3]
		local newnum=bfOrder[#bfOrder][4]
		print ("INCEPTION LEVEL "..#bfOrder.." - NUM1 "..tostring(oldnum)..", NUM2 "..newnum)
		-- for n=1,9 do
			-- if (tile[tilex][tiley].num[n]) then
				-- print (n)
			-- end
		-- end
		if (oldnum==false) then
			-- print "WENT BACK ONE"
			-- print (#bfOrder)
			bfOrder[#bfOrder]=nil
			-- print (#bfOrder)
			reduceBrutes()
		else
			for x=1,9 do for y=1,9 do
				if setup[((y-1)*9)+x]==0 then
					for n=1,9 do
						display.remove(tile[x][y].num[n])
						tile[x][y].num[n]=nil
					end
					if (tile[x][y].num[10]) then
						display.remove(tile[x][y].num[10])
						tile[x][y].num[10]=nil
					end
					local notForce=true
					for bf=1,table.maxn(bfOrder) do
						if x==bfOrder[bf][1] and y==bfOrder[bf][2] then
							notForce=false
						end
					end
					if notForce==true then
						for n=1,9 do
							tile[x][y].num[n]=display.newText(n,0,0,native.systemFont,10)
							tile[x][y].num[n].x=tile[x][y].x+(((n-1)%3)*10)-10
							tile[x][y].num[n].y=tile[x][y].y+(math.floor((n-1)/3)*10)-10
							tile[x][y].num[n]:setTextColor(0,0,1)
						end
					end
					done[x][y]=false
				end 
			end end
		
			for bf=1,table.maxn(bfOrder) do
				local tilex2=bfOrder[bf][1]
				local tiley2=bfOrder[bf][2]
				local oldnum2=bfOrder[bf][3]
				local newnum2=bfOrder[bf][4]
				if tilex2==tilex and tiley2==tiley then
					for n=1,9 do
						display.remove(tile[tilex2][tiley2].num[n])
						tile[tilex2][tiley2].num[n]=nil
					end
					bfOrder[bf][3]=false
					tile[tilex2][tiley2].num[newnum]=display.newText(newnum,0,0,native.systemFont,40)
					tile[tilex2][tiley2].num[newnum].x=tile[tilex2][tiley2].x
					tile[tilex2][tiley2].num[newnum].y=tile[tilex2][tiley2].y
					tile[tilex2][tiley2].num[newnum]:setTextColor(0,1,0)
					done[tilex2][tiley2]=true
				else
					if oldnum2==false then
						tile[tilex2][tiley2].num[newnum2]=display.newText(newnum2,0,0,native.systemFont,40)
						tile[tilex2][tiley2].num[newnum2].x=tile[tilex2][tiley2].x
						tile[tilex2][tiley2].num[newnum2].y=tile[tilex2][tiley2].y
						tile[tilex2][tiley2].num[newnum2]:setTextColor(0,1,0)
						done[tilex2][tiley2]=true
					else
						tile[tilex2][tiley2].num[oldnum2]=display.newText(oldnum2,0,0,native.systemFont,40)
						tile[tilex2][tiley2].num[oldnum2].x=tile[tilex2][tiley2].x
						tile[tilex2][tiley2].num[oldnum2].y=tile[tilex2][tiley2].y
						tile[tilex2][tiley2].num[oldnum2]:setTextColor(0,1,0)
						done[tilex2][tiley2]=true
					end
					
				end
			end
		
		
			mrClean()
			print ("("..tilex..","..tiley..") -- REPLACED "..oldnum.." WITH "..newnum)
			-- Runtime:addEventListener("tap",doneCheck)
			doneCheck()
		end
	end
end

