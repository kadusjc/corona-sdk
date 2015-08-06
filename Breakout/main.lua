local physics = require("physics");

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
	--physics.setGravity(0, 0);
	system.setAccelerometerInterval( 100 );
	
	display.setStatusBar(display.HiddenStatusBar);
	display.setDefault( "background", 1, 1, 1 );
	
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
		transition.to(menuScreenGroup,{time = 500, alpha=0, onComplete=addGameScreen});
		event.target:removeEventListener("tap", loadGame);		
	end;
end;

function addGameScreen()
	--removendo grupo nao mais utilizado
	menuScreenGroup:removeSelf();
	
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
	ball.x = 240; ball.y = 103;
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
	
	local function dragPaddle(event)
		if isSimulator then
			if event.phase == "began" then
				moveX = event.x - paddle.x;
			elseif event.phase == "moved" then
				paddle.x = event.x - moveX;
			end
			if((paddle.x - paddle.width * 0.5) < 0) then
				paddle.x = paddle.width * 0.5;
			elseif((paddle.x + paddle.width * 0.5) > display.contentWidth)	then
				paddle.x = display.contentWidth - paddle.width * 0.5;
			end;
		end;
	end;
	
    Runtime:addEventListener( "touch", dragPaddle )
end;

function alertScreen(title, message)
	alertBox = display.newImage("images/alertBox.png");
	alertBox.x = 240; alertBox.y = 160;
	transition.from(alertBox, {time = 500, xScale = 0.5, yScale = 0.5, transition = easing.outExpo});
	
	conditionDisplay = display.newText(title, 0, 0, "Arial", 38);
	conditionDisplay:setTextColor(255,255,255,255);
	conditionDisplay.xScale = 0.5; conditionDisplay.yScale = 0.5;
	conditionDisplay:setReferencePoint(display.CenterReferencePoint);
	conditionDisplay.x = display.contentCenterX;
	conditionDisplay.y = display.contentCenterY - 15;
	
	messageText = display.newText(message, 0, 0, "Arial", 24);
	messageText:setTextColor(255,255,255,255)
	messageText.xScale = 0.5; messageText.yScale = 0.5;
	messageText:setReferencePoint(display.CenterReferencePoint)
	messageText.x = display.contentCenterX;
	messageText.y = display.contentCenterY + 15;
	
	alertDisplayGroup = display.newGroup();
	alertDisplayGroup:insert(alertBox);
	alertDisplayGroup:insert(conditionDisplay);
	alertDisplayGroup:insert(messageText);
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

function startGame()
	print('Start game ');
	physics.addBody(paddle, "static", {density = 1, friction = 0, bounce = 0});
	physics.addBody(ball, {density = 1, friction = 0, bounce = 0});
	
	background:removeEventListener("tap", startGame);
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

function gameLevelTwo()
	currentLevel = 2;
	bricks:toFront();
	
	paddle.width = paddle.width-20;
	
	local numOfRows =  5;
	local numOfColumns = 8;
	createBricks(numOfRows, numOfColumns);
	
end;

function gameLevelThree()
	currentLevel = 3;
	bricks:toFront();
	

	local numOfRows =  8;
	local numOfColumns = 11;
	createBricks(numOfRows, numOfColumns);
	
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