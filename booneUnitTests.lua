
function bestBooneUnit()
    CodeaUnit.detailed = false
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
    
end

function bestMoonUnitFeature() 
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
    
function bestBooneUnitExpect()
    booneUnit:reset()
    _:describe( "Function booneUnit:expect() takes an argument and returns a set of functions which evaluate that argument.", function()
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
        -- booneUnit:expect() properties
        do
            booneUnit:reset()
            local expectationContains = { is = "function", 
                                          isnt = "function", 
                                          has = "function", 
                                          throws = "function" }
            local expectation
            booneUnit:test("foo Expectations", function() 
                expectation = booneUnit:expect( "foo" )
            end )
            memberTypeTest( 'booneUnit:expect("foo")', expectation, expectationContains )
        end
    end )
    _:describe( 'booneUnit:expect( var ).is( var ) returns true', function()
        local aVar = "bar"
        local emptyTable = {}
        local aTable = {"a","b","c"}
        local sameTable = aTable
        local aFunction = function(num) return num * num end
        local otherFunc = math.sin
        local equalities = {{ true, true },
                            { false, false },
                            { nil, nil },
                            {"foo", "foo"},
                            {"bar", "b".."ar"},
                            { aVar, "bar" },
                            {"24", string.format("%d", 24) },
                            { 24, 24 },
                            { -0.3269, -00.32690 },
                            { 4*2, 8 },
                            { emptyTable, emptyTable },
                            { aTable, sameTable },
                            { aFunction, aFunction },
                            { 4 * 4, aFunction( 4 ) },
                            { math.sin, otherFunc },
                            { math.sin(math.pi), otherFunc(math.pi) },
                            { vec2(5,2), vec2(5,2)},
                            { color(43)  , color(43,43,43)  } }
        for i, v in ipairs( equalities ) do
            local testDesc = string.format('booneUnit:expect(%s).is(%s) returns true', v[1], v[2] )
            _:test( testDesc, function()
                booneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                booneUnit:test( dweezilTestDesc, function() 
                    expectation = booneUnit:expect( v[1] )
                end )
                _:expect( expectation.is( v[2] ) ).is( true ) 
            end )
        end
    end )

    _:describe( 'booneUnit:expect( "a" ).is( "b" ) returns false', function()
        local inequalities = {{ true, false },
                              { true, "true"}, 
                              {"false", false },
                              {"foo", "bar"},
                              {"24", 24 },
                              { 3.0, math.pi },
                              { {}, {"a","b","c"} },
                              { {}, {} },
                              { math.cos, math.sin},
                              { function() end, function() end },
                              { vec2(5,2), vec2(5.2,2.5) }}
        for i, v in ipairs( inequalities ) do
            local testDesc = string.format('booneUnit:expect(%s).is(%s) returns false', v[1], v[2] )
            _:test( testDesc, function()
                booneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                booneUnit:test( dweezilTestDesc, function() 
                    expectation = booneUnit:expect( v[1] )
                end )
                _:expect( expectation.is( v[2] ) ).is( false ) 
            end )
        end
    end )

    _:describe( 'booneUnit:expect( var ).isnt( var ) returns false', function()
        local aVar = "bar"
        local emptyTable = {}
        local aTable = {"a","b","c"}
        local sameTable = aTable
        local aFunction = function(num) return num * num end
        local otherFunc = math.sin
        local equalities = {{ true, true },
                            { false, false },
                            { nil, nil },
                            {"foo", "foo"},
                            {"bar", "b".."ar"},
                            { aVar, "bar" },
                            {"24", string.format("%d", 24) },
                            { 24, 24 },
                            { -0.3269, -00.32690 },
                            { 4*2, 8 },
                            { emptyTable, emptyTable },
                            { aTable, sameTable },
                            { aFunction, aFunction },
                            { 4 * 4, aFunction( 4 ) },
                            { math.sin, otherFunc },
                            { math.sin(math.pi), otherFunc(math.pi) },
                            { vec2(5,2), vec2(5,2)},
                            { color(43)  , color(43,43,43)  } }
        for i, v in ipairs( equalities ) do
            local testDesc = string.format('booneUnit:expect(%s).is(%s) returns true', v[1], v[2] )
            _:test( testDesc, function()
                booneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                booneUnit:test( dweezilTestDesc, function() 
                    expectation = booneUnit:expect( v[1] )
                end )
                _:expect( expectation.isnt( v[2] ) ).is( false ) 
            end )
        end
    end )

    _:describe( 'booneUnit:expect( "a" ).isnt( "b" ) returns true', function()
        local inequalities = {{ true, false },
                              { true, "true"}, 
                              {"false", false },
                              {"foo", "bar"},
                              {"24", 24 },
                              { 3.0, math.pi },
                              { {}, {"a","b","c"} },
                              { {}, {} },
                              { math.cos, math.sin},
                              { function() end, function() end },
                              { vec2(5,2), vec2(5.2,2.5) }}
        for i, v in ipairs( inequalities ) do
            local testDesc = string.format('booneUnit:expect(%s).is(%s) returns false', v[1], v[2] )
            _:test( testDesc, function()
                booneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                booneUnit:test( dweezilTestDesc, function() 
                    expectation = booneUnit:expect( v[1] )
                end )
                _:expect( expectation.isnt( v[2] ) ).is( true ) 
            end )
        end
    end )
    
    _:describe( "booneUnit:expect( table ).has( value )", function()
    end )
    
end

function testBooneUnitTest()
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
        do
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testTable = booneUnit:test( testDesc, emptyTestFunc )
            local testTableProperties = { passed = "function",
                                          report = "function",
                                          results = "table",
                                          description = "string",
                                          registerResult = "function" }
            memberTypeTest("booneUnit:test produces table", testTable, testTableProperties )
        end
        
        -- length of table "results"
        _:test( "length of table results is 0 with empty test", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testTable = booneUnit:test( testDesc, emptyTestFunc )
            _:expect( #testTable.results ).is( 0 )
        end )
    end)
        --test registerResult(result, actual, expected)
    _:describe( "test:registerResult() appends a table to test.results", function()
        for i = 0, 5 do
            thisTestDesc = string.format( "call test.registerResult() %d times, results length is %d", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = "Stinky-Cheese Man"
                local anEmptyTestFunc = function() end 
                local testTable = booneUnit:test( aTestDesc, anEmptyTestFunc )
                for j = 1, i do
                    testTable:registerResult( true, "foo", "bar" )
                    --appends entry to table test.results
                end
                _:expect( #testTable.results ).is( i )
            end )
        end
    end )
    
end
