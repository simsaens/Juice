juice.shakemove = class(juice.move)

function juice.shakemove:init(intensity, duration, falloff)
    juice.move.init(self)
    
    if falloff == nil then falloff = true end
    
    self.intensity = intensity or 10
    self.duration = duration or 0.7
    self.falloff = falloff
    self.time = 0
    self.didFinish = nil
end

function juice.shakemove:update(dt)
    local t = self.time
    t = t + dt
    
    local pct = t/self.duration
    
    if pct <= 1.0 then
        local r = vec2((math.random() - 0.5) * 2,
                       (math.random() - 0.5) * 2)
        local shake = self.intensity * r
        
        if self.falloff then 
            shake = shake * (1 - pct) 
        end
        
        self.pos = shake
    else
        if self.didFinish then
            self.didFinish(self)
            self.didFinish = nil
        end
    end
    
    self.time = t
end