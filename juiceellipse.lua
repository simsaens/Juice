juice.ellipse = class(juice.mover)

function juice.ellipse:init(x, y, w, h)
    juice.mover.init(self)
    
    self.pos = vec2(x,y)
    
    self.w = w or 0
    self.h = h or w
end

function juice.ellipse:drawObject()
    ellipse(0, 0, self.w, self.h)
end

function juice.ellipse:size()
    return vec2(self.w, self.h)
end

function juice.ellipse:copy()  
    local c = juice.ellipse(self.pos.x,self.pos.y,self.w,self.h)

    juice.mover.copyInto(self, c)
    
    return c
end
