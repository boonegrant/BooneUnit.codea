
function bestBooneUnit()
    --CodeaUnit.detailed = false
    local bu = booneUnit
    -- local theFeature = ""
    local atestDesc = "location: Springfield"
    local atestFunc = function ()
        print( "324 Evergreen Terrace" )
        return "Shelbyville"
    end
    local afeatureDesc = "HomerSimpson"
    local afeatureFunc = function( scope ) 
        print("woo-hoo!")
        bu:test( testDesc, testFunc )
        return( 42 )
    end
    
    booneUnit:reset()

    -- booneUnit is something --
    _:describe( "BooneUnit initial state", function()
        
        _:test( "booneUnit exists", function ()
            _:expect( booneUnit ).isnt( nil )
        end )
        
        -- Public methods list
        local publicUnitMethods = { describe = "function",
                                    test = "function",
                                    reset = "function",
                                    ignore = "function",
                                    before = "function",
                                    after = "function" }
        memberTypeTest( "public methods: booneUnit", booneUnit, publicUnitMethods )
        --tableKeyValueTypeTest
        --tableKeyValueTest
        
        -- Result categories 
        local definedResultTypes = { "pass", "fail", "ignore", "pending", "empty test"}
        _:test( string.format( "There are %d result categories", #definedResultTypes ), function ()
            _:expect( #booneUnit.resultTypes ).is( #definedResultTypes )
        end )
        -- tableHasValueTest()
        for i, v in ipairs(definedResultTypes) do
            _:test( "booneUnit.resultTypes has", function()
                _:expect( booneUnit.resultTypes ).has( v )
            end)
        end
        
        -- reset exists
        _:test( "reset exists", function ()
            _:expect( booneUnit.reset ).isnt( nil )
        end )
        
        -- do a reset
        _:test( "call booneUnit:reset() ", function ()
            _:expect( booneUnit:reset() ).is( nil )
        end )
        
        -- booneUnit post-reset tests
        local privateUnitMembers = { features = "table", 
                                     resultTypes = "table",
                                     errorMsgs = "table",
                                     currentFeature = "nil", 
                                     currentTest = "nil", 
                                     orphanage = "function", 
                                     aHomeForOrphanTests = "nil" }
        memberTypeTest( "post-reset booneUnit", booneUnit, privateUnitMembers )
        
        -- features is empty
        _:test( "booneUnit.features has 0 length", function ()
            local f = booneUnit.features
            _:expect( #f ).is( 0 )
        end )
        _:test( "booneUnit.features is empty", function()
            local f = booneUnit.features
            local found = false
            for key, value in pairs( f ) do
                if key then found = true end
                if value then found = true end
            end
            _:expect( found==false ).is( true )
        end )
    end )
    
    -- booneUnit.test()
    _:describe( "booneUnit.test() returns a test object", function()
        _:test( "booneUnit.test() exists", function()
            _:expect( type( booneUnit.test ) ).is( "function" )
        end )
        -- test() returns a table
        _:test( "booneUnit:test( description_string, function ) returns a table", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            _:expect( type( booneUnit:test( testDesc, emptyTestFunc ) ) ).is( "table" )
        end )
        -- test() without arguments returns a table
        _:test( "booneUnit:test() without arguments returns a table", function()
            _:expect( type( booneUnit:test() ) ).is( "table" )
        end )
        -- properties of that table
        local testDesc = "Gingerbread Man"
        local emptyTestFunc = function() end 
        local testTable = booneUnit:test( testDesc, emptyTestFunc )
        local testTableProperties = { passed = "function",
                                      report = "function",
                                      results = "table" }
        memberTypeTest("booneUnit:test produces table", testTable, testTableProperties )
        
        -- length of table "results"
        _:test( "length of table results is 0 with empty test", function()
            local testTable = booneUnit:test( testDesc, emptyTestFunc )
            _:expect( #testTable.results ).is( 0 )
        end )
        
    end )
end

function testBooneUnitExpect()
    booneUnit:reset()
    _:describe( "booneUnit:expect() function", function()
        _:test( "expect() throws error if not inside a test", function()
            _:expect( function() booneUnit:expect() end ).throws( booneUnit.errorMsgs.expectWithoutTest )
        end )
        _:test( "expect() returns a table", function()
            booneUnit:reset()
            local expectation 
            booneUnit:test("foo Expectations", function() 
                expectation = booneUnit:expect( "foo" )
            end )
            _:expect( type( expectation ) ).is( "table" )
        end )
    end )
    
end

function lestMoonUnit() 
    -- Feature Creation --
    _:describe( "booneUnit creates Features", function ()
        
        _:before( function() end )
        
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
        
        -- features is empty
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
