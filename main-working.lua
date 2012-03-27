display.setStatusBar(display.HiddenStatusBar)


local physics = require 'physics'
physics.start()
physics.setGravity(0, 0)

-- Variables

local BRICK_W = 41
local BRICK_H = 21
local OFFSET = 23
local W_LEN = 8
local SCORE_CONST = 100
local score = 0
local bricks = display.newGroup()
local balls = display.newGroup()
local xSpeed = 5
local ySpeed = -5
local xDir = 1
local yDir = 1
-- local gameEvent = ''
local currentLevel = 1    

local background = display.newImage('bg.png')

local paddle
local brick
local ball

local scoreText
local scoreNum
local levelText
local levelNum

local alertScreen
local alertBg
local box
local titleTF
local msgTF
		
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
local startUpdate = {}  
local addPaddle = {} 
local addBall = {}
local buildLevel = {}
local setUpScores = {}
local drag = {}
local bounce = {}
local removeBrick = {}
local update = {}
local alert = {}   
local restart = {}
local changeLevel = {}
local gameListeners = {}   


function setUpGame()
  print("setUpGame")
  buildLevel(levels[1])  
  setUpScores()	
  addPaddle()
	addBall()	
end  
         
function startGame()
  print("startGame")
	background:removeEventListener('tap', startGame)
  gameListeners('add')
	
	physics.addBody(paddle, {density = 1, friction = 0, bounce = 0})
	physics.addBody(ball, {density = 1, friction = 0, bounce = 0})
	paddle.bodyType = 'static' 
end   

function startUpdate()
  print("startUpdate")
  background:removeEventListener('tap', startGame)  
  Runtime:addEventListener('enterFrame', update)  
end

function addPaddle()
  print("addPaddle")
  paddle = display.newImage('paddle.png') 
  paddle.x = 160
  paddle.y = 430
  paddle.name = 'paddle'  
end 

function addBall()
  print("addBall")
	ball = display.newImage('ball.png')
  ball.x = 160
	ball.y = 416
  ball.name = 'ball'
end

function buildLevel(level)
  print("buildLevel")
  -- Level length, height 
  local len = table.maxn(level)
  bricks:toFront()
  
  for i = 1, len do
    for j = 1, W_LEN do
      if(level[i][j] == 1) then
        local brick = display.newImage('brick.png')
        brick.name = 'brick'
        brick.x = BRICK_W * j - OFFSET
        brick.y = BRICK_H * i
        physics.addBody(brick, {density = 1, friction = 0, bounce = 0})
        brick.bodyType = 'static'
        bricks.insert(bricks, brick)
      end
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
end     

--call this from the Runtime touch event
function drag(event)
  
  paddle.x = event.x
end

--a ball hits the paddle
function bounce(event)
  print("bounce")
--need to work out if the ball is e.object1 or e.object2
-- print("collision: e.object1.y = " .. e.object1.y .. ", e.object2.y = " .. e.object2.y)
-- ball = e.object1
  -- print("event.object1.name = " + event.object1.name)
  ySpeed = -5
  
  -- Paddle Collision, check which side of the paddle the ball hits, left, right 
  
  if((ball.x + ball.width * 0.5) < paddle.x) then
    xSpeed = -5
  elseif((ball.x + ball.width * 0.5) >= paddle.x) then
    xSpeed = 5
  end
end
  
function removeBrick(e)
	
	-- Check the which side of the brick the ball hits, left, right  

				if(e.other.name == 'brick' and (ball.x + ball.width * 0.5) < (e.other.x + e.other.width *
0.5)) then
						xSpeed = -5
				elseif(e.other.name == 'brick' and (ball.x + ball.width * 0.5) >= (e.other.x + 
e.other.width * 0.5)) then
						xSpeed = 5
				end
	-- Bounce, Remove
	if(e.other.name == 'brick') then
		ySpeed = ySpeed * -1
		e.other:removeSelf()
		e.other = nil
		bricks.numChildren = bricks.numChildren - 1
		-- Score
		score = score + 1
		scoreNum.text = score * SCORE_CONST
		scoreNum:setReferencePoint(display.CenterLeftReferencePoint)
		scoreNum.x = 54 
	end
	
	-- Check if all bricks are destroyed
	
	if(bricks.numChildren < 0) then
		alert('  You Win!', '  Next Level ›')
		gameEvent = 'win'
	end
end
    
function update(e)
	ball.x = ball.x + xSpeed
	ball.y = ball.y + ySpeed
	
	if(ball.x < 0) then 
		ball.x = ball.x + 3 xSpeed = -xSpeed 
	end--Left
	if((ball.x + ball.width) > display.contentWidth) then 
		ball.x = ball.x - 3 xSpeed = -xSpeed 
	end
--Right
	if(ball.y < 0) then 
		ySpeed = -ySpeed 
	end--Up
	
	if(ball.y + ball.height > paddle.y + paddle.height) then 
		alert('  You Lose', '  Play Again ›') 
		gameEvent = 'lose' 
	end--down/lose
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

	-- Remove Alert 
	
	box:removeEventListener('tap', restart)
	alertScreen:removeSelf()
	alertScreen = nil
	
	-- Reset Ball and Paddle position 
	
	ball.x = (display.contentWidth * 0.5) - (ball.width * 0.5)
	ball.y = (paddle.y - paddle.height) - (ball.height * 0.5) -2
	
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
		ball:addEventListener('collision', removeBrick)
  else
    Runtime:removeEventListener('enterFrame', update)
    paddle:removeEventListener('collision', bounce)
    Runtime:removeEventListener("touch", drag)
		ball:removeEventListener('collision', removeBrick)		
  end
end
       
local function Main()
--wait for tap before starting
  print("Main")
	setUpGame()
  startGame()
end   

Main()        