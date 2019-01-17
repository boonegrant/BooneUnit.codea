somefun = function() 
    print( "Yabba-Dabba-Doo!" )
end

bloop = {}
bloop[somefun]=4

print( table.tostring( bloop ) )

Newfeature = class()

function Newfeature:init(x)
    -- you can accept and set parameters here
    self.x = x
end

function Newfeature:draw()
    -- Codea does not automatically call this method
end

function Newfeature:touched(touch)
    -- Codea does not automatically call this method
end
