local composer = require( "composer" )
local scene = composer.newScene()

local MAX_LIFE = 25
local MAX_WATER = 25

local rightKidney
local leftKidney
local pizza
local beer

local lifeTextRight
local lifeTextLeft
local waterTextRight
local waterTextLeft
local scoreText

local gameLoopTimer
local scoreTimer

local lifeCountRight = MAX_LIFE
local lifeCountLeft = MAX_LIFE
local waterCountRight = 0
local waterCountLeft = 0
local scoreCount =0
local xPadding = 70
local yPadding = 800

local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the kidneys
local fallingGroup = display.newGroup()    -- Display group for falling
local uiGroup = display.newGroup()    -- Display group for ui objects like the score

math.randomseed( os.time() )
display.setStatusBar( display.HiddenStatusBar )

local physics = require( "physics")
physics.start()
physics.setGravity(0,5)

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function onTick()
	scoreCount = scoreCount+1
	scoreText.text = scoreCount
end

local function startGame()
	scoreTimer = timer.performWithDelay(1000,onTick,0)
end

local function endGame()
	timer.cancel(scoreTimer)
	composer.setVariable( "finalScore",scoreCount)
    composer.gotoScene( "scene.death_result", { time=800, effect="crossFade" } ) 
end

local function createFalling()
	local fallingType
	local rand = math.random(2)
	if (rand>1) 
		then fallingType = "pizza" 
		else fallingType = "beer"
			end
	print(string.format("random created : %s",fallingType))
	local newFalling = display.newImageRect(fallingGroup,string.format("assets/%s.png",fallingType),100,100)
	physics.addBody(newFalling,"dynamic")
	newFalling.objName = fallingType
	newFalling.x = math.random(200,558)
	newFalling.y = 0
	newFalling:addEventListener( "tap",
		function()
			display.remove(newFalling)
		end
	)
end

local function gameLooper()
	createFalling()
end

local function rightKidneyDeath()
	print(string.format("---Right kidney death life=%s, water=%s---\n---Left life=%s, water=%s",lifeCountRight,waterCountRight,lifeCountLeft,waterCountLeft))

	display.remove(rightKidney)
	display.remove(lifeTextRight)
	display.remove(waterTextRight)
	if(lifeCountLeft<=0 or waterCountLeft>=MAX_WATER)
		then endGame()
	end
end

local function leftKidneyDeath()
	print(string.format("---Left kidney death life=%s, water=%s---\n---Right life=%s, water=%s",lifeCountLeft,waterCountLeft, lifeCountRight,waterCountRight))
	display.remove(leftKidney)
	display.remove(lifeTextLeft)
	display.remove(waterTextLeft)
	if(lifeCountRight<=0 or waterCountRight>=MAX_WATER)
		then endGame()
	end
end

local function updateRightKidneyWater(delta)
	if(waterCountRight+delta>=0)
		then
		waterCountRight = waterCountRight + delta
		waterTextRight.text = waterCountRight
		if(waterCountRight>=MAX_WATER)
			then
				rightKidneyDeath()
		end
	end 
end

local function updateLeftKidneyWater(delta)
	if(waterCountLeft+delta>=0)
		then
		waterCountLeft = waterCountLeft + delta
		waterTextLeft.text = waterCountLeft
		if(waterCountLeft>=MAX_WATER)
			then
				leftKidneyDeath()
		end
	end 
end

local function updateRightKidneyLife()
	lifeCountRight = lifeCountRight-1
	lifeTextRight.text = lifeCountRight
	if(lifeCountRight==0)
		then rightKidneyDeath()
	end
end

local function updateLeftKidneyLife()
	lifeCountLeft = lifeCountLeft-1
	lifeTextLeft.text = lifeCountLeft
	if(lifeCountLeft==0)
		then leftKidneyDeath()
	end
end


local function tapKidneyRight()
	updateRightKidneyWater(-1)
end

local function tapKidneyLeft()
	updateLeftKidneyWater(-1)
end

local function onCollision( event )
    if ( event.phase == "began" ) then
 		--print("colission")
        local obj1 = event.object1
        local obj2 = event.object2

        if ( (obj1.objName == "pizza" and obj2.objName == "rightKidney")) 
        then
 			display.remove(obj1)
 			updateRightKidneyLife()
 		end
 		if (obj1.objName == "rightKidney" and obj2.objName == "pizza" )
        then
 			display.remove(obj2)
 			updateRightKidneyLife()
 		end
 		if ( obj1.objName == "pizza" and obj2.objName == "leftKidney" )
        then
 			display.remove(obj1)
 			updateLeftKidneyLife()
 		end
 		if (obj1.objName == "leftKidney" and obj2.objName == "pizza" )
        then
 			display.remove(obj2)
 			updateLeftKidneyLife()
 		end
 		if ( obj1.objName == "beer" and obj2.objName == "rightKidney" ) 
        then
 			display.remove(obj1)
 			updateRightKidneyWater(1)
 		end
 		if (obj1.objName == "rightKidney" and obj2.objName == "beer" )
        then
 			display.remove(obj2)
 			updateRightKidneyWater(1)
 		end
 		if ( obj1.objName == "beer" and obj2.objName == "leftKidney") 
        then
 			display.remove(obj1)
 			updateLeftKidneyWater(1)
 		end
 		if (obj1.objName == "leftKidney" and obj2.objName == "beer" )
        then
 			display.remove(obj2)
 			updateLeftKidneyWater(1)
 		end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
	sceneGroup:insert( fallingGroup )    -- Insert into the scene's view group
	sceneGroup:insert( uiGroup )  

	local background = display.newImageRect(backGroup, string.format("assets/%s.png",math.random(1,3)), 768, 1024 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	rightKidney = display.newImageRect(mainGroup,"assets/left kidney.png", 140, 212)
	rightKidney.x = display.contentCenterX+xPadding
	rightKidney.y = yPadding
	rightKidney.xScale = -1
	rightKidney.objName = "rightKidney"

	leftKidney = display.newImageRect(mainGroup,"assets/left kidney.png", 140, 212)
	leftKidney.x = display.contentCenterX-xPadding
	leftKidney.y = yPadding
	leftKidney.objName = "leftKidney"


	waterTextRight = display.newText( uiGroup, waterCountRight, display.contentCenterX+xPadding, yPadding, native.systemFont, 40 )
	waterTextRight:setFillColor( 0, 0, 0 )

	waterTextLeft = display.newText( uiGroup,waterCountLeft, display.contentCenterX-xPadding, yPadding, native.systemFont, 40 )
	waterTextLeft:setFillColor( 0, 0, 0 )

	lifeTextRight = display.newText( uiGroup,lifeCountRight, display.contentCenterX+xPadding, 40, native.systemFont, 40 )
	lifeTextRight:setFillColor( 256, 0, 0 )

	lifeTextLeft = display.newText( uiGroup,lifeCountLeft, display.contentCenterX-xPadding, 40, native.systemFont, 40 )
	lifeTextLeft:setFillColor( 256, 0, 0 )

	scoreText = display.newText(uiGroup, scoreCount, display.contentCenterX, 120, native.systemFont, 40 )
	lifeTextLeft:setFillColor( 256, 0, 0 )


	physics.addBody( leftKidney, "static" )
	physics.addBody( rightKidney, "static" )

	
	rightKidney:addEventListener( "tap", tapKidneyRight )
	leftKidney:addEventListener( "tap", tapKidneyLeft )
	
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)


	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		startGame()
		physics.start()
		gameLoopTimer = timer.performWithDelay(300,gameLooper,0)
		Runtime:addEventListener( "collision", onCollision )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel(gameLoopTimer)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		print("hide did")
		Runtime:removeEventListener( "collision", onCollision )
        physics.pause()
        composer.removeScene("game")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
