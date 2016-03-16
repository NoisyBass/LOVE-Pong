--debug = true

--text = "No collision yet."

function love.load()
	-- conf
	conf = {}
	conf.paddle = {}
	conf.paddle.width = 50
	conf.paddle.height = 150
	conf.paddle.offsetX = 50

	love.graphics.setBackgroundColor(21, 24, 24)
	love.graphics.setFont(love.graphics.newFont(60))

	-- world setup
	world = love.physics.newWorld(0, 0, true)
	world: setCallbacks(beginContact)

	-- world objects
	objects = {}

	-- player
	objects.player         = {}
	objects.player.score   = 0
	objects.player.body    = love.physics.newBody(world, love.graphics.getWidth() - conf.paddle.offsetX, love.graphics.getHeight()/2, "kinematic")
	objects.player.shape   = love.physics.newRectangleShape(0, 0, conf.paddle.width, conf.paddle.height)
	objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape)
	objects.player.fixture: setUserData("Player")

	-- opponent
	objects.opponent = {}
	objects.opponent.score   = 0
	objects.opponent.body    = love.physics.newBody(world, conf.paddle.offsetX, love.graphics.getHeight()/2, "kinematic")
	objects.opponent.shape   = love.physics.newRectangleShape(0, 0, conf.paddle.width, conf.paddle.height)
	objects.opponent.fixture = love.physics.newFixture(objects.opponent.body, objects.opponent.shape)
	objects.opponent.fixture: setUserData("Opponent")

	-- ball
	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, love.graphics.getWidth()/2, love.graphics.getHeight()/2, "dynamic")
	objects.ball.body: setMass(1)
	objects.ball.shape = love.physics.newCircleShape(20)
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape)
	objects.ball.body: setMassData(objects.ball.shape: computeMass(1))
	objects.ball.fixture: setUserData("Ball") 
end

function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	checkWorldBoundsCollision()

	playerMove()

	opponentMove()

	world: update(dt)
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
	for i = 0, love.graphics.getHeight()/50 - 1 do
		love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 5, i*50, 10, 40)
	end

	love.graphics.setColor(92, 115, 114)
	-- player score
	love.graphics.printf(objects.player.score, love.graphics.getWidth()/2 - 80, 20, 40, "right")
	-- opponent score
	love.graphics.printf(objects.opponent.score, love.graphics.getWidth()/2 + 40, 20, 40, "left")

	-- Draw text.
	--love.graphics.print(text, 5, 25)

end

function love.keypressed(k)
	if k == "space" then
		local x, y = objects.ball.body: getLinearVelocity()
		if x == 0 and y == 0 then
			-- Apply a random impulse
			local randomRotation = math.random() * 2 * math.pi
			objects.ball.body: applyLinearImpulse(math.cos(randomRotation) * 500, math.sin(randomRotation) * 500)
			--objects.ball.body: applyLinearImpulse((0.5 - love.math.random()) * 500, (0.5 - love.math.random()) * 500)
		end
	elseif k == "r" then
		resetBall()
	end
end

function beginContact(a, b, coll)
	x, y = coll: getNormal()
	--text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
	objects.ball.body: applyLinearImpulse(x * 500, y * 500)
end

function checkWorldBoundsCollision()
	local ballY = objects.ball.body: getY()
	local ballX = objects.ball.body: getX()

	if ballY < 0 + objects.ball.shape: getRadius() or ballY > love.graphics.getHeight() - objects.ball.shape: getRadius() then
		local x, y = objects.ball.body: getLinearVelocity()
		objects.ball.body: setLinearVelocity(x, -y)
	end

	if ballX < 0 then
		objects.opponent.score = objects.opponent.score + 1
		resetBall();
	elseif ballX > love.graphics.getWidth() then
		objects.player.score = objects.player.score + 1
		resetBall()
	end
end

function resetBall()
	objects.ball.body: setX(love.graphics.getWidth()/2)
	objects.ball.body: setY(love.graphics.getHeight()/2)
	objects.ball.body: setLinearVelocity(0, 0)
end

function playerMove()
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

	if y > conf.paddle.height/2 and y < love.graphics.getHeight() - conf.paddle.height/2 then
		objects.player.body: setY(y)
	end
end

function opponentMove()
	local ballY = objects.ball.body: getY()

	if ballY > conf.paddle.height/2 and ballY < love.graphics.getHeight() - conf.paddle.height/2 then
		objects.opponent.body: setY(ballY)
	end
end