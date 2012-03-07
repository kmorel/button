module(..., package.seeall)

local clickSound = media.newEventSound("klick.wav")

local screenBorder = 0.1
local buttonBorder = 0.05

function newButton()
   local button = {}

   button.group = display.newGroup()

   button.upImage = display.newImage("ButtonUp.jpg")
   button.group:insert(button.upImage)

   button.downImage = display.newImage("ButtonDown.jpg")
   button.group:insert(button.downImage)
   button.downImage.isVisible = false

   button.group.xReference = button.group.width/2
   button.group.yReference = button.group.height/2

   function button:isDown()
      return button.downImage.isVisible
   end

   function button:setDown(downFlag)
      if self:isDown() == downFlag then
	 return
      end
      if downFlag then
         media.playEventSound(clickSound)
         self.upImage.isVisible = false
         self.downImage.isVisible = true
      else
      	 self.upImage.isVisible = true
      	 self.downImage.isVisible = false
      end
   end

   function button:setGridSize(dimSize)
      local displayBounds = display.getCurrentStage().contentBounds
      local width = displayBounds.xMax - displayBounds.xMin
      local height = displayBounds.yMax - displayBounds.yMin

      local maxLength = math.min(width, height)
      -- Take away for screen border.
      maxLength = (1.0 - screenBorder) * maxLength

      local gridSpacing = maxLength/dimSize
      -- Take away for space between buttons.
      local buttonDiameter = math.round((1.0 - buttonBorder) * gridSpacing)

      self.group.xScale = buttonDiameter/self.group.width
      self.group.yScale = buttonDiameter/self.group.height

      self.gridSize = dimSize
      self.gridSpacing = gridSpacing
      self:setGridToCenter()
   end

   function button:setGridToCenter()
      local displayBounds = display.getCurrentStage().contentBounds
      local centerx = (displayBounds.xMin + displayBounds.xMax)/2
      local centery = (displayBounds.yMin + displayBounds.yMax)/2
      local offset = 0.5*(self.gridSize - 1)*self.gridSpacing
      self.gridOriginX = centerx - offset
      self.gridOriginY = centery - offset
   end

   function button:setGridToTop()
      local displayBounds = display.getCurrentStage().contentBounds
      local centerx = (displayBounds.xMin + displayBounds.xMax)/2
      local width = displayBounds.xMax - displayBounds.xMin
      local height = displayBounds.yMax - displayBounds.yMin
      local maxLength = math.min(width, height)
      local offset = 0.5*(self.gridSize - 1)*self.gridSpacing
      self.gridOriginX = centerx - offset
      self.gridOriginY = --
        displayBounds.yMin + 0.5*screenBorder*maxLength + 0.5*self.gridSpacing
   end

   function button:setGridToBottom()
      local displayBounds = display.getCurrentStage().contentBounds
      local centerx = (displayBounds.xMin + displayBounds.xMax)/2
      local width = displayBounds.xMax - displayBounds.xMin
      local height = displayBounds.yMax - displayBounds.yMin
      local maxLength = math.min(width, height)
      local offset = 0.5*(self.gridSize - 1)*self.gridSpacing
      self.gridOriginX = centerx - offset
      self.gridOriginY = --
	 displayBounds.yMax - 0.5*screenBorder*maxLength - (self.gridSize-0.5)*self.gridSpacing
   end

   function button:setGridPosition(x, y)
      local x = self.gridOriginX + self.gridSpacing*x
      local y = self.gridOriginY + self.gridSpacing*y
      self.group.x = x
      self.group.y = y
   end

   function button:gridPositionOf(x, y)
      return --
	 (x - self.gridOriginX)/self.gridSpacing, --
         (y - self.gridOriginY)/self.gridSpacing
   end

   function button:getGridPosition()
      return self:gridPositionOf(self.group.x, self.group.y)
   end

   function button:getValidGridDimensions()
      local bounds = {}
      local displayBounds = display.getCurrentStage().contentBounds
      local width = displayBounds.xMax - displayBounds.xMin
      local height = displayBounds.yMax - displayBounds.yMin
      local maxLength = math.min(width, height)
      local border = 0.5*screenBorder*maxLength
      local radius = 0.5*self.gridSpacing
      bounds.xMin, bounds.yMin --
          = self:gridPositionOf(displayBounds.xMin + border + radius, --
                                displayBounds.yMin + border + radius)
      bounds.xMax, bounds.yMax --
          = self:gridPositionOf(displayBounds.xMax - border - radius, --
                                displayBounds.yMax - border - radius)
      return bounds
   end

   button:setGridSize(1)
   button:setGridToCenter()
   button:setGridPosition(0, 0)

   button.isFocus = false

   -- Returns true if the screen coordinates x and y are located within
   -- this button.  It does not check whether the button is visible.
   function button:isInside(x, y)
      local buttonWidth = self.group.width
      local buttonHeight = self.group.height
      local buttonX = self.group.x - (buttonWidth/2)
      local buttonY = self.group.y - (buttonHeight/2)
      if (x >= buttonX) and
	 (x <= buttonX + buttonWidth) and
	 (y >= buttonY) and
	 (y <= buttonY + buttonHeight) then
	 return true
      end
      return false
   end

   function button:addEventListener(eventName, eventListener)
      self.group:addEventListener(eventName, eventListener)
   end
   function button:removeEventListener(eventName, eventListener)
      self.group:removeEventListener(eventName, eventListener)
   end
   function button:dispatchEvent(event)
      self.group:dispatchEvent(event)
   end

   function button:touch(event)
      if "began" == event.phase then
	 self:setDown(true)

         -- Send subsequent events here.
         display.getCurrentStage():setFocus(self.group, event.id)
         self.isFocus = true
      elseif self.isFocus then
	 local inside = self:isInside(event.x, event.y)
	 self:setDown(inside)
         if ("ended" == event.phase) or ("cancelled" == event.phase) then
	    self:setDown(false)

	    -- Dispatch the click event, but only if still inside.
	    if inside then
	       local clickEvent = { name="click", target=self }
	       self:dispatchEvent(clickEvent)
	    end

            -- Stop grabbing events.
            display.getCurrentStage():setFocus(self.group, nil)
            self.isFocus = false
         end
      end
   end
   button:addEventListener("touch", button)

   return button
end
