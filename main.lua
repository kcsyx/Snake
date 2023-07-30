function love.load()
	GRIDXCOUNT = 20
	GRIDYCOUNT = 15

	function MoveFood()
		local possibleFoodPositions = {}

		for foodX = 1, GRIDXCOUNT do
			for foodY = 1, GRIDYCOUNT do
				local possible = true

				for segmentIndex, segment in ipairs(SNAKESEGMENTS) do
					if foodX == segment.x and foodY == segment.y then
						possible = false
					end
				end

				if possible then
					table.insert(possibleFoodPositions, { x = foodX, y = foodY })
				end
			end
		end

		FOODPOSITION = possibleFoodPositions[
		love.math.random(#possibleFoodPositions)
		]
	end

	function Reset()
		SNAKESEGMENTS = {
			{ x = 3, y = 1 },
			{ x = 2, y = 1 },
			{ x = 1, y = 1 },
		}
		DIRECTION_QUEUE = {"right"}
		SNAKE_ALIVE = true
		TIMER = 0
		MoveFood()
	end

	Reset()
end

function love.update(dt)
	TIMER = TIMER + dt

	if SNAKE_ALIVE then
		if TIMER >= 0.15 then
			TIMER = 0

			if #DIRECTION_QUEUE > 1 then
				table.remove(DIRECTION_QUEUE, 1)
			end

			local nextXPosition = SNAKESEGMENTS[1].x
			local nextYPosition = SNAKESEGMENTS[1].y

			if DIRECTION_QUEUE[1] == "right" then
				nextXPosition = nextXPosition + 1
				if nextXPosition > GRIDXCOUNT then
					nextXPosition = 1
				end
			elseif DIRECTION_QUEUE[1] == "left" then
				nextXPosition = nextXPosition - 1
				if nextXPosition < 1 then
					nextXPosition = GRIDXCOUNT
				end
			elseif DIRECTION_QUEUE[1] == "down" then
				nextYPosition = nextYPosition + 1
				if nextYPosition > GRIDYCOUNT then
					nextYPosition = 1
				end
			elseif DIRECTION_QUEUE[1] == "up" then
				nextYPosition = nextYPosition - 1
				if nextYPosition < 1 then
					nextYPosition = GRIDYCOUNT
				end
			end

			local canMove = true

			for segmentIndex, segment in ipairs(SNAKESEGMENTS) do
				if segmentIndex ~= #SNAKESEGMENTS
					and nextXPosition == segment.x
					and nextYPosition == segment.y then
					canMove = false
				end
			end

			if canMove then
				table.insert(SNAKESEGMENTS, 1, {
					x = nextXPosition, y = nextYPosition
				})

				if SNAKESEGMENTS[1].x == FOODPOSITION.x and SNAKESEGMENTS[1].y == FOODPOSITION.y then
					MoveFood()
				else
					table.remove(SNAKESEGMENTS)
				end
			else
				SNAKE_ALIVE = false
			end
		end
	elseif TIMER >= 2 then
		Reset()
	end
end

function love.keypressed(key)
	if key == "right" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "right" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "left" then
		table.insert(DIRECTION_QUEUE, "right")
	elseif key == "left" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "left" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "right" then
		table.insert(DIRECTION_QUEUE, "left")
	elseif key == "down" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "down" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "up" then
		table.insert(DIRECTION_QUEUE, "down")
	elseif key == "up" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "up" and DIRECTION_QUEUE[#DIRECTION_QUEUE] ~= "down" then
		table.insert(DIRECTION_QUEUE, "up")
	end
end

function love.draw()
	local cellSize = 15

	love.graphics.setColor(.28, .28, .28)
	love.graphics.rectangle('fill', 0, 0, GRIDXCOUNT * cellSize, GRIDYCOUNT * cellSize)

	local function DrawCell(x, y)
		love.graphics.rectangle(
			'fill',
			(x - 1) * cellSize,
			(y - 1) * cellSize,
			cellSize - 1,
			cellSize - 1
		)
	end

	for segmentIndex, segment in ipairs(SNAKESEGMENTS) do
		if SNAKE_ALIVE then
			love.graphics.setColor(.6, 1, .32)
		else 
			love.graphics.setColor(.5, .5, .5)
		end
		DrawCell(segment.x, segment.y)
	end

	-- Temporary
	for directionIndex, direction in ipairs(DIRECTION_QUEUE) do
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(
			'directionQueue[' .. directionIndex .. ']: ' .. direction,
			15, 15 * directionIndex
		)
	end

	love.graphics.setColor(1, .3, .3)
	DrawCell(FOODPOSITION.x, FOODPOSITION.y)
end
