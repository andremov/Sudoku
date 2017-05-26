-----------------------------------------------------------------------------------------
--
-- solver.lua
--
-----------------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )
system.setIdleTimer( false )


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
	
local tile={}
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

function initial()
	started=false
	for x=1,9 do
		tile[x]={}
		for y=1,9 do
			tile[x][y]=display.newRect(0,0,30,30)
			tile[x][y].x=-2+	(x*31)+		((x-((x-1)%3))*2)
			tile[x][y].y=		(y*31)+		((y-((y-1)%3))*2)
			tile[x][y].num={}
			if setup[((y-1)*9)+x]~=0 then
				local danum=setup[((y-1)*9)+x]
				tile[x][y].num[danum]=display.newText(danum,0,0,native.systemFont,40)
				tile[x][y].num[danum].x=tile[x][y].x
				tile[x][y].num[danum].y=tile[x][y].y
				tile[x][y].num[danum]:setTextColor(0,0,0)
			end
			if x<4 then
				tile[x][y].quad=1
				if y<4 then
					-- tile[x][y].quad=tile[x][y].quad+1
				elseif y<7 then
					tile[x][y].quad=tile[x][y].quad+3
				else
					tile[x][y].quad=tile[x][y].quad+6
				end
			elseif x<7 then
				tile[x][y].quad=2
				if y<4 then
					-- tile[x][y].quad=tile[x][y].quad+1
				elseif y<7 then
					tile[x][y].quad=tile[x][y].quad+3
				else
					tile[x][y].quad=tile[x][y].quad+6
				end
			else
				tile[x][y].quad=3
				if y<4 then
					-- tile[x][y].quad=tile[x][y].quad+1
				elseif y<7 then
					tile[x][y].quad=tile[x][y].quad+3
				else
					tile[x][y].quad=tile[x][y].quad+6
				end
			end
			function selectTile()
				if not (icng) then
					-- print "!1"
					-- tile[selected[1]][selected[2]]:setFillColor(1,1,1)
					selected={x,y}
					chooseMenu()
					-- tile[selected[1]][selected[2]]:setFillColor(0,1,0)
				end
			end
			tile[x][y]:addEventListener("tap",selectTile)
		end
	end
	
	square=display.newRect(0,0,display.contentWidth-10,80)
	square.x=display.contentCenterX
	square.y=display.contentHeight-65
	
	textmain=display.newText("",0,0,native.systemFont,40)
	textmain.x=square.x
	textmain.y=square.y
	textmain:setTextColor(0,0,0)
	
	textline1=display.newText("",0,0,native.systemFont,40)
	textline1.x=square.x
	textline1.y=square.y-20
	textline1:setTextColor(0,0,0)
	
	textline2=display.newText("",0,0,native.systemFont,40)
	textline2.x=square.x
	textline2.y=square.y+20
	textline2:setTextColor(0,0,0)
	
	owner=display.newText("  Written By:\nAndres Movilla",0,0,native.systemFont,20)
	owner.x=square.x
	owner.y=display.contentHeight-130
	-- owner:setTextColor(0,0,0)
	
	for i=1,7 do
		processdisplay[i]=display.newRect(0,0,15,15)
		processdisplay[i].x=display.contentCenterX+((i-4)*30)
		processdisplay[i].y=display.contentHeight-160
		processdisplay[i]:setFillColor(0.6,0.6,0.6)
	end
	
	square1=display.newRect(0,0,75,75)
	square1.x=display.contentCenterX*0.5
	square1.y=display.contentHeight-65
	square1:setFillColor(0.7,0.7,0.7)
	
	text1=display.newText("Clean",0,0,native.systemFont,30)
	text1.x=square1.x
	text1.y=square1.y
	text1:setTextColor(0,0,0)
	
	square1:addEventListener("tap",prevStep)
	
	square2=display.newRect(0,0,75,75)
	square2.x=display.contentCenterX*1.5
	square2.y=display.contentHeight-65
	square2:setFillColor(0.7,0.7,0.7)
	
	text2=display.newText("Start",0,0,native.systemFont,30)
	text2.x=square2.x
	text2.y=square2.y
	text2:setTextColor(0,0,0)
	
	square2:addEventListener("tap",nextStep)
	
end

function chooseMenu()
	if started==false then
		if (icng) then
			for n=icng.numChildren,1,-1 do
				display.remove(icng[n])
				icng[n]=nil
			end
			function clear()
			icng=nil
			end
			timer.performWithDelay(10,clear)
		else
			icng=display.newGroup()
			
			bkg=display.newRect(display.contentCenterX,display.contentCenterY,display.contentWidth,display.contentHeight)
			bkg:setFillColor(0,0,0,0.9)
			icng:insert(bkg)

			victim=display.newText(("("..selected[1]..","..selected[2]..")"),0,0,native.systemFont,30)
			victim.x=display.contentCenterX
			victim.y=display.contentHeight-165
			icng:insert(victim)
			
			curval=display.newText("Current Value:",0,0,native.systemFont,15)
			curval.x=display.contentCenterX*0.5
			curval.y=display.contentHeight-145
			icng:insert(curval)
			
			demotile1=display.newRect(0,0,30,30)
			demotile1.x=curval.x
			demotile1.y=curval.y+25
			icng:insert(demotile1)
			
			asd=setup[((selected[2]-1)*9)+selected[1]]
			
			curvalnum=display.newText(asd,0,0,native.systemFont,30)
			curvalnum.x=demotile1.x
			curvalnum.y=demotile1.y
			curvalnum:setTextColor(0,0,0)
			icng:insert(curvalnum)
			
			newval=display.newText("New Value:",0,0,native.systemFont,15)
			newval.x=display.contentCenterX*1.5
			newval.y=display.contentHeight-145
			icng:insert(newval)
			
			demotile2=display.newRect(0,0,30,30)
			demotile2.x=newval.x
			demotile2.y=newval.y+25
			if tonumber(curvalnum.text)~=0 then
				demotile2:setFillColor(1,0,0)
			end
			icng:insert(demotile2)
			
			newvalnum=display.newText(0,0,0,native.systemFont,30)
			newvalnum.x=demotile2.x
			newvalnum.y=demotile2.y
			newvalnum:setTextColor(0,0,0)
			icng:insert(newvalnum)
			
			acceptbtn=display.newRect(0,0,75,75)
			acceptbtn.x=display.contentWidth*0.8
			acceptbtn.y=display.contentHeight-65
			acceptbtn:setFillColor(0.7,0.7,0.7)
			acceptbtn:addEventListener("tap",acceptNum)
			icng:insert(acceptbtn)
			
			accepttxt=display.newText("Accept",0,0,native.systemFont,20)
			accepttxt.x=acceptbtn.x
			accepttxt.y=acceptbtn.y
			accepttxt:setTextColor(0,0,0)
			icng:insert(accepttxt)
			
			cancelbtn=display.newRect(0,0,75,75)
			cancelbtn.x=display.contentWidth*0.5
			cancelbtn.y=display.contentHeight-65
			cancelbtn:setFillColor(0.7,0.7,0.7)
			cancelbtn:addEventListener("tap",chooseMenu)
			icng:insert(cancelbtn)
			
			canceltxt=display.newText("Cancel",0,0,native.systemFont,20)
			canceltxt.x=cancelbtn.x
			canceltxt.y=cancelbtn.y
			canceltxt:setTextColor(0,0,0)
			icng:insert(canceltxt)
			
			function cleanNum()
				newvalnum.text=0
				demotile2:setFillColor(1,0,0)
			end
				
			clearbtn=display.newRect(0,0,75,75)
			clearbtn.x=display.contentWidth*0.2
			clearbtn.y=display.contentHeight-65
			clearbtn:setFillColor(0.7,0.7,0.7)
			clearbtn:addEventListener("tap",cleanNum)
			icng:insert(clearbtn)
			
			cleartxt=display.newText("Clear",0,0,native.systemFont,20)
			cleartxt.x=clearbtn.x
			cleartxt.y=clearbtn.y
			cleartxt:setTextColor(0,0,0)
			icng:insert(cleartxt)
			
			numsquares={}
			numsquarestxt={}
			for n = 1,9 do
				function changeval()
					newvalnum.text=n
					demotile2:setFillColor(0,1,0)
				end
			
				numsquares[n]=display.newRect(0,0,75,75)
				numsquares[n].x=display.contentCenterX+((((n-1)%3)-1)*90)
				numsquares[n].y=display.contentCenterY+(((math.floor((n-1)/3))-1.85)*90)
				numsquares[n]:setFillColor(0.7,0.7,0.7)
				numsquares[n]:addEventListener("tap",changeval)
				icng:insert(numsquares[n])
				
				numsquarestxt[n]=display.newText(n,0,0,native.systemFont,90)
				numsquarestxt[n].x=numsquares[n].x
				numsquarestxt[n].y=numsquares[n].y
				numsquarestxt[n]:setTextColor(0,0,0)
				icng:insert(numsquarestxt[n])
			end
			
			icng:toFront()
		end
	end
end

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

function nextStep()
	if not (icng) then
		display.remove(square1)
		display.remove(text1)
		
		display.remove(square2)
		display.remove(text2)

		--  Display()
		preRevise()
	end
end

function preRevise()
	local laembarro=false
	for curx=1,9 do for cury=1,9 do
		
		local number
		for n=1,9 do
			if (tile[curx][cury].num[n]) then
				number=n
			end
		end
		
		if (tile[curx][cury]) then
		
				for x=1,9 do for y=1,9 do
					if x==curx and y==cury then
					elseif y==cury then
						if (tile[x][y].num[number]) then
							-- if setup[((y-1)*9)+x]==0 then
								tile[curx][cury].num[number]:setFillColor(0.75,0,0)
								laembarro=true
								-- done[curx][cury]=false
								-- display.remove(tile[curx][cury].num[number])
								-- tile[curx][cury].num[number]=nil
							-- end
						end
					elseif x==curx then
						if (tile[x][y].num[number]) then
							-- if setup[((y-1)*9)+x]==0 then
								tile[curx][cury].num[number]:setFillColor(0.75,0,0)
								laembarro=true
								-- done[curx][cury]=false
								-- display.remove(tile[curx][cury].num[number])
								-- tile[curx][cury].num[number]=nil
							-- end
						end
					elseif tile[curx][cury].quad==tile[x][y].quad then
						if (tile[x][y].num[number]) then
							-- if setup[((y-1)*9)+x]==0 then
								tile[curx][cury].num[number]:setFillColor(0.75,0,0)
								laembarro=true
								-- done[curx][cury]=false
								-- display.remove(tile[curx][cury].num[number])
								-- tile[curx][cury].num[number]=nil
							-- end
						end
					end
				end
			end
		end
		
	end end
	if laembarro==true then
		-- print "REDUCE BRUTES"
		-- text.text="JUEPUTA"
		function errorDetect()
			for i=1,7 do
				display.remove(processdisplay[i])
				processdisplay[i]=nil
			end
		
			for x=1,9 do 
				for y=1,9 do
					for n=1,9 do
						display.remove(tile[x][y].num[n])
						tile[x][y].num[n]=nil
					end
					display.remove(tile[x][y])
					tile[x][y]=nil
			
				end
				tile[x]=nil
			end
			display.remove(square)
			square=nil
			
			display.remove(textmain)
			textmain=nil
			
			display.remove(textline1)
			textline1=nil
			
			display.remove(textline2)
			textline2=nil
			
			display.remove(owner)
			owner=nil
			
			Runtime:removeEventListener("enterFrame",updateCount)
			display.remove(bfcount)
			bfcount=nil
			
			timer.performWithDelay(500,initial)
		end
			timer.performWithDelay(1000,errorDetect)
		-- Runtime:addEventListener("tap",reduceBrutes)
		-- mrClean()
		-- doneCheck()
	else
		-- text.text="PILLALO"
		-- print "Correct"
		-- Runtime:addEventListener("tap",ShamWow)
		timer.performWithDelay(10,Display)
	end
end

function prevStep()
	if not (icng) then
		display.remove(square1)
		display.remove(text1)
		
		display.remove(square2)
		display.remove(text2)

		setup={

			0,0,0, 0,0,0, 0,0,0,
			0,0,0, 0,0,0, 0,0,0,
			0,0,0, 0,0,0, 0,0,0,
			
			0,0,0, 0,0,0, 0,0,0,
			0,0,0, 0,0,0, 0,0,0,
			0,0,0, 0,0,0, 0,0,0,
			
			0,0,0, 0,0,0, 0,0,0,
			0,0,0, 0,0,0, 0,0,0,
			0,0,0, 0,0,0, 0,0,0,
		}
		
		for i=1,7 do
			display.remove(processdisplay[i])
			processdisplay[i]=nil
		end
		
		for x=1,9 do 
			for y=1,9 do
				for n=1,9 do
					display.remove(tile[x][y].num[n])
					tile[x][y].num[n]=nil
				end
				display.remove(tile[x][y])
				tile[x][y]=nil
		
			end
			tile[x]=nil
		end
		display.remove(square)
		square=nil
		
		display.remove(textmain)
		textmain=nil
		
		display.remove(textline1)
		textline1=nil
		
		display.remove(textline2)
		textline2=nil
		
		display.remove(owner)
		owner=nil
		
		timer.performWithDelay(500,initial)
	end
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
-- Runtime:removeEventListener("tap",doneCheck)
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

function Assign()
-- Runtime:removeEventListener("tap",Assign)
	local wtf=false
	textmain.text=""
	textline1.text=""
	textline2.text=""
	for curx=1,9 do for cury=1,9 do
	-- if not (curx) then
		-- curx=0
	-- end
	-- if not (cury) then
		-- cury=1
	-- end
	-- if curx~=0 and (tile[curx][cury]) then
		-- tile[curx][cury]:setFillColor(1,1,1)
	-- end
	-- curx=curx+1
	-- if curx==10 then
		-- curx=1
		-- cury=cury+1
	-- end
	if (tile[curx][cury]) then
		if setup[((cury-1)*9)+curx]~=0 then
			for n=1,9 do if (tile[curx][cury].num[n]) then
				tile[curx][cury].num[n]:setTextColor(0,0,0)
			end end
		end
		if done[curx][cury]~=true then
		-- tile[curx][cury]:setFillColor(0,0,0.5)
		local quant=0
		for n=1,9 do
			if (tile[curx][cury].num[n]) then
				quant=quant+1
			end
		end
		if quant==1 then
			for n=1,9 do
				if (tile[curx][cury].num[n]) then
					print ("("..curx..","..cury..") -- "..n.." PLACED")
					display.remove(tile[curx][cury].num[n])
					tile[curx][cury].num[n]=nil
					
					tile[curx][cury].num[n]=display.newText(n,0,0,native.systemFont,40)
					tile[curx][cury].num[n].x=tile[curx][cury].x
					tile[curx][cury].num[n].y=tile[curx][cury].y
					tile[curx][cury].num[n]:setTextColor(0,0,1)
					done[curx][cury]=true
					clean()
				end
			end
		elseif quant==0 then
			wtf=true
			tile[curx][cury].num[10]=display.newText("!!",0,0,native.systemFont,40)
			tile[curx][cury].num[10].x=tile[curx][cury].x
			tile[curx][cury].num[10].y=tile[curx][cury].y
			tile[curx][cury].num[10]:setTextColor(1,0,0)
			done[curx][cury]=true
		end
		end
	end


	-- if curx==9 and cury==9 then
		-- tile[curx][cury]:setFillColor(1,1,1)
		-- curx=nil
		-- cury=nil
		-- timer.performWithDelay(10,doneCheck)
	-- else
		-- timer.performWithDelay(10,Assign)
	-- end
	end end
	if wtf==true then
		textmain.text="VERGA PRIMO"
		timer.performWithDelay(1000,reduceBrutes)
	else
		timer.performWithDelay(10,doneCheck)
	end
end

function tileSelect()
	for y=1,9 do
		for x=1,9 do
			if done[x][y]==true and xySpread[x][y]==false then
				xySpread[x][y]=true
				for n=1,9 do 
					if (tile[x][y].num[n]) then
						xLines[x][n]=true
						yLines[y][n]=true
					end
				end
			end
		end
	end
	timer.performWithDelay(10,tileOptions)
end

function tileOptions()
	for curx=1,9 do for cury=1,9 do
	-- if not (curx) then
		-- curx=0
	-- end
	-- if not (cury) then
		-- cury=1
	-- end
	-- print (curx..","..cury)
	-- not(curx~=ix and cury ~=iy)
	-- if curx~=0 and (tile[curx][cury]) then
		-- tile[curx][cury]:setFillColor(1,1,1)
	-- end
	-- curx=curx+1
	-- if curx==10 then
		-- curx=1
		-- cury=cury+1
	-- end
	if (tile[curx][cury]) then
		if done[curx][cury]==false then
			-- tile[curx][cury]:setFillColor(0,0.75,0)
			for n=1,9 do
				if xLines[curx][n]==true or yLines[cury][n]==true then
					display.remove(tile[curx][cury].num[n])
					tile[curx][cury].num[n]=nil
				end
			end
		else
			-- tile[curx][cury]:setFillColor(0,0.25,0)
		end
	end
	
	-- if curx==9 and cury==9 then
		-- tile[curx][cury]:setFillColor(1,1,1)
		-- curx=nil
		-- cury=nil
		-- timer.performWithDelay(1,Assign)
	-- else
		-- timer.performWithDelay(1,tileOptions)
	-- end
	end end
	timer.performWithDelay(100,Assign)
end

function areaSelect()
	for y=1,9 do
		for x=1,9 do
			if done[x][y]==true and areaSpread[x][y]==false then
				areaSpread[x][y]=true
				for n=1,9 do
					if (tile[x][y].num[n]) then
						areaTiles[tile[x][y].quad][n]=true
					end
				end
			end
		end
	end
	timer.performWithDelay(10,areaOptions)
end

function areaOptions()
	for curx=1,9 do for cury=1,9 do
	-- base, ix, iy
	-- if not (curx) then
		-- curx=0
	-- end
	-- if not (cury) then
		-- cury=1
	-- end
	-- print (curx..","..cury)
	-- not(curx~=ix and cury ~=iy)
	-- if curx~=0 and (tile[curx][cury]) then
		-- tile[curx][cury]:setFillColor(1,1,1)
	-- end
	-- curx=curx+1
	-- if curx==10 then
		-- curx=1
		-- cury=cury+1
	-- end
	if (tile[curx][cury]) then
		if done[curx][cury]==false then
			-- tile[curx][cury]:setFillColor(0.75,0,0)
			for n=1,9 do
				if (areaTiles[tile[curx][cury].quad][n]==true) then
					display.remove(tile[curx][cury].num[n])
					tile[curx][cury].num[n]=nil
				end
			end
		else
			-- tile[curx][cury]:setFillColor(0.25,0,0)
		end
	end
	
	-- if curx==9 and cury==9 then
		-- tile[curx][cury]:setFillColor(1,1,1)
		-- curx=nil
		-- cury=nil
		-- timer.performWithDelay(1,Assign)
	-- else
		-- timer.performWithDelay(1,areaOptions)
	-- end
	end end
	timer.performWithDelay(100,Assign)
end

function quadSelect()
	quadinfo={}
	if unqQuadSpread==false then
		for q=1,9 do
			quadinfo[q]={0,0,0, 0,0,0, 0,0,0}
		end
		for y=1,9 do
			for x=1,9 do
				if done[x][y]==false then
					for n=1,9 do
						if (tile[x][y].num[n]) then
							quadinfo[tile[x][y].quad][n]=quadinfo[tile[x][y].quad][n]+1
						end
					end
				end
			end
		end
	end
	timer.performWithDelay(10,quadOptions)
end

function quadOptions()
	for curx=1,9 do for cury=1,9 do
	-- if not (curx) then
		-- curx=0
	-- end
	-- if not (cury) then
		-- cury=1
	-- end
	-- print (curx..","..cury)
	-- not(curx~=ix and cury ~=iy)
	-- if curx~=0 and (tile[curx][cury]) then
		-- tile[curx][cury]:setFillColor(1,1,1)
	-- end
	-- curx=curx+1
	-- if curx==10 then
		-- curx=1
		-- cury=cury+1
	-- end
	if (tile[curx][cury]) then
		if done[curx][cury]==false then
			-- tile[curx][cury]:setFillColor(0.75,0.75,0)
			for n=1,9 do
				if (tile[curx][cury].num[n]) then
					if (quadinfo[tile[curx][cury].quad][n]==1) then
						
						print ("("..curx..","..cury..") -- "..n.." PLACED")
						for n2=1,9 do
							display.remove(tile[curx][cury].num[n2])
							tile[curx][cury].num[n2]=nil
						end
						
						tile[curx][cury].num[n]=display.newText(n,0,0,native.systemFont,40)
						tile[curx][cury].num[n].x=tile[curx][cury].x
						tile[curx][cury].num[n].y=tile[curx][cury].y
						tile[curx][cury].num[n]:setTextColor(0,0,1)
						done[curx][cury]=true
						clean()
					end
				end
			end
		-- else
			-- tile[curx][cury]:setFillColor(0.25,0.25,0)
		end
	end
	
	-- if curx==9 and cury==9 then
		-- tile[curx][cury]:setFillColor(1,1,1)
		-- curx=nil
		-- cury=nil
		-- unqQuadSpread=true
		-- timer.performWithDelay(1,Assign)
	-- else
		-- timer.performWithDelay(1,quadOptions)
	-- end
	end end
	unqQuadSpread=true
	timer.performWithDelay(100,Assign)
end

function lineSelect()
	xlineinfo={}
	ylineinfo={}
	for a=1,9 do
		ylineinfo[a]={0,0,0, 0,0,0, 0,0,0,}
		xlineinfo[a]={0,0,0, 0,0,0, 0,0,0,}
	end
	for y=1,9 do
		for x=1,9 do
			if done[x][y]==false then
				-- print ("!! X-"..x)
				for n=1,9 do
					if (tile[x][y].num[n]) then
						-- print ("num-"..n)
						-- print (xlineinfo[x][n])
						xlineinfo[x][n]=xlineinfo[x][n]+1
						-- print (xlineinfo[x][n])
						ylineinfo[y][n]=ylineinfo[y][n]+1
					end
					-- print (x.."->"..n.."-"..xlineinfo[x][n])
				end
			end
		end
	end
	timer.performWithDelay(10,lineOptions)
end

function lineOptions()
	for curx=1,9 do for cury=1,9 do
	-- base, ix, iy
	-- if not (curx) then
		-- curx=0
	-- end
	-- if not (cury) then
		-- cury=1
	-- end
	-- print (curx..","..cury)
	-- not(curx~=ix and cury ~=iy)
	-- if curx~=0 and (tile[curx][cury]) then
		-- tile[curx][cury]:setFillColor(1,1,1)
	-- end
	-- curx=curx+1
	-- if curx==10 then
		-- curx=1
		-- cury=cury+1
	-- end
	if (tile[curx][cury]) then
		if done[curx][cury]==false then
			-- tile[curx][cury]:setFillColor(0.75,0,0.75)
			for n=1,9 do
				if (tile[curx][cury].num[n]) then
					-- print (curx..","..cury.."->"..n.." -- "..xlineinfo[curx][n]..","..ylineinfo[cury][n])
					if xlineinfo[curx][n]==1 or ylineinfo[cury][n]==1 then
						
						print ("("..curx..","..cury..") -- "..n.." PLACED")
						for n2=1,9 do
							display.remove(tile[curx][cury].num[n2])
							tile[curx][cury].num[n2]=nil
						end
						
						tile[curx][cury].num[n]=display.newText(n,0,0,native.systemFont,40)
						tile[curx][cury].num[n].x=tile[curx][cury].x
						tile[curx][cury].num[n].y=tile[curx][cury].y
						tile[curx][cury].num[n]:setTextColor(0,0,1)
						done[curx][cury]=true
						clean()
					end
				end
			end
		-- else
			-- tile[curx][cury]:setFillColor(0.25,0,0.25)
		end
	end
	
	-- if curx==9 and cury==9 then
		-- tile[curx][cury]:setFillColor(1,1,1)
		-- curx=nil
		-- cury=nil
	-- else
		-- timer.performWithDelay(1,lineOptions)
	-- end
	end end
	unqLineSpread=true
	timer.performWithDelay(100,Assign)
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

function clean()
	unqLineSpread=false
	unqQuadSpread=false
	flying=false
	smash=false
end

function mrClean()
	clean()
	for x=1,9 do
		xLines[x]={false,false,false, false,false,false, false,false,false}
		yLines[x]={false,false,false, false,false,false, false,false,false}
		yPosLines[x]={false,false,false, false,false,false, false,false,false}
		xPosLines[x]={false,false,false, false,false,false, false,false,false}
		for y=1,9 do
			xySpread[x][y]=false
			magicSpread[x][y]=false
			areaSpread[x][y]=false
			areaTiles[x][y]=false
		end
	end
end

function revise()
	for curx=1,9 do for cury=1,9 do
		
		local number
		for n=1,9 do
			if (tile[curx][cury].num[n]) then
				number=n
			end
		end
		
		if (tile[curx][cury]) then
			if done[curx][cury]==true then
		
				for x=1,9 do
					for y=1,9 do
						if x==curx and y==cury then
						elseif y==cury then
							if (tile[x][y].num[number]) then
								-- if setup[((y-1)*9)+x]==0 then
									tile[curx][cury].num[number]:setFillColor(0.75,0,0)
									isWrong=true
									-- done[curx][cury]=false
									-- display.remove(tile[curx][cury].num[number])
									-- tile[curx][cury].num[number]=nil
								-- end
							end
						elseif x==curx then
							if (tile[x][y].num[number]) then
								-- if setup[((y-1)*9)+x]==0 then
									tile[curx][cury].num[number]:setFillColor(0.75,0,0)
									isWrong=true
									-- done[curx][cury]=false
									-- display.remove(tile[curx][cury].num[number])
									-- tile[curx][cury].num[number]=nil
								-- end
							end
						elseif tile[curx][cury].quad==tile[x][y].quad then
							if (tile[x][y].num[number]) then
								-- if setup[((y-1)*9)+x]==0 then
									tile[curx][cury].num[number]:setFillColor(0.75,0,0)
									isWrong=true
									-- done[curx][cury]=false
									-- display.remove(tile[curx][cury].num[number])
									-- tile[curx][cury].num[number]=nil
								-- end
							end
						end
					end
				end
			end
		end
		
	end end
	if isWrong==true then
		-- print "REDUCE BRUTES"
		textmain.text="JUEPUTA"
		textline1.text=""
		textline2.text=""
		isWrong=false
		timer.performWithDelay(1000,reduceBrutes)
		-- Runtime:addEventListener("tap",reduceBrutes)
		-- mrClean()
		-- doneCheck()
	else
		textmain.text="PILLALO"
		textline1.text=""
		textline2.text=""
		print "Correct"
	
		display.remove(squarei)
		squarei=nil
		
		display.remove(texti)
		texti=nil
	
		Runtime:addEventListener("tap",ShamWow)
	end
	-- else
		-- timer.performWithDelay(1,revise)
	-- end
end

function ShamWow()
	Runtime:removeEventListener("tap",ShamWow)
	
	mrClean()
	-- setup={

		-- 0,0,0, 0,0,0, 0,0,0,
		-- 0,0,0, 0,0,0, 0,0,0,
		-- 0,0,0, 0,0,0, 0,0,0,
		
		-- 0,0,0, 0,0,0, 0,0,0,
		-- 0,0,0, 0,0,0, 0,0,0,
		-- 0,0,0, 0,0,0, 0,0,0,
		
		-- 0,0,0, 0,0,0, 0,0,0,
		-- 0,0,0, 0,0,0, 0,0,0,
		-- 0,0,0, 0,0,0, 0,0,0,
	-- }
	
	for b=1,table.maxn(bfOrder) do
		bfOrder[b]=nil
	end
	
	for i=1,7 do
		display.remove(processdisplay[i])
		processdisplay[i]=nil
	end
	
	for x=1,9 do 
		for y=1,9 do
			for n=1,9 do
				display.remove(tile[x][y].num[n])
				tile[x][y].num[n]=nil
			end
			if (tile[x][y].num[10]) then
				display.remove(tile[x][y].num[10])
				tile[x][y].num[10]=nil
			end
			display.remove(tile[x][y])
			tile[x][y]=nil
	
		end
		tile[x]=nil
	end
	display.remove(square)
	square=nil
	
	display.remove(textmain)
	textmain=nil
	
	display.remove(textline1)
	textline1=nil
	
	display.remove(textline2)
	textline2=nil
	
	display.remove(owner)
	owner=nil
	
	Runtime:removeEventListener("enterFrame",updateCount)
	display.remove(bfcount)
	bfcount=nil
	
	timer.performWithDelay(500,initial)
end

-- Display()
initial()