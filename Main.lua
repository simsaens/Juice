--Project: juice
--Version: 0.8
--Comments: initial version of juice library and demo

-- Use this function to perform your initial setup
function setup()
    r = juice.rect(WIDTH/2,HEIGHT/2,70)
    
    parameter.integer( "ObjType", 1, 4, 1, objChanged )
    
    parameter.action( "Spin", function() r:spin(2) end )
        
    parameter.action( "Bounce", function() r:bounce(150, 0.3) end )
        
    parameter.action( "Bounce & Spin", 
        function()
            r:bounce(150, 0.3, function() r:spin(1, 0.3) end )
        end )
        
    parameter.action( "Scale By", function() r:scaleBy(0.2, 0.3) end)
        
    parameter.action( "Shake", function() r:shake() end)  
        
    parameter.action( "Knock", 
        function()
            r:knock( vec2(-100,0) )
        end)
        
    parameter.action( "Pulse", function() r:pulse(0.2, 3) end )
        
    parameter.action( "Flash", function() r:flash(0, 3) end )
        
    parameter.action( "Squash",
        function()
            r:squash(1, 0.3)
        end )
        
    parameter.action( "Bounce, Spin & Squash",
        function()
            r:bounce(150, 0.3, function() r:spin(1, 0.3) end, function() r:squash(0.3,0.01,0.3) end)
        end)
        
    parameter.action( "Fade Out", function() r:fadeOut() end )
    
    parameter.action( "Fade In", function() r:fadeIn() end )
        
    parameter.action( "Copy", 
        function()
            local c = r:copy()
            for k,v in pairs(c) do        
                print(k,v)
            end
    end)
end

function objChanged(val)
    if val == 1 then
        print("juice.rect")
        r = juice.rect(WIDTH/2,HEIGHT/2,70)
        r.fill = color(234, 139, 41, 255)
    elseif val == 2 then
        print("juice.ellipse")
        r = juice.ellipse(WIDTH/2,HEIGHT/2,70)
        r.fill = color(234, 139, 41, 255)
    elseif val == 3 then
        print("juice.sprite")
        r = juice.sprite("Platformer Art:Guy Standing",WIDTH/2,HEIGHT/2,50)
        r.fill = color(255)
    elseif val == 4 then
        print("juice.text")
        r = juice.text("juice", WIDTH/2, HEIGHT/2)
        r.fill = color(255, 95, 0, 255)
        r.fontSize = 54
    end
    
    r.stroke = color(244, 180, 100, 255)    
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(40, 40, 50)

    -- This sets the line thickness
    strokeWidth(2)

    -- Do your drawing here
    stroke(255)
    line(0, HEIGHT/2 - 35, WIDTH, HEIGHT/2 - 35)
    
    r:update(DeltaTime)
    r:draw()
end

function touched(t)
    -- Code added by JakAttak
    if t.state == BEGAN then
        r:stopMoves(0.5)
    end
end
