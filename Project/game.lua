-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------
module(..., package.seeall)

local numberSwapMenuGroup
local board
local boardGroup
local currentNumber
local isChance

function init()
	initBoard()
	initUI()
    -- initValues()
end

function initValues()
    currentNumber = 1
    isChance = false
end

function sudokuSquare(x, y)
    local size = 37
	local square = display.newRect(0,0,size,size)
	square.x=-38+   (x*(size+1))+		((x-((x-1)%3))*2)
	square.y=       (y*(size+1))+		((y-((y-1)%3))*2)
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
		square.chances[n] = false
		square.chancesDisplay[n]=display.newText("",0,0,native.systemFont,11)
		square.chancesDisplay[n].x=square.x - 10 + (((n-1)%3)*10)
		square.chancesDisplay[n].y=square.y - 10 + (math.floor((n-1)/3)*10)
		square.chancesDisplay[n]:setTextColor(0,0,0)
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

	square.setFinal = function(self, num)
		self.finalNum = num
		self.finalDisplay.text = num
		self.finalDisplay:setFillColor(0,0,0.7)
		square.isStaticFinal = false
		for n = 1, 9 do
			self.chances[n] = false
			self.chancesDisplay[n].text = ""
		end
	end

	square.reset = function(self)
		self.finalNum = 0
		self.finalDisplay.text = ""
		self.finalDisplay:setFillColor(0,0,0)
		square.isStaticFinal = false
	end

	square.removeChance = function(self, index)
		self.chances[index] = false
		self.chancesDisplay[index].text = ""
	end


	square.addChance = function(self, index)
		self.chances[index] = true
		self.chancesDisplay[index].text = index
	end

	square.tap = function(self)
		if (isChance) then
            if (self.chances[currentNumber] = true) then
                self:removeChance(currentNumber)
            else
                self:addChance(currentNumber)
            end
        else
            if (self.finalNum == currentNumber) then
                self:reset()
            else
                self:setFinal(currentNumber)
            end
        end
	end
	square:addEventListener("tap",square)

	return square
end

function initBoard()

	board = { }
	boardGroup = display.newGroup()
	isSolving = false
	for y = 1, 9 do
		board[y] = { }
		for x = 1, 9 do
			board[y][x] = sudokuSquare(x, y)
			boardGroup:insert(board[y][x])
		end
	end

end

function initUI()
	boardSetupMenuGroup = display.newGroup()

    local size = 36
	local midW = display.contentCenterX
    local maxH = display.contentHeight
    for i = 1, 9 do
        local square = display.newRect(0,0,size,size)
        square.x = ((i-5) * (size+3)) + midW
        square.y = maxH - 80
        square.number = i

        

        square.tap = function(self)
            if (currentNumber == self.number) then
                isChance = not isChance
            else
                isChance = false
                currentNumber = self.number
            end
        end
        square:addEventListener("tap",square)

        numberSwapMenuGroup:insert(square)
    end
end