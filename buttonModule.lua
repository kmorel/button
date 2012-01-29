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
      return button.upImage.isVisible
   end

   function button:setDown(downFlag)
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

   function button:touch(event)
      if "began" == event.phase then
	 self:setDown(true)

         -- Send subsequent events here.
         display.getCurrentStage():setFocus(self.group, event.id)
         self.isFocus = true
      elseif self.isFocus then
         if ("ended" == event.phase) or ("cancelled" == event.phase) then
	    self:setDown(false)

            -- Stop grabbing events.
            display.getCurrentStage():setFocus(self.group, nil)
            self.isFocus = false
         end
      end
   end
   button.group:addEventListener("touch", button)

   return button
end
