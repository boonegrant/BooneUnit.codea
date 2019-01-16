-- BooneUnit

-- Use this function to perform your initial setup
function setup()
    print("Hello World!")
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(40, 40, 50)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    
end

function testBooneUnit()
    --CodeaUnit.detailed = false
    _:describe( "booneUnit", function ()
        local unitMembers = { "features", "numTests", "describe" }
        local featureMembers = { "description", "tests", "numTests", "runTests", "test" }
        local featureDesc = "print"
        local testDesc = "this is a test"
        local testFunc = function ()
            print( "testing!" )
            return "some results"
        end
        
        _:test( "booneUnit exists", function ()
            _:expect( booneUnit ).isnt( nil )
        end )
        
        -- init
        _:test( "set/reset", function ()
            _:expect( booneUnit.reset ).isnt( nil )
            _:expect( booneUnit:reset() ).is( nil )
        end )
        
        --members
        for i, v in ipairs( unitMembers ) do
            _:test( "booneUnit contains " .. v, function ()
                _:expect( booneUnit[ v ] ).isnt( nil )
            end )
        end
        
        -- features is empty
        _:test( "booneUnit.features is empty", function ()
            local f = booneUnit.features
            _:expect( f[1] ).is( nil )
            _:expect( #f ).is( 0 )
        end )
        
        --call :describe()
        _:test( "call describe()", function ()
            _:expect( booneUnit:describe( featureDesc, function() 
                print("woo-hoo!")
                self:test( testDesc, testFunc )
                return( 42 )
            end) ).is( nil )
        end )
        
        -- features not empty
        _:test( "booneUnit.features not empty", function ()
            local f = booneUnit.features
            _:expect( #f ).is( 1 )
            _:expect( f[1] ).isnt( nil )
        end )
        
        -- feature members 
        for i, v in ipairs( featureMembers ) do
            _:test( "features[1] has " .. v, function ()
                local f = booneUnit.features
                _:expect( f[ 1 ][ v ] ).isnt( nil )
            end )
        end
        
        -- feature description 
        _:test( "feature description matches argument", function ()
            local target = booneUnit.features[1]
            _:expect( target.description ).is( featureDesc )
        end )
        
        -- run feature tests 
        _:test( "run feature tests", function ()
            local target = booneUnit.features[1]
            _:expect( target.runTests() ).is( nil )
        end )
        
        
        
        
    end )
end

