juice.mover = class(juice.object)

function juice.mover:init()
    juice.object.init(self)
    
    self.highlightAmount = 0
    self.darkenAmount = 0
end

function juice.mover:spin(rotations, duration, easing, callback)    
    rotations = rotations or 3
    duration = duration or 0.5
    easing = easing or tween.easing.quadOut
    
    local a = self.angle - 360 * rotations
    
    return self:rotateTo(a, duration, easing,
        function()
            if callback then callback(self) end
            self:fixAngleRange()            
        end)
end

function juice.mover:bounce(height, hold, call1, call2)
    height = height or 100
    hold = hold or 0.1
    
    local m,mk = self:startMove()
    
    local savedScale = m.scale
    local savedPos = m.pos
    local squash = vec2(m.scale.x * 1.5, m.scale.y * 0.75)
    local moveDown = savedPos.y - self:size().y/2 * (1 - squash.y)
    
    tween(0.15, m, {scale = squash}, tween.easing.quadInOut)
    tween(0.15, m, {pos = vec2(0, moveDown)}, tween.easing.quadInOut, 
        function() 
            local moveUp = savedPos.y + height * 0.9
            local unsquash = vec2(savedScale.x * 0.85, savedScale.y * 1.25)
            
            tween(0.15, m, {scale = unsquash}, tween.easing.quadInOut)
            tween(0.2, m, {pos = vec2(0, moveUp)}, tween.easing.quadOut,
                function()
                    -- Reached top of jump
                    if call1 then call1(self) end
                    
                    local holdHeight = savedPos.y + height
                    tween(hold, m, {pos = vec2(0, holdHeight)}, tween.easing.linear,
                     function()
                        tween(0.15, m, {scale = savedScale}, tween.easing.quadInOut)
                        tween(0.15, m, {pos = savedPos}, tween.easing.quadIn,
                            function()
                                self:finishMove(mk)
                                if call2 then call2(self) end
                            end )
                     end)
                end )
            
        end )
        
    return mk,m
end

function juice.mover:pulse(amount, repeats, hold, call1, call2)
    local s = vec2(1,1)
    if type(amount) == "number" then
        amount = vec2(amount + s.x, amount + s.y)
    else
        amount = amount or vec2(0.3, 0.3)
        amount = amount + s
    end
    
    local m,mk = self:startMove()
    
    hold = hold or 0
    repeats = repeats or 1
    call1 = call1 or function() end
    call2 = call2 or call1
    
    tween(0.15, m, {scale=amount}, tween.easing.quadIn,
        function() 
            call1(self)
            tween.delay(hold, function()
                tween(0.15, m, {scale=s}, tween.easing.quadOut,
                    function()
                        call2(self)
                        self:finishMove(mk)
                        if repeats > 1 or repeats < 0 then
                            self:pulse(amount - vec2(1,1), repeats - 1, 
                                       hold, call1, call2)
                        end
                    end)
            end)
        end)
        
    return mk,m
end

function juice.mover:squash(amount, hold, duration, call1, call2)
    duration = duration or 0.3
    local d = duration/2
    amount = amount or 0.5
    hold = hold or 0.1
    
    local m,mk = self:startMove()
    
    local sx = (1 + amount)
    local sy = (1 - amount * 0.5)
    local sz = self:size()
    
    local savedScale = m.scale
    local savedPos = m.pos
    local squash = vec2(sx * 0.9, sy * 0.9)
    
    local diff = (sz.y - (sz.y * squash.y))/2
    local moveDown = savedPos.y - diff
    
    tween(d, m, {pos = vec2(0,moveDown)}, tween.easing.quadOut)
    tween(d, m, {scale = squash}, tween.easing.quadOut,
      function()
        if call1 then call1(self) end
        local diff = (sz.y - (sz.y * sy))/2
        local moveDown = savedPos.y - diff
        tween(hold, m, {pos = vec2(0,moveDown)}, tween.easing.quadOut)
        tween(hold, m, {scale = vec2(sx,sy)}, tween.easing.quadOut,
          function()
            tween(d, m, {pos = savedPos}, tween.easing.backOut)
            tween(d, m, {scale = savedScale}, tween.easing.backOut,
              function()
                self:finishMove(mk)
                if call2 then call2(self) end 
              end )
          end)
      end)
    
    return mk,m
end

function juice.mover:knock(dir, duration, callback)
    duration = duration or 0.4
    return self:moveBy(dir, duration, tween.easing.backOut, callback)
end

function juice.mover:shake(intensity, duration, falloff, callback)
    local shake = juice.shakemove(intensity, duration, falloff)
    
    local m,mk = self:addMove(shake)
    
    shake.didFinish = function(move)
            self:cancelMove(mk)
            if callback then callback(self) end
        end
end

function juice.mover:fadeTo(a, duration, callback)
    duration = duration or 0.3
    
    tween(duration, self, {alpha = a}, tween.easing.linear,
      function()
        if callback then callback(self) end
      end )
end

function juice.mover:fadeOut(duration, callback)
    self:fadeTo(0, duration, callback)
end

function juice.mover:fadeIn(duration, callback)
    self:fadeTo(1, duration, callback)
end

function juice.mover:rotateTo(a, duration, easing, callback)
    duration = duration or 0.3
    easing = easing or tween.easing.quadInOut
    
    local m,mk = self:startMove()
    
    local dest = a - self.angle
    
    tween(duration, m, {angle=dest}, easing, 
      function()
        self:finishMove(mk)
        if callback then callback(self) end 
      end)
    
    return mk,m
end

function juice.mover:rotateBy(a, duration, easing, callback)
    return self:rotateTo(self.angle + a, duration, easing, callback)
end

function juice.mover:moveTo(p, duration, easing, callback)
    duration = duration or 0.3
    easing = easing or tween.easing.quadInOut
    
    local m,mk = self:startMove()
    
    local dest = p - self.pos
    
    tween(duration, m, {pos=dest}, easing,
        function()
            self:finishMove(mk)
            if callback then callback(self) end
        end)
        
    return mk,m
end

function juice.mover:moveBy(p, duration, easing, callback)
    return self:moveTo(self.pos + p, duration, easing, callback)
end

function juice.mover:scaleTo(s, duration, easing, callback)
    if type(s) == "number" then
        s = vec2(s, s)
    end
    
    duration = duration or 0.3
    easing = easing or tween.easing.quadInOut
    
    local m,mk = self:startMove()
    
    local as = self.scale
    local dest = vec2(s.x/as.x, s.y/as.y)
    
    tween(duration, m, {scale=dest}, easing,
        function()
            self:finishMove(mk)
            if callback then callback(self) end
        end )
        
    return mk,m
end

function juice.mover:scaleBy(s, duration, easing, callback)
    if type(s) == "number" then
        s = vec2(s, s)
    end
    
    return self:scaleTo(self.scale + s, duration, easing, callback)
end

function juice.mover:flash(hold, repeats, call1, call2)
    hold = hold or 0
    repeats = repeats or 1
    
    local unflash = function()
            tween(0.15, self, {highlightAmount=0}, tween.easing.linear,
                function() 
                    if call2 then call2(self) end
                    if repeats > 1 or repeats < 0 then
                        self:flash(hold, repeats - 1, call1, call2)
                    end
                end)
        end
    
    tween(0.15, self, {highlightAmount=1}, tween.easing.linear,
        function() 
            if call1 then call1(self) end
            tween.delay(hold, unflash)
        end)
end

function juice.mover:draw()
    if self.visible then
        self:startDraw()
        
        self:drawObject()
        
        if self.highlightAmount > 0 then
            local hc = color(255,255,255,255*self.highlightAmount)
            
            pushStyle()
            blendMode(ADDITIVE)
            fill(hc)
            tint(hc)
            self:drawObject()
            popStyle()
        end
        
        self:drawChildren()
        
        self:finishDraw()
    end
end

function juice.mover:copyInto(obj)  
    obj.highlightAmount = self.highlightAmount
    obj.darkenAmount = self.darkenAmount
    
    juice.object.copyInto(self, obj)
end

