juice.sprite = class(juice.mover)

function juice.sprite:init(tex, x, y, w, h)
    juice.mover.init(self)
    
    x = x or 0
    y = y or 0
    
    self.texture = tex
    self.pos = vec2(x,y)
    print(tex)
    local szx,szy = spriteSize(tex)
    local aspect = szy / szx
    
    if w then
        self.w = w
        self.h = h or w * aspect
    else
        self.w = szx or 0        
        self.h = szy or 0
    end
end

function juice.sprite:drawObject()    
    sprite(self.texture, 0, 0, self.w, self.h)
end

function juice.sprite:size()
    return vec2(self.w, self.h)
end

function juice.sprite:copy()  
    local c = juice.sprite(self.texture,self.pos.x,self.pos.y,self.w,self.h)

    juice.mover.copyInto(self, c)
    
    return c
end
