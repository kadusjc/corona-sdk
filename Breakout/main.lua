local physics = require("physics");
local brickSound;
local hitSound;

local whiteBackRectangle;
local ferreiroCorreaScreen;

local menuScreenGroup; -- display.newGroup()
local mmScreen;
local playBtn;
local playText;

local background;
local paddle;
local brick;
local ball;
local scoreText;
local scoreNum;
local levelText;
local levelNum;

local alertDisplayGroup; -- display.newGroup()
local alertBox;
local conditionDisplay;
local messageText;

local _W = display.contentWidth / 2;
local _H = display.contentHeight / 2;
local bricks; -- display.newGroup();
local brickWidth = 35;
local brickHeight = 15;
local row;
local column;
local score = 0;
local scoreIncrease = 100;
local currentLevel;
local vx = 3;
local vy = -3;
local gameEvent = "";
local isSimulator = ("simulator" == system.getInfo("environment"));

local function main()
	configureApplication();    
	initializeApplication();	
end;

function configureApplication()
	physics.start();
	physics.setScale( 40 );
	physics.setGravity(0, 0);
	system.setAccelerometerInterval( 100 );
	
	display.setStatusBar(display.HiddenStatusBar);
	display.setDefault( "background", 1, 1, 1 );	
	
	hitSound = media.newEventSound("sounds/hit.wav");
	brickSound = media.newEventSound("sounds/brick.wav");
end;

function initializeApplication()
	
    whiteBackRectangle = display.newRect(0, 0, _W, _H);
	whiteBackRectangle:setFillColor(255, 255, 255);
	
	ferreiroCorreaScreen = display.newImage("images/logo.png", 152, 300, true);
	ferreiroCorreaScreen.x = _W;
	ferreiroCorreaScreen.y = _H;
	
	devScreenGroup = display.newGroup();
	devScreenGroup:insert(whiteBackRectangle);
	devScreenGroup:insert(ferreiroCorreaScreen);
	
	transition.to(devScreenGroup,{time = 3000, alpha=1, onComplete = createMenuScreen});
end;


function createMenuScreen()
	--removendo grupo nao mais utilizado
	devScreenGroup:removeSelf();	 
	devScreenGroup = nil;
	
	mmScreen = display.newImage("images/mmScreen.png", _W, _H);
	mmScreen:addEventListener("tap", loadGame);
	mmScreen.name = "playbutton";
	
	playText = display.newText( "play", 200, 40, native.systemFont, 20);
	playText:setTextColor( 0,0,0, 10 );
	playText.y = _H+130;
	playText.x = _W;
	playText.name = "playbutton";
	playText:addEventListener("tap", loadGame);
		
	menuScreenGroup = display.newGroup();
	menuScreenGroup:toFront();
	menuScreenGroup:insert(mmScreen);
	menuScreenGroup:insert(playText);
end;

function loadGame(event)
	if(event.target.name == "playbutton") then
		event.target.y = event.target.y-3;
		transition.to(menuScreenGroup,{time = 3, alpha=0, onComplete=drawGameScreen});
		event.target:removeEventListener("tap", loadGame);		
	end;
end;

function drawGameScreen()
	--removendo grupo nao mais utilizado
	menuScreenGroup:removeSelf();
	menuScreenGroup = nil;
	
	background = display.newImage("images/bg.png", 0, 0, true );--bg covering all background
	background.x = _W;
	background.y = _H+45;
	
	--paddle = display.newImage("images/paddle.png");
	paddle = display.newImageRect("images/paddle.png", 71, 11);
	paddle.x = 240; paddle.y = 300;
	paddle.name = "paddle";
	
	ball = display.newImage( "images/rock.png");--ball with 5 pixels of size 
	ball.width = 25;
	ball.height = 25;
	ball.x = 0; ball.y = 0
	ball.name = "ball";
	 
	scoreText = display.newText("Score:", 5, 7, "Arial", 14);
	scoreText:setTextColor(255, 255, 255, 255);
	
	scoreNum = display.newText("0", 54, 7, "Arial", 14);
	scoreNum:setTextColor(255, 255, 255, 255);
	
	levelText = display.newText("Level:", 420, 7, "Arial", 14);
	levelText:setTextColor(255, 255, 255, 255);
	levelNum = display.newText("1", 460, 7, "Arial", 14);
	levelNum:setTextColor(255, 255, 255, 255);
	
	gameLevelOne();	
	background:addEventListener("tap", startGame);			
end;

function createBricks(numOfRows, numOfColumns)
	local brickPlacement = {x = ( (_W) - (brickWidth * numOfColumns )/ 2 + 20),  y = 50};	
	
	for row = 0, numOfRows - 1 do
		for column = 0, numOfColumns - 1 do
			local brick = display.newImage("images/brick.png");
			brick.name = "brick";
			brick.x = brickPlacement.x + (column * brickWidth);
			brick.y = brickPlacement.y + (row * brickHeight);
			physics.addBody(brick, "static", {density = 1, friction = 0, bounce = 0});
			bricks.insert(bricks, brick);
		end
	end
end;	




-- *************************  INIT OF ACTIONS
function limitPaddleToWallBorders()
	--limiting to the left corner of mobile
	if((paddle.x - paddle.width * 0.5) < 0) then
		paddle.x = paddle.width * 0.5;
				
	--limiting to the right corner of mobile
	elseif((paddle.x + paddle.width * 0.5) > display.contentWidth)	then
		paddle.x = display.contentWidth - paddle.width * 0.5;
	end;
end;

function dragPaddle(event)
	local moveX = 0;
	if isSimulator then
		if event.phase == "began" then
			moveX = event.x - paddle.x;
		elseif event.phase == "moved" then
			paddle.x = event.x - moveX;
		end
		limitPaddleToWallBorders();
	end;
end;

function movePaddle(event)
	paddle.x = display.contentCenterX - (display.contentCenterX * (event.yGravity*3));
	limitPaddleToWallBorders();
end;
	
function bounceBall(event)
	media.playEventSound(hitSound);
	vy = -3;
	if( (ball.x + ball.width * 0.5) < paddle.x) then
		vx = -vx;
	elseif( (ball.x + ball.width * 0.5) >= paddle.x) then
		vx = vx;
	end
end;

function proccessBrickColision(event)
	
	local brickLimitWidth = event.other.x + event.other.width * 0.5;
	local isBrickCollide = ( event.other.name == "brick" );
	
	if isBrickCollide and (ball.x + ball.width * 0.5) < brickLimitWidth then 
		vx = -vx;
	elseif isBrickCollide and (ball.x + ball.width * 0.5) >= brickLimitWidth then 
		vx = vx;
	end;
	
	if isBrickCollide then
		vy = vy * -1;
		
		media.playEventSound(brickSound);
		event.other:removeSelf();
		event.other = nil;
				
		bricks.numChildren = bricks.numChildren - 1
		score = score + 1;
		
		scoreNum.text = score * scoreIncrease;
		--scoreNum:setReferencePoint(display.CenterLeftReferencePoint);
		scoreNum.x = 54;
	end;
	
	if bricks.numChildren < 0 then
		alertScreen("YOU WIN!", "Continue");
		gameEvent = "win";
	end;
	
end;

function updateBall(event)
	ball.x = ball.x + vx;
	ball.y = ball.y + vy;
	
	--movement to x direction
	if ball.x < 0 or (ball.x + ball.width) > display.contentWidth then
		vx = -vx;		
	end;
	
	if(ball.y < 0) then
		vy = -vy;
	end;	
		
	if ( ball.y - ball.height) > ( paddle.y + paddle.height)  then
		alertScreen("YOU LOSE!", "Play Again");
		gameEvent = "lose";
		gameListeners('remove');
	end;
end;

function gameListeners(event)

	if event == "add" then	
		Runtime:addEventListener("accelerometer", movePaddle);
		Runtime:addEventListener("enterFrame", updateBall)
		paddle:addEventListener("collision", bounceBall);
		ball:addEventListener("collision", proccessBrickColision)
		paddle:addEventListener("touch", dragPaddle);
		
	elseif event == "remove" then
		Runtime:removeEventListener("accelerometer", movePaddle);
		Runtime:removeEventListener("enterFrame", updateBall)
		paddle:removeEventListener("collision", bounceBall);
		ball:removeEventListener("collision", proccessBrickColision)
		paddle:removeEventListener("touch", dragPaddle);		
	end;
		
end;
-- *************************  END OF ACTIONS




function alertScreen(title, message)	
	alertBox = display.newImage("images/alertBox.png");
	alertBox.x = 240; alertBox.y = 160;
	alertBox.width = 200; alertBox.height = 200;
	transition.from(alertBox, {time = 1000, xScale = 0.5, yScale = 0.5, transition = easing.outExpo});
	
	conditionDisplay = display.newText(title, 0, 0, "Arial", 38);
	conditionDisplay:setFillColor(243,204,118);
	conditionDisplay.xScale = 0.5; conditionDisplay.yScale = 0.5;
	conditionDisplay.align = "center";
	conditionDisplay.x = display.contentCenterX;
	conditionDisplay.y = display.contentCenterY - 15;
	conditionDisplay:toFront();
	
	messageText = display.newText(message, 0, 0, "Arial", 30)
	messageText:setFillColor(243,204,118)
	messageText.xScale = 0.5; messageText.yScale = 0.5;
	messageText.align = "center";
	messageText.x = display.contentCenterX;
	messageText.y = display.contentCenterY + 15;
	
	alertDisplayGroup = display.newGroup();
	alertDisplayGroup:insert(alertBox);
	alertDisplayGroup:insert(conditionDisplay);
	alertDisplayGroup:insert(messageText);
	
end;



function resetLevelComponents()
	bricks:removeSelf();
	bricks.numChildren = 0;
	bricks = display.newGroup();
	
	alertBox:removeEventListener("tap", restart);
	alertDisplayGroup:removeSelf()
	alertDisplayGroup = nil;
	
	ball.x = (display.contentWidth * 0.5) - (ball.width * 0.5);
	ball.y = (paddle.y - paddle.height) - (ball.height * 0.5) -2;
	paddle.x = display.contentWidth * 0.5;
end;

function restart()
	local lastLevel = 3;
	
	--Se ganhou, avanca pra proxima fase
	if (gameEvent == "win") then
		currentLevel = currentLevel + 1;
		levelNum.text = tostring(currentLevel);
		_G['changeToLevel'..currentLevel]();		
	
	--Se perdeu mantem na fase atual, porem com score zerado
	elseif ( gameEvent == "lose" ) then
		score = 0;
		scoreNum.text = "0";
		_G['changeToLevel'..currentLevel]();		
	
	--Se ganhou na ultima fase
	elseif ( gameEvent == "win" ) and ( currentLevel == lastLevel) then
		alertScreen(" Game Over", " Congratulations!");
		gameEvent = "completed"	;
	
	elseif gameEvent == "completed" then
		alertBox:removeEventListener("tap", restart);
	end;
	
end;	

function startGame()
	physics.addBody(paddle, "static", {density = 1, friction = 0, bounce = 0});
	physics.addBody(ball, "dynamic", {density = 1, friction = 0, bounce= 0})
	
	background:removeEventListener("tap", startGame);
	gameListeners("add");
end;

function gameLevelOne()
	currentLevel = 1;
	bricks = display.newGroup();
	bricks:toFront();
	
	paddle.width = paddle.width+30;
	
	local numOfRows = 4;
	local numOfColumns = 4;
	createBricks(numOfRows, numOfColumns);
end;

function changeToLevel1()
	resetLevelComponents();
	gameLevelOne();
	background:removeEventListener("tap", startGame);
end;

function gameLevelTwo()
	bricks:removeSelf();
	currentLevel = 2;
	
	bricks = display.newGroup();
	bricks:toFront();
	
	paddle.width = paddle.width-20;
	
	local numOfRows =  5;
	local numOfColumns = 8;
	createBricks(numOfRows, numOfColumns);
end;

function changeToLevel2()
	resetLevelComponents();
	gameLevelTwo();
	background:removeEventListener("tap", startGame);
end;

function gameLevelThree()
	bricks:removeSelf();
	currentLevel = 3;
	
	bricks = display.newGroup();
	bricks:toFront();
	
	local numOfRows =  8;
	local numOfColumns = 11;
	createBricks(numOfRows, numOfColumns);	
end;	

function changeToLevel3()
	resetLevelComponents();
	gameLevelThree();
	background:removeEventListener("tap", startGame);
end;

function gameLevelFour()
	currentLevel = 4;
	bricks:toFront();

	paddle.width = paddle.width-10;	
	
	local numOfRows =  10;
	local numOfColumns = 13;
	createBricks(numOfRows, numOfColumns);
	
end;	

function gameLevelFive()
	currentLevel = 5;
	bricks:toFront();
	
	paddle.width = paddle.width-10;
	
	local numOfRows =  12;
	local numOfColumns = 15;
	createBricks(numOfRows, numOfColumns);
	
end;	



main();