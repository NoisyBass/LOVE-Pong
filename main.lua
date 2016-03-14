function love.load()
	-- conf
	conf = {}
	conf.window = {}
	conf.window.width = 800
	conf.window.height = 600
	conf.paddle = {}
	conf.paddle.width = 50
	conf.paddle.height = 150
	conf.paddle.offsetX = 50

	love.graphics.setBackgroundColor(21, 24, 24)
	love.window.setMode(conf.window.width, conf.window.height)
	love.graphics.setFont(love.graphics.newFont(60))

	-- world setup
	world = love.physics.newWorld(0, 0, false)

	-- world objects
	objects = {}

	-- player
	objects.player         = {}
	objects.player.score   = 0
	objects.player.body    = love.physics.newBody(world, conf.window.width - conf.paddle.offsetX, conf.window.height/2, "kinematic")
	objects.player.shape   = love.physics.newRectangleShape(0, 0, conf.paddle.width, conf.paddle.height)
	objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape)

	-- opponent
	objects.opponent = {}
	objects.opponent.score   = 0
	objects.opponent.body    = love.physics.newBody(world, conf.paddle.offsetX, conf.window.height/2, "kinematic")
	objects.opponent.shape   = love.physics.newRectangleShape(0, 0, conf.paddle.width, conf.paddle.height)
	objects.opponent.fixture = love.physics.newFixture(objects.opponent.body, objects.opponent.shape)

	-- ball
	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, conf.window.width/2, conf.window.height/2, "dynamic")
	objects.ball.shape = love.physics.newCircleShape(20)
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape)

	-- window setup
	love.graphics.setBackgroundColor(21, 24, 24)
	love.window.setMode(conf.window.width, conf.window.height)
end

function love.update(dt)
	mouseControl = true
	keyboardControl = false
	local y = objects.player.body: getY()

	if mouseControl then
		y = love.mouse.getY()
	elseif keyboardControl then
		if love.keyboard.isDown("up") then
			y = y - 200 * dt
		elseif love.keyboard.isDown("down") then
			y = y + 200 * dt
		end
	end

	if y > conf.paddle.height/2 and y < conf.window.height - conf.paddle.height/2 then
		objects.player.body: setY(y)
	end
end

function love.draw()
	-- player paddle
	love.graphics.setColor(36, 163, 154)
	love.graphics.polygon("fill", objects.player.body: getWorldPoints(objects.player.shape: getPoints()))

	-- opponent paddle
	love.graphics.setColor(255, 143, 57)
	love.graphics.polygon("fill", objects.opponent.body: getWorldPoints(objects.opponent.shape: getPoints()))

	love.graphics.setColor(86, 93, 93)
	-- ball
	love.graphics.circle("fill", objects.ball.body: getX(), objects.ball.body: getY(), objects.ball.shape: getRadius())

	-- draw line
	for i = 0, conf.window.height/50 - 1 do
		love.graphics.rectangle("fill", conf.window.width/2 - 5, i*50, 10, 40)
	end

	love.graphics.setColor(92, 115, 114)
	-- player score
	love.graphics.printf(objects.player.score, conf.window.width/2 - 80, 20, 40, "right")
	-- opponent score
	love.graphics.printf(objects.opponent.score, conf.window.width/2 + 40, 20, 40, "left")
end
