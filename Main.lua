-- BooneUnit

-- Use this function to perform your initial setup
function setup()
    afun = function() 
        -- print( "Average expectations" )
        -- booneUnit:expect( math.pie() ).is( 3 )
    end
    somefun = function() 
        -- print( "Yabba-Dabba-Doo!" )
        -- booneUnit:test( "Great: 2 + 2 = 4", function()
            -- print("Great expectations")
            -- booneUnit:expect( 2 + 2 ).is( 4 )
        -- end )
    end
    
    bloop = {}
    bloop[somefun]=4
    
    --[[
    print( table.tostring( bloop ) )
    booneUnit:test("Average pie", afun )
    booneUnit:test("Still average pie", afun )
    booneUnit:describe( "Fred Flintstone", somefun )
    booneUnit:describe( "Fred Flintstone 2", somefun )
    booneUnit:test( "Would you like more pie?", afun )
    print("Hello World!")
    --]]
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(40, 40, 50)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    
end
