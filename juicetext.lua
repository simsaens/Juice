juice.text = class(juice.mover)

function juice.text:init(str, x, y)
    juice.mover.init(self)
    self.pos = vec2(x,y)
    
    self.string = str
    self.font = "HelveticaNeue"
    self.fontSize = 22
end

function juice.text:copy()
end

function juice.text:drawObject()
    font(self.font)
    fontSize(self.fontSize)
    
    textMode(CENTER)
    
    text(self.string, 0, 0)
end

function juice.text:size()
    pushStyle()
    
    font(self.font)
    fontSize(self.fontSize)
    
    local w,h = textSize(self.string)
    
    popStyle()
    
    return vec2(w,h)
end

function juice.text:copy()
    local c = juice.text(self.string,self.pos.x,self.pos.y)

    c.font = self.font
    c.fontSize = self.fontSize
    
    juice.mover.copyInto(self, c)
    
    return c
end


