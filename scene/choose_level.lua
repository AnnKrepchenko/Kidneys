local composer = require( "composer" )
local scene = composer.newScene()

local json = require( "json" )
local levelsTable = {}
local filePath = system.pathForFile( "levels.json", system.ResourceDirectory )
local preferences = require "preferences"

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame(level)
	composer.setVariable( "level",level)
    composer.gotoScene( "scene.game" , { time=800, effect="crossFade" } )
end

local function gotoMenu()
    composer.gotoScene( "scene.menu" , { time=800, effect="crossFade" } )
end


local function loadLevels()
    local file = io.open( filePath, "r" )
    if file then
        local contents = file:read( "*a" )
        local tables = '{ "results": [ '..string.sub(contents, 0,-2)..'] }'
        io.close( file )
        print(tables)
        levelsTable = json.decode( tables )
        levelsTable = levelsTable.results[1]
        if (levelsTable.preferences==nil) then
        	levelsTable = levelsTable.en
        end

    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view

	loadLevels()

	local y = 1024
	local currentY=0

	local background = display.newRect( sceneGroup,display.contentCenterX,display.contentCenterY, 768,y )
    background:setFillColor( 0, 0, 0 )
    y = y/table.maxn(levelsTable)
	-- Code here runs when the scene is first created but has not yet appeared on screen
	for i,v in ipairs(levelsTable) do
		currentY = currentY+y-44
		local title = display.newText( sceneGroup, levelsTable[i],  display.contentCenterX, currentY , native.systemFont, 44 )
    	title:setFillColor( 1, 1, 1 )
    	title:addEventListener("tap",
    		function ()
    			gotoGame(i)
    		end
    	)
	end


    local menuButton = display.newText( sceneGroup, "<-", 150, 100, native.systemFont, 44 )
    menuButton:setFillColor( 1, 1, 1 )
    menuButton:addEventListener( "tap", gotoMenu )
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
		composer.removeScene("choose_level")
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
