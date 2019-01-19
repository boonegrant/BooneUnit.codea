-- BooneUnit

-- Use this function to perform your initial setup
function setup()
    afun = function() 
        print( "Average expectations" )
        -- booneUnit.expect( math.pi ).is( 3 )
    end
    somefun = function() 
        print( "Yabba-Dabba-Doo!" )
        booneUnit:test( "Great: 2 + 2 = 4", function()
            print("Great expectations")
            -- booneUnit:expect( 2 + 2 ).is( 4 )
        end )
    end
    
    bloop = {}
    bloop[somefun]=4
    
    print( table.tostring( bloop ) )
    booneUnit:test("Average pie", afun )
    booneUnit:test("Still average pie", afun )
    booneUnit:describe( "Fred Flintstone", somefun )
    booneUnit:describe( "Fred Flintstone 2", somefun )
    booneUnit:test( "Would you like more pie?", afun )
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
        _:test( string.format( 'Type test: %s contains %s "%s"',targetDescription, value, key ), function ()
            _:expect( type( target[ key ] ) ).is( value )
        end )
    end
end
function memberValueTest( targetDescription, target, targetMembersAndValues )
    for key, value in pairs( targetMembersAndValues ) do
        _:test( string.format( 'Value test: %s["%s"] is "%s"',targetDescription, key, value ), function ()
            _:expect( target[ key ] ).is( value )
        end )
    end
end

function testBooneUnit()
    --CodeaUnit.detailed = false
    local bu = booneUnit
    local theFeature = ""
    local testDesc = "location: Springfield"
    local testFunc = function ()
        print( "324 Evergreen Terrace" )
        -- return "Shelbyville"
    end
    local featureDesc = "HomerSimpson"
    local featureFunc = function( scope ) 
        print("woo-hoo!")
        bu:test( testDesc, testFunc )
        return( 42 )
    end
    
    booneUnit:reset()
    booneUnit:describe(featureDesc, featureFunc)

    -- Feature Creation --
    _:describe( "booneUnit creates features", function ()
        _:before( function() end )
        
        _:test( "booneUnit exists", function ()
            _:expect( booneUnit ).isnt( nil )
        end )
        
        -- reset exists
        _:test( "reset exists", function ()
            _:expect( booneUnit.reset ).isnt( nil )
        end )
        
        -- do a reset
        _:test( "call booneUnit:reset() ", function ()
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
        memberTypeTest( "booneUnit", booneUnit, unitMembers )
        
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
        _:test( "call describe(), returns nil", function ()
            _:expect( booneUnit:describe( featureDesc, featureFunc ) ).isnt( nil )
        end )
        
        -- features not empty
        _:test( "booneUnit.features not empty", function ()
            local f = booneUnit.features
            _:expect( #f ).is( 1 )
            _:expect( f[1] ).isnt( nil )
        end )
        
        _:test( ".currentFeature is nil again", function ()
            local t = booneUnit
            _:expect( t.currentFeature ).is( nil )
        end )
    end )
    
    -- Feature Properties --
    _:describe( '"booneUnit:define()" results', function()
        -- feature members 
        local featureMembers = { description = "string", 
                                 tests = "table", 
                                 featureTests = "function", 
                                 runTests = "function",
                                 before = "function",
                                 after = "function" }
        memberTypeTest( "features[1]", booneUnit.features[1], featureMembers )
        local featureValues = { description = featureDesc, 
                                featureTests = featureFunc,
                                runTests = booneUnit.newFeature.runTests,
                                before = booneUnit.newFeature.before, 
                                after = booneUnit.newFeature.after }
        memberValueTest( "features[1]", booneUnit.features[1], featureValues )
        -- feature description 
        _:test( "feature description matches argument", function ()
            local target = booneUnit.features[1]
            _:expect( target.description ).is( featureDesc )
        end )
        
        -- run feature tests 
        _:test( "run feature tests", function ()
            local target = booneUnit.features[1]
            _:expect( target.featureTests ).isnt( nil )
            _:expect( target.runTests ).isnt( nil )
            _:expect( target:runTests() ).is( nil )
        end )
        --]]
    end )
end

