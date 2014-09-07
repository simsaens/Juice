juice.rect = class(juice.mover)

function juice.rect:init(x, y, w, h)
    juice.mover.init(self)
    
    self.pos = vec2(x,y)
    
    self.w = w or 0
    self.h = h or w
end

function juice.rect:drawObject()
    rect(0, 0, self.w, self.h)
end

function juice.rect:size()
    return vec2(self.w, self.h)
end

function juice.rect:copy()  
    local c = juice.rect(self.pos.x,self.pos.y,self.w,self.h)

    juice.mover.copyInto(self, c)
    
    return c
end

