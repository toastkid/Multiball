display.setStatusBar(display.HiddenStatusBar)


local physics = require 'physics'
physics.start()
physics.setGravity(0, 0)

-- Variables

local BRICK_W = 41
local BRICK_H = 21
local X_OFFSET = 23
local Y_OFFSET = 10
local W_LEN = 8
local SCORE_CONST = 100
local score = 0
local bricks = display.newGroup()
local balls = display.newGroup()
local xDir = 1
local yDir = 1
-- local gameEvent = ''
local currentLevel = 1    

local background = display.newImage('bg.png')

local paddle
local brick
local ball
local lastBallAddedTime
local timeNow
local paddleBouncePos

local scoreText
local scoreNum
local levelText
local levelNum

local alertScreen
local alertBg
local box
local titleTF
local msgTF
local bounceCount
local powerBar
local powerBarFill
local powerBarFillCount
		
local levels = {}

levels[1] = {{0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0},
       {0,0,0,1,1,0,0,0},
       {0,0,0,1,1,0,0,0},
       {0,1,1,1,1,1,1,0},
       {0,1,1,1,1,1,1,0},
       {0,0,0,1,1,0,0,0},
       {0,0,0,1,1,0,0,0},
       {0,0,0,0,0,0,0,0},}

levels[2] = {{0,0,0,0,0,0,0,0},
       {0,0,0,1,1,0,0,0},
       {0,0,1,0,0,1,0,0},
       {0,0,0,0,0,1,0,0},
       {0,0,0,0,1,0,0,0},
       {0,0,0,1,0,0,0,0},
       {0,0,1,0,0,0,0,0},
       {0,0,1,1,1,1,0,0},}
      
levels[3] = {{0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0},
       {0,0,0,1,1,0,0,0},
       {0,1,0,0,0,0,1,0},
       {0,1,1,1,1,1,1,0},
       {0,1,0,1,1,0,1,0},
       {0,0,0,0,0,0,0,0},
       {0,0,0,1,1,0,0,0},
       {0,0,0,0,0,0,0,0},}
    
levels[4] = {{0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0},
       {1,1,1,1,1,1,1,1},
       {1,0,0,0,0,0,0,1},
       {1,0,0,0,0,0,0,1},
       {1,0,0,0,0,0,0,1},
       {1,0,0,0,0,0,0,1},
       {1,0,0,0,0,0,0,1},
       {1,1,1,1,1,1,1,1},}

local setUpGame = {}			
local startGame = {}  
local addPaddle = {} 
local addBall = {}
local buildLevel = {}
local setUpScores = {}
local drag = {}
local bounce = {}
local onCollision = {}
local update = {}
local alert = {}   
local restart = {}
local changeLevel = {}
local gameListeners = {}
local addRowOfBricks = {} 
local fillPowerBar = {}
local activatePowerBar = {}
local removeSomeBricks = {}

function setUpGame()
  print("setUpGame")
  buildLevel(levels[1])  
  setUpScores()	
  addPaddle()
end  
         
function startGame()
  print("startGame")
	background:removeEventListener('tap', startGame)
  gameListeners('add')
	
	physics.addBody(paddle, {density = 1, friction = 0, bounce = 0})
	paddle.bodyType = 'static' 
	addBall()
end   

function addPaddle()
  print("addPaddle")
  paddle = display.newImage('paddle.png') 
  paddle.x = 160
  paddle.y = 430
  paddle.name = 'paddle'  
end 

--do this at the start and when you hit the addBall button
function addBall()
	timeNow = os.time()	
	--don't do anything if it's less than a second since we last added a ball
  if(lastBallAddedTime == nil or math.abs(os.difftime( timeNow, lastBallAddedTime )) > 1 ) then
		ball = display.newImage('ball.png')
		ball.x = paddle.x
		ball.y = paddle.contentBounds.yMin - (ball.height * 0.5) -2
		ball.xSpeed = 5
		ball.ySpeed = -5	
		ball.name = 'ball'
		physics.addBody(ball, {density = 1, friction = 0, bounce = 0})
		ball:addEventListener('collision', onCollision)
		balls.insert(balls, ball)
		lastBallAddedTime = os.time()
	end
end

function buildLevel(level)
  print("buildLevel")
  -- Level length, height 
  local len = table.maxn(level)
  bricks:toFront()
  balls:toFront()
	bounceCount = 0
	--add 6 rows of bricks
  for i = 1, 6 do
    addRowOfBricks()
  end
end  

function addRowOfBricks()
  print("addRowOfBricks")
  --move all the other bricks up first
	for i = bricks.numChildren, 1, -1 do
	  brick = bricks[i]
		brick.y = brick.y + BRICK_H
	end
	--then add a new one at the back
  for i = 1, W_LEN do
	  if(math.random() < 0.5) then 
			local brick = display.newImage('brick.png')
			brick.name = 'brick'
			brick.x = BRICK_W * i - X_OFFSET
			brick.y = BRICK_H + Y_OFFSET
			physics.addBody(brick, {density = 1, friction = 0, bounce = 0})
			brick.bodyType = 'static'
			bricks.insert(bricks, brick)	
		end
	end
end

function setUpScores()
  print("setUpScores")
  scoreText = display.newText('Score:', 5, 2, 'akashi', 14)
  scoreText:setTextColor(254, 203, 50)
  scoreNum = display.newText('0', 54, 2, 'akashi', 14)
  scoreNum:setTextColor(254,203,50)
  
  levelText = display.newText('Level:', 260, 2, 'akashi', 14)
  levelText:setTextColor(254, 203, 50)
  levelNum = display.newText('1', 307, 2, 'akashi', 14)
  levelNum:setTextColor(254,203,50)
  
	addBallBox = display.newText("Add Ball", 120, 2, "akashi", 14)
	addBallBox:setTextColor(254, 254, 254)
	
	powerBar = display.newRect(210, 6, 24, 9)
  powerBar.strokeWidth = 1
  powerBar:setStrokeColor(254,203,50)	
	powerBar:setFillColor(0,0,0,0)	
	
	powerBarFillCount = -1
  fillPowerBar()
end     

function fillPowerBar()
  powerBarFillCount = powerBarFillCount + 1	
	if(powerBarFillCount == 22) then 
	  powerBar:addEventListener("touch", activatePowerBar)
		if(powerBarFill) then
			powerBarFill:removeSelf()
			powerBarFill = nil		
		end
		powerBarFill = display.newRect(211,7,powerBarFillCount,7)	
		powerBarFill:setFillColor(255,255,255)	
	elseif(powerBarFillCount < 22) then
		if(powerBarFill) then
			powerBarFill:removeSelf()
			powerBarFill = nil		
		end
	  powerBarFill = display.newRect(211,7,powerBarFillCount,7)	
	  powerBarFill:setFillColor(234,183,30)		
	end
end

function activatePowerBar()
  print("activatePowerBar")
  --delete the bottom row of bricks and reset the power bar	
	removeSomeBricks()
	powerBar:removeEventListener("touch", activatePowerBar)
	powerBarFillCount = -1	
	fillPowerBar()
end

function removeSomeBricks()
  for i=bricks.numChildren, 1, -1 do
	  if(i < 5) then 
		  brick = bricks[i]
			brick:removeSelf()
			brick = nil
		end
	end
end

--call this from the Runtime touch event
function drag(event)
  --ignore any touch events in the top half of the screen
  if(event.y > display.contentHeight/2) then 
    paddle.x = event.x
  end
end

--a ball hits the paddle
function bounce(e)
  --other can either be the ball or a brick.  if it's a brick then it's game over.
	if(e.other.name == "ball") then
		ball = e.other
		ball.ySpeed = -5
		
		--new xspeed should be relative to how far along the paddle it is
		local left =  paddle.contentBounds.xMin
		local right = paddle.contentBounds.xMax
		-- if ball.x is at right we want 1, if it's at left we want 0
		paddleBouncePos = (ball.x - left)/(right - left)
		--then apply that normalised value between -5 and 5
		ball.xSpeed = -5 + (10 * paddleBouncePos)
		bounceCount = bounceCount + 1
	elseif(e.other.name == "brick") then
		alert('  The bricks got you', '  Play Again ›') 
		gameEvent = 'lose' 	  
	end
end

function onCollision(e)
	-- Check the which side of the brick the ball hits, left, right  
  ball = e.target
  other = e.other
	
  if(other.name ~= "paddle") then
		--other could actually be a brick, another ball or the paddle
		local otherTop = other.contentBounds.yMin	
		local otherBottom = other.contentBounds.yMax
		local otherLeft = other.contentBounds.xMin
		local otherRight = other.contentBounds.xMax
		
		if(ball.x <= otherLeft or ball.x >= otherRight) then
			ball.xSpeed = -ball.xSpeed
			if(e.other.name == "ball") then
				other.xSpeed = -other.xSpeed
			end
		end
		
		if(ball.y <= otherTop or ball.y >= otherBottom) then
			ball.ySpeed = -ball.ySpeed
			if(e.other.name == "ball") then
				other.ySpeed = -other.ySpeed
			end		
		end	

		if(other.name == 'brick') then
			other:removeSelf()
			other = nil
			-- bricks.numChildren = bricks.numChildren - 1
			-- Score
			score = score + 1
			scoreNum.text = score * SCORE_CONST
			scoreNum:setReferencePoint(display.CenterLeftReferencePoint)
			scoreNum.x = 54 
			
			fillPowerBar()
			-- Check if all bricks are destroyed
			if(bricks.numChildren < 1) then
				alert('  You Win!', '  Next Level ›')
				gameEvent = 'win'
			end
		end
	end
end
    
function update(e)
	--iterate over balls, backwards to avoid messing up the index when we remove elements
  for i=balls.numChildren, 1, -1 do
    local ball = balls[i]  
		ball.x = ball.x + ball.xSpeed
		ball.y = ball.y + ball.ySpeed
		
		if(ball.contentBounds.xMin <= 0) then
		  ball.xSpeed = -ball.xSpeed 
			ball.x = ball.x + 3
		elseif(ball.contentBounds.xMax >= display.contentWidth) then
		  ball.x = ball.x - 3
			ball.xSpeed = -ball.xSpeed 
		end	--Right
		
		if(ball.contentBounds.yMin <= 0) then 
			ball.ySpeed = -ball.ySpeed 
		end--Up
		
		if(ball.contentBounds.yMax >= display.contentHeight) then 
      ball:removeSelf()
			ball = nil
      print("Removed ball: balls.numChildren = " .. balls.numChildren)			
			if(balls.numChildren < 1) then
				alert('  You lost all the balls', '  Play Again ›') 
				gameEvent = 'lose' 
			end			
		end--down/lose
	end		
  --then see if we want to add a new row of bricks
	if(bounceCount > 2) then
	  bounceCount = 0
	  addRowOfBricks()
		if(bricks[1].y > display.contentHeight) then 
			alert('  The bricks reached the bottom', '  Play Again ›') 
			gameEvent = 'lose' 		
		end
	end	
end

function alert(t, m)
  print("alert, t = " .. t .. ", m = " .. m)
  gameListeners('remove')
  
  alertBg = display.newImage('alertBg.png')
  box = display.newImage('alertBox.png', 90, 202)
  
  transition.from(box, {time = 300, xScale = 0.5, yScale = 0.5, transition = easing.outExpo})
  
  titleTF = display.newText(t, 0, 0, 'akashi', 19)
  titleTF:setTextColor(254,203,50)
  titleTF:setReferencePoint(display.CenterReferencePoint)
  titleTF.x = display.contentCenterX
  titleTF.y = display.contentCenterY - 15
  
  msgTF = display.newText(m, 0, 0, 'akashi', 12)
  msgTF:setTextColor(254,203,50)
  msgTF:setReferencePoint(display.CenterReferencePoint)
  msgTF.x = display.contentCenterX
  msgTF.y = display.contentCenterY + 15
  
  box:addEventListener('tap', restart)
  
  alertScreen = display.newGroup()
  alertScreen:insert(alertBg)
  alertScreen:insert(box)
  alertScreen:insert(titleTF)
  alertScreen:insert(msgTF)
end

function restart(e)
  print("restart, gameEvent = " .. gameEvent)
	if(gameEvent == 'win' and table.maxn(levels) > currentLevel) then
		currentLevel = currentLevel + 1
		changeLevel(levels[currentLevel])--next level
		levelNum.text = tostring(currentLevel)
	elseif(gameEvent == 'win' and table.maxn(levels) <= currentLevel) then
		box:removeEventListener('tap', restart)
		alertScreen:removeSelf()
		alertScreen = nil  
		alert('  Game Over', '  Congratulations!')
	elseif(gameEvent == 'lose') then
		changeLevel(levels[currentLevel])--same level
	end
end
    
function changeLevel(level)
  print("changeLevel")
	-- Clear Level Bricks 
	
	bricks:removeSelf()
	
	bricks.numChildren = 0
	bricks = display.newGroup()
	
	--clear balls
	balls:removeSelf()
	balls.numChildren = 0
	balls = display.newGroup()

	-- Remove Alert 
	
	box:removeEventListener('tap', restart)
	alertScreen:removeSelf()
	alertScreen = nil
	
	-- Reset Paddle position 
	
	paddle.x = display.contentWidth * 0.5
	
	-- Redraw Bricks 
	
	buildLevel(level)
	
	-- Start
	
	background:addEventListener('tap', startGame)
end

function gameListeners(action)
  print("gameListeners, action = " .. action)
  if(action == "add") then
    Runtime:addEventListener('enterFrame', update)
    paddle:addEventListener('collision', bounce)
    Runtime:addEventListener("touch", drag)
		addBallBox:addEventListener("touch", addBall)
  else
    Runtime:removeEventListener('enterFrame', update)
    paddle:removeEventListener('collision', bounce)
    Runtime:removeEventListener("touch", drag)	
		addBallBox:removeEventListener("touch", addBall)
  end
end
       
local function Main()
--wait for tap before starting
  print("Main")
	setUpGame()
  startGame()
end   

Main()        