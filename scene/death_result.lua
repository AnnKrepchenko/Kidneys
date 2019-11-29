local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()
    composer.gotoScene( "scene.game" , { time=800, effect="crossFade" } )
end

local function gotoMenu()
    composer.gotoScene( "scene.menu" , { time=800, effect="crossFade" } )
end

local json = require( "json" )
local scoresTable = {}
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local function saveScores()
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
    local file = io.open( filePath, "w" ) 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	print("death result created")
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local myScore = composer.getVariable( "finalScore" )
	table.insert( scoresTable, myScore )
    composer.setVariable( "finalScore", 0 )

    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )

    saveScores()

    local title = display.newText( sceneGroup, "Почкі атказалі",  display.contentCenterX, 200, native.systemFont, 44 )
    title:setFillColor( 1, 1, 1 )
 	
 	local subtitle = display.newText( sceneGroup, string.format("Ти продєржався  \nлише %s секунд",myScore),  display.contentCenterX, 400, native.systemFont, 44 )
    subtitle:setFillColor( 1, 1, 1 )

    local playButton = display.newText( sceneGroup, "Іграть іще", display.contentCenterX, 700, native.systemFont, 44 )
    playButton:setFillColor( 0.82, 0.86, 1 )
 
    local menuButton = display.newText( sceneGroup, "Набридло", display.contentCenterX, 810, native.systemFont, 44 )
    menuButton:setFillColor( 0.75, 0.78, 1 )

    playButton:addEventListener( "tap", gotoGame )
    menuButton:addEventListener( "tap" , gotoMenu )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene("death_result")
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
