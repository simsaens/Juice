juice.object = class()

function juice.object:init()
    if juice.automatic then
        -- Add object to global weak table
        juice.addWeakObject(self)
    end

    -- If active is true, update will be
    -- called on this object
    self.active = true
    
    -- If visible is true, object will be drawn
    self.visible = true
    
    -- Draw order is used for automatic drawing
    -- only
    self.drawOrder = 1
    
    -- Object style state
    self.fill = color(255)
    self.stroke = color(0,0,0,0)
    self.strokeWidth = 3
    self.smooth = false
    self.alpha = 1.0
    self.blendMode = nil
    
    -- Object base transform
    self.pos = vec2(0,0)
    self.angle = 0
    self.scale = vec2(1,1)
    
    -- Image context
    self.context = nil
    
    -- Helpers
    self.parent = nil
    self.children = {}
    self.juiceMoves = {}
    self.juiceMoveKey = 0
    self.juiceShouldCollect = juice.automatic
    self.lastMoveCache = juice.move()
end

-------------------------------------------
-- Recomputes the angle as an angle in
--  0 to 360
-------------------------------------------

function juice.object:fixAngleRange()
    self.angle = self.angle % 360
end

-------------------------------------------
-- Adding and removing children
-------------------------------------------

function juice.object:addChild(child)
    if child then
        if juice.automatic then
            -- Remove child from global table
            juice.removeWeakObject(child)
            child.juiceShouldCollect = false
        end
    
        -- Add as child
        if child.juiceChildIndex ~= nil then
            table.remove(self.children, child.juiceChildIndex)
        end
        table.insert(self.children, child)
        child.juiceChildIndex = #self.children
        child.parent = self
    end
end

function juice.object:removeChild(child)
    if child then
        -- Remove child 
        if child.juiceChildIndex ~= nil then
            table.remove(self.children, child.juiceChildIndex)
            
            for i = child.juiceChildIndex,#self.children do
                local c = self.children[i]
                c.juiceChildIndex = i
            end
            
            child.juiceChildIndex = nil
            child.parent = nil
        end
        
        if juice.automatic then
            -- Add child to global table
            juice.addWeakObject(child)
            self.juiceShouldCollect = true        
        end
    end
end

-------------------------------------------
-- Applying actions to self and children
-------------------------------------------

function juice.object:applyAction(action, ...)
    if action then
        action(self, ...)
        
        for k,v in pairs(self.children) do
            v:applyAction(action, ...)
        end
    end
end

-------------------------------------------
-- Copying objects
-------------------------------------------

function juice.object:copy()
    local klass = getmetatable(self)
    local c = klass()
    
    self:copyInto(c)
    
    return c
end

function juice.object:copyInto(obj)  
    obj.alpha = self.alpha
    obj.fill = color(self.fill.r, self.fill.g, self.fill.b, self.fill.a)
    obj.stroke = color(self.stroke.r, self.stroke.g, self.stroke.b, self.stroke.a)
    obj.strokeWidth = self.strokeWidth
    obj.smooth = self.smooth
    
    obj.pos = self.pos * 1
    obj.angle = self.angle
    obj.scale = self.scale * 1
   
    for k,v in pairs(self.children) do
        obj:addChild(v:copy())
    end 
end

-------------------------------------------
-- Halt all current moves -- Code added by JakAttak
-------------------------------------------

function juice.object:haltMoves(dur)
    for k,v in pairs(self.juiceMoves) do
        for i, t in ipairs(v.tweens) do
            tween.stop(t)
        end
        
        local etCallback = function()
            self.juiceMoves[k] = nil
        end
        
        if v.stopMoveAction then
            v.stopMoveAction(dur, etCallback)
        else
            tween(dur, v, { pos = vec2(0,0), scale = vec2(1, 1), angle = 0 }, tween.easing.linear, etCallback)
        end
    end
end

-------------------------------------------
-- Start a move with a specific transform
-------------------------------------------

function juice.object:addMove(m)
    local mk = self.juiceMoveKey
    
    m.key = mk
    m.object = self
    
    self.juiceMoves[mk] = m
    
    self.juiceMoveKey = mk+1
    
    return m, mk
end

-------------------------------------------
-- Start a move with a blank tranform
-------------------------------------------

function juice.object:startMove(m)
    m = m or juice.move()
    return self:addMove(m)
end

-------------------------------------------
-- Apply a move to this object to modify
--  its transform state
-------------------------------------------

function juice.object:applyMove(m)
    self.pos = self.pos + m.pos
    self.angle = self.angle + m.angle
    self.scale = vec2(self.scale.x * m.scale.x, 
                      self.scale.y * m.scale.y)
end

-------------------------------------------
-- Finish a move by applying its current
--  state to the object and removing it
-------------------------------------------

function juice.object:finishMove(mk)
    if mk then
        local m = self.juiceMoves[mk]
        
        if m then
            self:applyMove(m)
        
            self.juiceMoves[mk] = nil
        end
    end
end

-------------------------------------------
-- Cancel a move and don't apply it
-------------------------------------------

function juice.object:cancelMove(mk)
    if mk then
        self.juiceMoves[mk] = nil
    end
end

-------------------------------------------
-- These methods compute the world base
--  position / rotation / scale of the
--  object
-------------------------------------------

function juice.object:getWorldPosition()
    local p = self:getActualPosition()
    
    local parent = self.parent
    
    while parent ~= nil do
        p = p + parent:getActualPosition()
        
        parent = parent.parent
    end
    
    return p
end

function juice.object:getWorldAngle()
    local a = self:getActualAngle()
    
    local parent = self.parent
    
    while parent ~= nil do
        a = a + parent:getActualAngle()
        
        parent = parent.parent
    end
    
    return a
end

function juice.object:getWorldScale()
    local s = self:getActualScale()
    
    local parent = self.parent
    
    while parent ~= nil do
        local ps = parent:getActualScale()
        s = vec2( s.x * ps.x, s.y * ps.y )
        
        parent = parent.parent
    end
    
    return s
end

-------------------------------------------
-- These methods compute the actual visible
--  position / rotation / scale of the
--  object after all current moves are 
--  applied
-------------------------------------------

function juice.object:getActualPosition()
    local p = self.pos
    
    for k,v in pairs(self.juiceMoves) do
        p = p + v.pos
    end
    
    return p
end

function juice.object:getActualAngle()
    local a = self.angle
    
    for k,v in pairs(self.juiceMoves) do
        a = a + v.angle
    end
    
    return a
end

function juice.object:getActualScale()
    local s = self.scale    
    
    for k,v in pairs(self.juiceMoves) do
        s = vec2(s.x * v.scale.x, s.y * v.scale.y)
    end
    
    return s
end

-------------------------------------------
-- Helper methods for drawing
-------------------------------------------

-- Style setup
function juice.object:setupStyle()
    pushStyle()
    
    tint( self.fill.r, self.fill.g, self.fill.b,
          self.fill.a * self.alpha )
    
    fill( self.fill.r, self.fill.g, self.fill.b, 
          self.fill.a * self.alpha )
        
    stroke( self.stroke.r, self.stroke.g, self.stroke.b,
            self.stroke.a * self.alpha )
            
    strokeWidth(self.strokeWidth)
            
    if self.smooth then
        smooth()
    else
        noSmooth()
    end
    
    if self.blendMode then
        blendMode(self.blendMode)
    elseif self.parent == nil then
        blendMode(NORMAL)
    end
    
    spriteMode(CENTER)
    rectMode(CENTER)
    ellipseMode(CENTER)
    textMode(CENTER)
end

function juice.object:finishStyle()
    popStyle()
end

-- Transform setup
function juice.object:setupTransform()
    pushMatrix()
    
    local p = self.pos
    local a = self.angle
    local s = self.scale
    local h = self.highlightAmount  -- Code added by JakAttak
    
    for k,v in pairs(self.juiceMoves) do
        p = p + v.pos
        a = a + v.angle
        s = vec2(s.x * v.scale.x, s.y * v.scale.y)
    end
    
    self.lastMoveCache = juice.move(p,a,s)
    
    translate(p.x, p.y)
    rotate(a)
    scale(s.x, s.y)
end

function juice.object:finishTransform()
    popMatrix()
end

-- Draw setup
function juice.object:startDraw()
    juice.object.setupTransform(self)
    juice.object.setupStyle(self)
    
    if self.juiceShouldCollect then
        juice.collectGarbage()
    end
end

function juice.object:finishDraw()
    juice.object.finishStyle(self)
    juice.object.finishTransform(self)
end

-- Children
function juice.object:drawChildren()
    for k,v in pairs(self.children) do
        v:draw()
    end
end

-------------------------------------------
-- Draws object and children, setting up
--  necessary style and transform
--
-- You should override drawObject for 
--  normal drawing
--
-- If you override this be sure to call
--  startDraw
--  -- do your drawing
--  drawChildren
--  finishDraw
-------------------------------------------

function juice.object:draw()
    if self.visible then        
        self:startDraw()
        
        self:drawObject()
        
        self:drawChildren()
        
        self:finishDraw()
    end
end

-------------------------------------------
-- Draw this object / Subclasses override
--  this
-------------------------------------------

function juice.object:drawObject()
end

-------------------------------------------
-- Draw all moves attached to this object
--  call from within drawObject() if
--  needed
-------------------------------------------

function juice.object:drawMoves()
    for k,v in pairs(self.juiceMoves) do
        v:draw()
    end
end

-------------------------------------------
-- Updating object and children
-------------------------------------------

function juice.object:update(dt)
    if self.active then
        for k,v in pairs(self.juiceMoves) do
            v:update(dt)
        end
        
        self:updateObject(dt)
    
        for k,v in pairs(self.children) do
            v:update(dt)
        end
    end
end

-------------------------------------------
-- Update this object / Subclasses override
--  this
-------------------------------------------

function juice.object:updateObject(dt)
end

-------------------------------------------
-- Should return bounding box / Subclasses
--  override this
-------------------------------------------

function juice.object:size()
    return vec2(0,0)
end

-------------------------------------------
-- Checks if a point is within the bounds
--  of this object, bounds is computed
--  using size()
-------------------------------------------

function juice.object:contains(p)
    local ap = self:getActualPosition()
    local sz = self:size() * 0.5
    
    if sz.x == 0 and sz.y == 0 then
        for k,v in pairs(self.children) do
            if v:contains(p) then
                return true
            end
        end
    else
        local ll = ap - sz
        local ur = ap + sz
        
        if p.x <= ur.x and
           p.x >= ll.x and
           p.y <= ur.y and
           p.y >= ll.y then
            return true
        end
    end
    
    return false
end
