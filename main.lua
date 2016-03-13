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

end

function love.draw()
	love.graphics.setColor(92, 115, 114)
	-- player score
	love.graphics.printf(objects.player.score, conf.window.width/2 - 60, 20, 40, "right")
	-- opponent score
	love.graphics.printf(objects.opponent.score, conf.window.width/2 + 20, 20, 40, "left")

	-- player paddle
	love.graphics.setColor(36, 163, 154)
	love.graphics.polygon("fill", objects.player.body: getWorldPoints(objects.player.shape: getPoints()))

	-- opponent paddle
	love.graphics.setColor(255, 143, 57)
	love.graphics.polygon("fill", objects.opponent.body: getWorldPoints(objects.opponent.shape: getPoints()))

	-- ball
	love.graphics.setColor(86, 93, 93)
	love.graphics.circle("fill", objects.ball.body: getX(), objects.ball.body: getY(), objects.ball.shape: getRadius())

	-- draw line
	for i = 0, conf.window.height/50 - 1 do
		love.graphics.rectangle("fill", conf.window.width/2 - 5, i*50, 10, 40)
	end
end
