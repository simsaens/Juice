juice = {}

local juice_meta_objects = {}
juice.objects = {}
setmetatable(juice.objects, juice_meta_objects)
juice_meta_objects.__mode = "v"

juice.move = class()

juice.automatic = false

function juice.move:init(p, a, s)
    self.pos = p or vec2(0,0)
    self.angle = a or 0
    self.scale = s or vec2(1,1)

    
    -- Internal
    self.tweens = {}
    self.key = -1
    self.object = nil
end

function juice.move:addTween(t)
    table.insert(self.tweens, t)
end

function juice.move:draw()
    -- Optional and generally unused    
end

function juice.move:update(dt)
end

function juice.move:combine(m)
    return juice.move(
        self.pos + m.pos,
        self.angle + m.angle,
        vec2(self.scale.x * m.scale.x,
             self.scale.y * m.scale.y)
        )
end

function juice.addWeakObject(obj)
    juice.objects[obj] = obj
    
    --table.sort( juice.objects, function(o1, o2)
    --        return o1.drawOrder < o2.drawOrder
    --    end)
end

function juice.removeWeakObject(obj)
    juice.objects[obj] = nil
end

function juice.collectGarbage()
    collectgarbage()
    
    for k,v in pairs(juice.objects) do
        v.juiceShouldCollect = false
    end
end

function juice.draw()
    local ordered = {}
    for k,v in pairs(juice.objects) do
        if v.visible then
            v:draw()
        end
    end
end

function juice.update(dt)
    dt = dt or DeltaTime
    for k,v in pairs(juice.objects) do
        if v.active then
            v:update(dt)
        end
    end
end
