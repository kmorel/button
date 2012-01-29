
local displayBounds = display.getCurrentStage().contentBounds

local background = display.newRect(displayBounds.xMin,
				   displayBounds.yMin,
				   displayBounds.xMax,
				   displayBounds.yMax)
background:setFillColor(255, 255, 255)

require 'buttonModule'

local button = buttonModule.newButton()
button:setGridToBottom()
button:setGridPosition(0, 0)
