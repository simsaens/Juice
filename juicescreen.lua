juice.screen = class(juice.mover)

function juice.screen:init()
    juice.mover.init(self)
    self.buttons = {}
    self.pos = vec2(WIDTH/2, HEIGHT/2)
    self.camPos = vec2(0,0)
end

function juice.screen:screenToWorld(p)
    return p - self.pos + self.camPos
end

function juice.screen:drawObject()
    translate(-self.camPos.x, -self.camPos.y)
    
    if self.backgroundDraw then
        self.backgroundDraw()
    end
    
    self:drawScreen()
end

function juice.screen:addButton(btn)
    self.buttons[btn] = btn
    
    self:addChild(btn)
end

function juice.screen:removeButton(btn)
    self.buttons[btn] = nil
    
    self:removeChild(btn)
end

function juice.screen:drawScreen()
end

function juice.screen:finishButtonMove(btn)
    btn:finishMove(btn.moveKey)
    btn.moveKey = nil
end

function juice.screen:touched(touch)
    local tp = self:screenToWorld(vec2(touch.x, touch.y))
    for k,v in pairs(self.buttons) do
        if v.tid == nil or v.tid == touch.id then       
            if touch.state == BEGAN and
               v:contains(tp) then
                --print("began")
                v.tid = touch.id
                self:finishButtonMove(v)
                --v:flash()
                v.moveKey = v:scaleTo(1.1, 0.2, tween.easing.backOut,
                    function() 
                        v.moveKey = nil 
                        v.scale = vec2(1.1,1.1)
                    end)
                return
            elseif touch.state == ENDED and
                   v.tid == touch.id and
                   v:contains(tp) then
                --print("ended")
                self:finishButtonMove(v)
                v.moveKey = v:scaleTo(1, 0.2, tween.easing.backOut,
                    function() 
                        v.moveKey = nil 
                        v.scale = vec2(1,1)
                    end)
                v.tid = nil
                
                -- trigger button callback
                if v.action then
                    v.action(v)
                end
                
                return
            elseif v.tid == touch.id and
                   not v:contains(tp) then
                --print("cancelled")
                self:finishButtonMove(v)
                v.moveKey = v:scaleTo(1, 0.2, tween.easing.backOut,
                    function() 
                        v.moveKey = nil 
                        v.scale = vec2(1,1)
                    end)
                v.tid = nil                
            end
        end
    end
    
    self:touchedScreen(touch)
end

function juice.screen:touchedScreen(touch)
end

function juice.screen:size()
    return vec2(WIDTH, HEIGHT)
end

