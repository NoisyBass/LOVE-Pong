Gamestate = require "hump.gamestate"

local menu = {}
local game = {}
local endGame = {}


------------------------------------------------------------------------
------------------------------------------------------------------------


function menu: enter()
	love.graphics.setFont(love.graphics.newFont(40))
end

function menu: draw()
	love.graphics.printf("Press Enter to continue", 0, 300, 800, "center")
end

function menu: keyreleased(key, code)
	if key == "return" then
		Gamestate.switch(game)
	end
end


------------------------------------------------------------------------
------------------------------------------------------------------------

function endGame: enter(previous, text)
	love.graphics.setFont(love.graphics.newFont(40))

	endGame.text = text
end

function endGame: draw()
	love.graphics.printf(endGame.text, 0, 200, 800, "center")
	love.graphics.printf("Press Enter to play again", 0, 300, 800, "center")
end

function endGame: keyreleased(key, code)
	if key == "return" then
		Gamestate.switch(game)
	end
end

------------------------------------------------------------------------
------------------------------------------------------------------------


function game: enter()
	love.graphics.setFont(love.graphics.newFont(60))

	-- conf
	conf = {}
	conf.paddle = {}
	conf.paddle.width = 50
	conf.paddle.height = 150
	conf.paddle.offsetX = 50

	-- world setup
	world = love.physics.newWorld(0, 0, true)
	world: setCallbacks(beginContact)

	-- player
	player         = {}
	player.score   = 0
	player.body    = love.physics.newBody(world, love.graphics.getWidth() - conf.paddle.offsetX, love.graphics.getHeight()/2, "kinematic")
	player.shape   = love.physics.newRectangleShape(0, 0, conf.paddle.width, conf.paddle.height)
	player.fixture = love.physics.newFixture(player.body, player.shape)

	-- opponent
	opponent = {}
	opponent.score   = 0
	opponent.body    = love.physics.newBody(world, conf.paddle.offsetX, love.graphics.getHeight()/2, "kinematic")
	opponent.shape   = love.physics.newRectangleShape(0, 0, conf.paddle.width, conf.paddle.height)
	opponent.fixture = love.physics.newFixture(opponent.body, opponent.shape)

	-- ball
	ball = {}
	ball.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, "dynamic")
	ball.body: setMass(1)
	ball.shape = love.physics.newCircleShape(20)
	ball.fixture = love.physics.newFixture(ball.body, ball.shape)
	ball.body: setMassData(ball.shape: computeMass(1))
end

function game: update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	game: checkWorldBoundsCollision()

	game: playerMove()

	game: opponentMove()

	world: update(dt)
end

function game: draw()
	-- player paddle
	love.graphics.setColor(36, 163, 154)
	love.graphics.polygon("fill", player.body: getWorldPoints(player.shape: getPoints()))

	-- opponent paddle
	love.graphics.setColor(255, 143, 57)
	love.graphics.polygon("fill", opponent.body: getWorldPoints(opponent.shape: getPoints()))

	love.graphics.setColor(86, 93, 93)
	-- ball
	love.graphics.circle("fill", ball.body: getX(), ball.body: getY(), ball.shape: getRadius())

	-- draw line
	for i = 0, love.graphics.getHeight()/50 - 1 do
		love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 5, i*50, 10, 40)
	end

	love.graphics.setColor(92, 115, 114)
	-- player score
	love.graphics.printf(player.score, love.graphics.getWidth()/2 - 80, 20, 40, "right")
	-- opponent score
	love.graphics.printf(opponent.score, love.graphics.getWidth()/2 + 40, 20, 40, "left")
end

function game: keypressed(k)
	if k == "space" then
		local x, y = ball.body: getLinearVelocity()
		if x == 0 and y == 0 then
			-- Apply a random impulse
			local randomRotation = math.random() * 2 * math.pi
			ball.body: applyLinearImpulse(math.cos(randomRotation) * 500, math.sin(randomRotation) * 500)
			--objects.ball.body: applyLinearImpulse((0.5 - love.math.random()) * 500, (0.5 - love.math.random()) * 500)
		end
	elseif k == "r" then
		game: resetBall()
	end
end

function game: checkWorldBoundsCollision()
	local ballY = ball.body: getY()
	local ballX = ball.body: getX()

	if ballY < 0 + ball.shape: getRadius() or ballY > love.graphics.getHeight() - ball.shape: getRadius() then
		local x, y = ball.body: getLinearVelocity()
		ball.body: setLinearVelocity(x, -y)
	end

	if ballX < 0 then
		opponent.score = opponent.score + 1
		game: resetBall();
	elseif ballX > love.graphics.getWidth() then
		player.score = player.score + 1
		game: resetBall()
	end

	if opponent.score == 1 then
		Gamestate.switch(endGame, "You lose!")
	end

	if player.score == 1 then
		Gamestate.switch(endGame, "You win!")
	end
end

function game: resetBall()
	ball.body: setX(love.graphics.getWidth()/2)
	ball.body: setY(love.graphics.getHeight()/2)
	ball.body: setLinearVelocity(0, 0)
end

function game: playerMove()
	mouseControl = true
	keyboardControl = false
	local y = player.body: getY()

	if mouseControl then
		y = love.mouse.getY()
	elseif keyboardControl then
		if love.keyboard.isDown("up") then
			y = y - 200 * dt
		elseif love.keyboard.isDown("down") then
			y = y + 200 * dt
		end
	end

	if y > conf.paddle.height/2 and y < love.graphics.getHeight() - conf.paddle.height/2 then
		player.body: setY(y)
	end
end

function game: opponentMove()
	local ballY = ball.body: getY()

	if ballY > conf.paddle.height/2 and ballY < love.graphics.getHeight() - conf.paddle.height/2 then
		opponent.body: setY(ballY)
	end
end

------------------------------------------------------------------------
------------------------------------------------------------------------


function love.load()
	love.graphics.setBackgroundColor(21, 24, 24)

	Gamestate.registerEvents()
	Gamestate.switch(menu)
end

function beginContact(a, b, coll)
	x, y = coll: getNormal()
	--text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
	ball.body: applyLinearImpulse(x * 500, y * 500)
end

