module(..., package.seeall)

local clickSound = media.newEventSound("klick.wav")

function newButton()
   local button = {}

   button.group = display.newGroup()

   button.upImage = display.newImage("ButtonUp.jpg")
   button.group:insert(button.upImage)

   button.downImage = display.newImage("ButtonDown.jpg")
   button.group:insert(button.downImage)
   button.downImage.isVisible = false

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
