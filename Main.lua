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

function memberTypeTest( targetDescription, target, targetMembersAndTypes )
    for key, value in pairs( targetMembersAndTypes ) do
        _:test( string.format( 'Member test: %s contains %s "%s"',targetDescription, value, key ), function ()
            _:expect( type( target[ key ] ) ).is( value )
        end )
    end
end

function testBooneUnit()
    --CodeaUnit.detailed = false
    _:describe( "booneUnit", function ()
        _:before( function() end )
        
        _:test( "booneUnit exists", function ()
            _:expect( booneUnit ).isnt( nil )
        end )
        
        -- init
        _:test( "set/reset", function ()
            _:expect( booneUnit.reset ).isnt( nil )
            _:expect( booneUnit:reset() ).is( nil )
        end )
        
        -- booneUnit member test 
        local unitMembers = { features = "table", 
                              currentFeature = "nil", 
                              currentTest = "nil", 
                              describe = "function",
                              test = "function",
                              reset = "function",
                              bork = "number",
                              beck = "number" }
        for key, value in pairs( unitMembers ) do
            _:test( string.format( 'booneUnit contains %s "%s"', value, key ), function ()
                _:expect( type( booneUnit[ key ] ) ).is( value )
            end )
        end
        
        memberTypeTest( "auto booneUnit", booneUnit, unitMembers )
        
        ---[[ features is empty
        _:test( "booneUnit.features is empty", function ()
            local f = booneUnit.features
            _:expect( f[1] ).is( nil )
            _:expect( #f ).is( 0 )
        end )
        
        _:test( "booneUnit.currentFeature is nil", function ()
            local f = booneUnit
            _:expect( f.currentFeature ).is( nil )
        end )
        
        --call :describe()
        local testDesc = "this is a test"
        local testFunc = function ()
            print( "testing!" )
            return "some results"
        end
        local featureDesc = "printsomething"
        local featureFunc = function( scope ) 
            print("woo-hoo!")
            --test( testDesc, testFunc )
            return( 42 )
        end
        _:test( "call describe(), returns nil", function ()
            _:expect( booneUnit:describe( featureDesc, featureFunc ) ).is( nil )
        end )
        
        -- features not empty
        _:test( "booneUnit.features not empty", function ()
            local f = booneUnit.features
            _:expect( #f ).is( 1 )
            _:expect( f[1] ).isnt( nil )
        end )
        
        -- feature members 
        local featureMembers = { description = "string", 
                                 tests = "table", 
                                 numTests = "number", 
                                 runTests = "function",
                                 before = "function",
                                 after = "function" }
        for k, v in pairs( featureMembers ) do
            _:test( "features[1] has " .. k, function ()
                local f = booneUnit.features
                _:expect( f[ 1 ][ k ] ).isnt( nil )
            end )
        end
        memberTypeTest( "features[1]", booneUnit.features[1], featureMembers )
        
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
        --]]
    end )
end

