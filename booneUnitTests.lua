-- Test building helper functions
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
    
function testaBooneUnit()
    aBooneUnit = BooneUnit
    CodeaUnit.detailed = false
    aBooneUnit.silent = true

    -- aBooneUnit is something --
    _:describe( "aBooneUnit initial state", function()
        
        _:test( "aBooneUnit exists", function ()
            _:expect( aBooneUnit ).isnt( nil )
        end )
        
        -- Public methods list
        local publicUnitMethods = { describe = "function",
                                    reset = "function",
                                    ignore = "function",
                                    test = "function",
                                    delay = "function",
                                    before = "function",
                                    after = "function" }
        memberTypeTest( "public methods: aBooneUnit", aBooneUnit, publicUnitMethods )
        -- reset exists
        _:test( "reset exists", function ()
            _:expect( aBooneUnit.reset ).isnt( nil )
        end )
        
        -- do a reset
        _:test( "call aBooneUnit:reset() ", function ()
            _:expect( aBooneUnit:reset() ).is( nil )
        end )
        
        -- aBooneUnit post-reset tests
        local privateUnitMembers = { features = "table", 
                                     _tallyCategoryOrder = "table",
                                     _tallyCategoryNames = "table",
                                     errorMsgs = "table",
                                     currentFeature = "nil", 
                                     currentTest = "nil", 
                                     orphanage = "function", 
                                     continue = "function", 
                                     aHomeForOrphanTests = "nil" }
        memberTypeTest( "post-reset aBooneUnit", aBooneUnit, privateUnitMembers )
        
        -- Result categories 
        local definedTallyCategories = { "pass", "fail", "ignore", "pending", "empty" }
        _:test( string.format( "There are %d tally categories", #definedTallyCategories ), function ()
            _:expect( #aBooneUnit._tallyCategoryOrder ).is( #definedTallyCategories )
        end )
        -- tableHasValueTest()
        for i, v in ipairs(definedTallyCategories) do
            _:test( string.format( 'aBooneUnit.tallyCategoryOrder has "%s"', v ), function()
                _:expect( aBooneUnit._tallyCategoryOrder ).has( v )
            end)
        end
        for i, v in ipairs(definedTallyCategories) do
            _:test( string.format( 'aBooneUnit._tallyCategoryNames has key "%s"', v ), function()
                _:expect( aBooneUnit._tallyCategoryNames[ v ] ).isnt( nil )
            end)
        end
        
        -- features is empty
        _:test( "aBooneUnit.features has 0 length", function ()
            local f = aBooneUnit.features
            _:expect( #f ).is( 0 )
        end )
        _:test( "aBooneUnit.features is empty", function()
            local f = aBooneUnit.features
            local found = false
            for key, value in pairs( f ) do
                if key then found = true end
                if value then found = true end
            end
            _:expect( found==false ).is( true )
        end )
    end )
    
end
    
function testBooneUnitExpect()
    aBooneUnit = BooneUnit
    _.detailed = true
    aBooneUnit.silent = false
    aBooneUnit:reset()
    _:describe( "Function aBooneUnit:expect() takes an argument and returns" ..
                " a set of functions which evaluate that argument.", function()
        _:test( "expect() throws error if not inside a test", function()
            _:expect( function() aBooneUnit:expect() end ).throws( aBooneUnit.errorMsgs.expectWithoutTest )
        end )
        _:test( "expect() returns a table", function()
            aBooneUnit:reset()
            local expectation 
            aBooneUnit:test("foo Expectations", function() 
                expectation = aBooneUnit:expect( "foo" )
            end )
            _:expect( type( expectation ) ).is( "table" )
        end )
        -- aBooneUnit:expect() properties
        do
            aBooneUnit:reset()
            local expectationContains = { is = "function", 
                                          isnt = "function", 
                                          has = "function", 
                                          throws = "function" }
            local expectation
            aBooneUnit:test("foo Expectations", function() 
                expectation = aBooneUnit:expect( "foo" )
            end )
            memberTypeTest( 'aBooneUnit:expect("foo")', expectation, expectationContains )
        end
    end )
    _:describe( 'aBooneUnit:expect( var ).is( var ) returns true', function()
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
                            { color(43)    , color(43,43,43)  } }
        for i, v in ipairs( equalities ) do
            local testDesc = string.format('aBooneUnit:expect(%s).is(%s) returns true', v[1], v[2] )
            _:test( testDesc, function()
                aBooneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                aBooneUnit:test( dweezilTestDesc, function() 
                    expectation = aBooneUnit:expect( v[1] )
                end )
                _:expect( expectation.is( v[2] ) ).is( true ) 
            end )
        end
    end )

    _:describe( 'aBooneUnit:expect( "a" ).is( "b" ) returns false', function()
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
            local testDesc = string.format('aBooneUnit:expect(%s).is(%s) returns false', v[1], v[2] )
            _:test( testDesc, function()
                aBooneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                aBooneUnit:test( dweezilTestDesc, function() 
                    expectation = aBooneUnit:expect( v[1] )
                end )
                _:expect( expectation.is( v[2] ) ).is( false ) 
            end )
        end
    end )

    _:describe( 'aBooneUnit:expect( var ).isnt( var ) returns false', function()
        local aVar = "bar"
        local emptyTable = {}
        local aTable = {"a","b","c"}
        local sameTable = aTable
        local aFunction = function(num) return num * num end
        local otherFunc = math.sin
        local equalities = {
            { true, true },
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
            { color(43)  , color(43,43,43)  } 
        }
        for i, v in ipairs( equalities ) do
            local testDesc = string.format('aBooneUnit:expect(%s).is(%s) returns true', v[1], v[2] )
            _:test( testDesc, function()
                aBooneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                aBooneUnit:test( dweezilTestDesc, function() 
                    expectation = aBooneUnit:expect( v[1] )
                end )
                _:expect( expectation.isnt( v[2] ) ).is( false ) 
            end )
        end
    end )

    _:describe( 'aBooneUnit:expect( "a" ).isnt( "b" ) returns true', function()
        local inequalities = {{ true, false },
                              { true, "true"}, 
                              {"false", false },
                              {"foo", "bar"},
                              {"24", 24 },
                              { 3.0, math.pi },
                              { {"a","b"}, {"a","b","c"} },
                              { {}, {} },
                              { math.cos, math.sin},
                              { function() end, function() end },
                              { vec2(5,2), vec2(5.2,2.5) }}
        for i, v in ipairs( inequalities ) do
            local testDesc = string.format('aBooneUnit:expect(%s).is(%s) returns false', v[1], v[2] )
            _:test( testDesc, function()
                aBooneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "Equality-- %s:%s == %s:%s", 
                                        type(v[1]), v[1], type(v[2]), v[2] )
                aBooneUnit:test( dweezilTestDesc, function() 
                    expectation = aBooneUnit:expect( v[1] )
                end )
                _:expect( expectation.isnt( v[2] ) ).is( true ) 
            end )
        end
    end )
    
    _:describe( "aBooneUnit:expect( table ).has( value ) returns true when"..
                " the table has that value stored under any key", function()
        local aVar = "bar"
        local emptyTable = {}
        local alphaTable = {"a","b","c"}
        local sameTable = alphaTable
        local aFunction = function(num) return num * num end
        local otherFunc = math.sin
        local aVector = vec2(5,2)
        local aColor = color(43)
        local aTable = { first = true, true, false, "foo", aVar, "24", 24, 
                         emptyTable, alphaTable, aFunction, otherFunc,
                         aFunction(otherFunc(16)), 0.3296, math.pi, 
                         aVector, aColor}
        local bTable = { true, false, "foo", "bar", "24", 24, 
                         emptyTable, sameTable, aFunction, math.sin,
                         aFunction(math.sin(16)), 00.329600, math.pi, 
                         vec2(5,2), aColor }
        for i, v in ipairs( bTable ) do
            local testDesc = string.format('aBooneUnit:expect(table).has(%s)', v )
            _:test( testDesc, function()
                aBooneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "table has value %s:%s ", type(v), v )
                aBooneUnit:test( dweezilTestDesc, function() 
                    expectation = aBooneUnit:expect( aTable )
                end )
                _:expect( expectation.has( v ) ).is( true ) -- does this need to be moved out like this?
            end )
        end
    end )
    
    _:describe( "aBooneUnit:expect( table ).has( value ) returns false when"..
                " the table does not have that value stored under any key", function()
        local aVar = "bar"
        local baz = nil
        local emptyTable = {}
        local alphaTable = {"a","b","c"}
        local sameTable = alphaTable
        local aFunction = function(num) return num * num end
        local otherFunc = math.sin
        local aVector = vec2(5,2)
        local aColor = color(43)
        local aTable = { true, "false", "foo", aVar, baz, 24, 
                         emptyTable, alphaTable, aFunction, otherFunc,
                         aFunction(otherFunc(16)), 0.3296, math.pi, 
                         aVector, color(86)  }
        local bTable = { "true", false, "Foo", "bear", "baz", "24",  
                         {}, {"a","b","c"}, function(n)return n*n;end, math.cos,
                         aFunction(otherFunc(15.99)), -0.3296, 3.1415, 
                         vec2(5,3), aColor }
        for i, v in ipairs( bTable ) do
            local testDesc = string.format('aBooneUnit:expect(table).has(%s)', v )
            _:test( testDesc, function()
                aBooneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "table has value %s:%s ", type(v), v )
                aBooneUnit:test( dweezilTestDesc, function() 
                    expectation = aBooneUnit:expect( aTable )
                end )
                _:expect( expectation.has( v ) ).is( false ) 
            end )
        end
    end )
    
    -- Testing aBooneUnit:expect().throws()
    _:describe( 'aBooneUnit:expect( <function> ).throws( <something> ) executes the function'..
        ' given to expect() and returns true if it throws an error containing <error>'..
        ' ( usually a string )', function()
        -- produces failed result if expect( arg ); arg is not a function.
        _:test( 'expect( func ).throws() throws error if no function is evaluated', function()
            local expectation 
            local throwTest = aBooneUnit:test( "a nil expectation", function()
                expectation = aBooneUnit:expect( nil )
            end )
            _:expect( function() expectation:throws("") end ).throws( aBooneUnit.errorMsgs.throwsArgIsNotFunction )
        end )
        
        -- executes function argument
        _:test( '"expect( <func> ).throws()" executes <func>', function()
            local didThisStuff = false
            aBooneUnit:test( "do some stuff", function()
                aBooneUnit:expect( function() didThisStuff = true end ).throws("")
            end )
            _:expect( didThisStuff ).is( true )
        end )
    
        -- produces failed result if function does not throw error
        _:test( 'expect().throws() returns false if no error is thrown', function()
            local expectation 
            aBooneUnit:test( "don't throw error", function()
                expectation = aBooneUnit:expect( function() print("No error") end )
            end )
            _:expect( expectation.throws("") ).is( false )
        end )
    end )
    
    -- produces passing result if throws() has no argument and any error is thrown
    _:describe( 'aBooneUnit:expect( <function> ).throws( nil ) returns true for any error\n', function()
        local thingsToThrow = { "", "a foo test", "a bar exam", 7, math.pi, {"table"}, function() end }        
            for i, v in ipairs( thingsToThrow ) do
            _:test( string.format( 'expect( <function> ).throws() \ncatches: %s', v ), function()
                local expectation 
                aBooneUnit:test( string.format("throw and catch: %s", v ), function()
                    expectation = aBooneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws() ).is( true )
            end )
        end
        _:test( 'expect( <function> ).throws( nil ) \ncatches: nil', function()
            local expectation 
            aBooneUnit:test( 'throw and catch: nil', function()
                expectation = aBooneUnit:expect( function()
                    error( nil )
                end )
            end )
            _:expect( expectation.throws() ).is( true )
        end )
    end )
        
    _:describe( 'aBooneUnit:expect(<func>).throws( "" ) returns true if any error string is thrown', function()
        local stringsToThrow = { "", "a foo test", "a bar exam", "error", "aBooneUniterrorMsgsexpectWithoutTest" }        
        for i, v in ipairs( stringsToThrow ) do
            _:test( string.format( 'expect( <function throws "%s"> ).throws("") \ncatches: "%s"', v, v ), function()
                local expectation 
                aBooneUnit:test( string.format('throw and catch: "%s"', v ), function()
                    expectation = aBooneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws( "" ) ).is( true )
            end )
        end
        local notStringsToThrow = { {}, 7, function()end, vec2(4,5) }
        for i, v in ipairs( notStringsToThrow ) do
            _:test( string.format( 'expect( <function throws %s> ).throws("")'..
            ' \ndoes not catch: "%s"', type(v), v ), function()
                local expectation 
                aBooneUnit:test( string.format('throw and catch: "%s"', v ), function()
                    expectation = aBooneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws( "" ) ).is( false )
            end )
        end
        _:test( 'expect( <function throws nil> ).throws("") \ncatches: nil', function()
            local expectation 
            aBooneUnit:test( 'throw and catch: nil', function()
                expectation = aBooneUnit:expect( function()
                    error( nil )
                end )
            end )
            _:expect( expectation.throws( "" ) ).is( false )
        end )
    end )
    
    _:describe( 'aBooneUnit:expect(<func>).throws( <string> ) returns true'..
        ' only if <string> is found in the error', function()
        local barStrings = { "bar", "Barbara", "foobar" }
        for i, v in ipairs( barStrings ) do
            _:test( string.format( 'expect( <function throws "%s"> ).throws("bar") \ncatches: "%s"', v, v ), function()
                local expectation 
                aBooneUnit:test( 'catch: "bar"', function()
                    expectation = aBooneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws( "bar" ) ).is( true )
            end )
        end
        local barlessValues = { "Bar", "Foo", "Hannah-Barbera", "b ar", "", 7, {}, function()end }
        for i, v in ipairs( barlessValues ) do
            _:test( string.format( 'expect( <function throws "%s"> ).throws("bar") \n not caught', v ), function()
                local expectation 
                aBooneUnit:test( 'catch: "bar"', function()
                    expectation = aBooneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws( "bar" ) ).is( false )
            end )
        end
        
    end )
end

function testBooneUnitIgnore()    
    -- Testing aBooneUnit.ignore()
    _:describe( "aBooneUnit.ignore() stores a result but does not run a test", function()
        _:test( "aBooneUnit.ignore is a function", function()        
            _:expect( type( aBooneUnit.ignore ) ).is( "function" )
        end )
        -- ignore() returns a table
        _:test( "aBooneUnit:ignore( description_string, function ) returns a table", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            _:expect( type( aBooneUnit:ignore( testDesc, emptyTestFunc ) ) ).is( "table" )
        end )
        -- test() without arguments returns a table
        _:test( "aBooneUnit:ignore() without arguments returns a table", function()
            _:expect( type( aBooneUnit:ignore() ) ).is( "table" )
        end )
        -- test() returns a table of class NewTable
        _:test( "aBooneUnit:ignore() returns a table of class NewTable", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testReturn = aBooneUnit:ignore( testDesc, emptyTestFunc )
            _:expect( testReturn:is_a( aBooneUnit.TestInfo ) ).is( true )

        end )
        -- properties of that table
        do
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testTable = aBooneUnit:ignore( testDesc, emptyTestFunc )
            local testTableProperties = { passed = "function",
                                          report = "function",
                                          results = "table",
                                          description = "string",
                                          registerResult = "function" }
            memberTypeTest("aBooneUnit:ignore produces object", testTable, testTableProperties )
        end
        _:test( "aBooneUnit:ignore():passed() returns false", function() 
            aBooneUnit:reset()
            local testTable = aBooneUnit:ignore( "one true result", function()
                aBooneUnit:expect(true).is(true)
            end )
            _:expect( testTable:passed() ).is( false )
        end )
        _:test( 'aBooneUnit:ignore():status() returns "ignore"', function() 
            aBooneUnit:reset()
            local testTable = aBooneUnit:ignore( "one true result", function()
                aBooneUnit:expect(true).is(true)
            end )
            _:expect( testTable:status() ).is( "ignore" )
        end )
    end )
end

function testBooneUnitTest()
    aBooneUnit:reset()
    CodeaUnit.detailed = false
    aBooneUnit.silent = true
    -- aBooneUnit.test()
    _:describe( "aBooneUnit.test() produces and stores a TestInfo object", function()
        _:test( "aBooneUnit.test() exists", function()
            _:expect( type( aBooneUnit.test ) ).is( "function" )
        end )
        -- test() returns a table
        _:test( "aBooneUnit:test( description_string, function ) returns a table", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            _:expect( type( aBooneUnit:test( testDesc, emptyTestFunc ) ) ).is( "table" )
        end )
        -- test() without arguments returns a table
        _:test( "aBooneUnit:test() without arguments returns a table", function()
            _:expect( type( aBooneUnit:test() ) ).is( "table" )
        end )
        -- test() returns a table of class TestInfo
        _:test( "aBooneUnit:test() returns a table of class TestInfo", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testReturn = aBooneUnit:test( testDesc, emptyTestFunc )
            _:expect( testReturn:is_a( aBooneUnit.TestInfo ) ).is( true )
        end )
        -- properties of that table
        do
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testTable = aBooneUnit:test( testDesc, emptyTestFunc )
            local testTableProperties = { description = "string",
                                          feature = "table",
                                          results = "table",
                                          passed = "function",
                                          report = "function",
                                          registerResult = "function" }
            memberTypeTest("aBooneUnit:test produces table", testTable, testTableProperties )
        end
        
        _:test( 'This TestInfo table is stored in the "tests" table of the feature that encloses it', function()
            local thisFeature, thisTest
            thisFeature = aBooneUnit:describe( "A standard feature", function()
                thisTest = aBooneUnit:test( "Your basic non-test", function() end )
            end )
            _:expect( thisFeature.tests ).has( thisTest )
        end )
        _:test( 'Therefore, this TestInfo table will be found in the "tests" table of the parent feature', function()
            local thisFeature, thisTest
            thisFeature = aBooneUnit:describe( "Another standard feature", function()
                thisTest = aBooneUnit:test( "Your basic non-test", function() end )
            end )
            _:expect( thisTest.feature.tests ).has( thisTest )
        end )
        
        -- length of table "results"
        _:test( 'With empty test, length of table "results" is 0', function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testTable = aBooneUnit:test( testDesc, emptyTestFunc )
            _:expect( #testTable.results ).is( 0 )
        end )
    end)
    --test.registerResult() appends table
    _:describe( "TestInfo:registerResult() appends a table to test.results", function()
        for i = 0, 5 do
            thisTestDesc = string.format( "call test.registerResult() %d times, results length is %d", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = "Stinky-Cheese Man"
                local anEmptyTestFunc = function() end 
                local testTable = aBooneUnit:test( aTestDesc, anEmptyTestFunc )
                for j = 1, i do
                    testTable:registerResult( true, "foo", "bar" )
                end
                _:expect( #testTable.results ).is( i )
            end )
        end
    end )
    
    --test.registerResult(result, actual, expected) stores data
    _:describe( "TestInfo:registerResult(outcome, expected, actual) stores data in test.results", function()
        for i = 1, 5 do
            thisTestDesc = string.format( 'registerResult(true, "foo", n^2); result[n] matches; n=%d', i )
            _:test( thisTestDesc, function() 
                local aTestDesc = "Stinky-Cheese Man"
                local anEmptyTestFunc = function() end 
                local testTable = aBooneUnit:test( aTestDesc, anEmptyTestFunc )
                for j = 1, i do
                    testTable:registerResult( true, "foo", j*j )
                    --appends entry to table test.results
                end
                local target = testTable.results[#testTable.results]
                _:expect( target.expected ).is( i*i )
            end )
        end
    end )
    
    -- aBooneUnit:expect().is() also appends a table to aTest.results
    _:describe( '"aBooneUnit:expect().is()" appends a table to aTest.results', function()
        for i = 0, 5 do
            thisTestDesc = string.format( "call expect().is() %d times, results length is %d", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                local testTable = aBooneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        aBooneUnit:expect( j*j ).is( j*j )
                    end
                end )
                _:expect( #testTable.results ).is( i )
            end )
        end
    end )
    
    -- aBooneUnit:expect().is() stores data in [test].results
    _:describe( '"aBooneUnit:expect().is()" stores data in [test].results', function()
        for i = 1, 5 do
            thisTestDesc = string.format( "call expect(n).is(n) %d times, results[%d] contains n", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                local testTable = aBooneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        aBooneUnit:expect( j*j ).is( j*j )
                    end
                end )
                target = testTable.results[ #testTable.results ]
                _:expect( target.actual ).is( i*i )
            end )
        end
    end )
    
    -- aBooneUnit:expect().isnt() stores data in [test].results
    _:describe( "aBooneUnit:expect().isnt() stores data in [test].results", function()
        for i = 1, 3 do
            thisTestDesc = string.format( "call expect(n).isnt(n) %d times, results[%d] contains n", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                local testTable = aBooneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        aBooneUnit:expect( j*j ).isnt( j*j )
                    end
                end )
                target = testTable.results[ #testTable.results ]
                _:expect( target.outcome ).is( false )
            end )
        end
    end )
    
    -- aBooneUnit:expect().has() stores data in [test].results
    _:describe( "aBooneUnit:expect().has() stores data in [test].results", function()
        local someData = { lat = 834.5677, long = true }
        local aTable = { "foo", "bar", other = "baz", diameter = math.pi, vip = someData, vec3(24,7,365.25) }
        local bTable = { "foo", "Bar", someData, math.pi } 
        for i, v in ipairs( bTable ) do
            thisTestDesc = string.format( "call expect( table ).has( value ) %d times," ..
                                          " results[%d] contains value %s", i, i, v )
            -- not working! (due to making has results more descriptive)
            _:ignore( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                 testTable = aBooneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        aBooneUnit:expect( aTable ).has( bTable[ j ] )
                    end
                end )
                target = testTable.results[ #testTable.results ]
                _:expect( target.expected ).is( v )
            end )
        end
    end )

    -- aBooneUnit:test():passed() 
    --      returns true if all results are true and there is at least one result. 
    _:describe( "aBooneUnit:test():passed()\nReturns true only if there is at least one result,"..
                " and all results are true", function()
        _:test( "passed() returns false if there were no results", function() 
            aBooneUnit:reset()
            local testTable = aBooneUnit:test( "an empty test", function()end )
            _:expect( testTable:passed() ).is( false )
        end )
        _:test( "passed() returns true if there is one true result", function()
            local testTable = aBooneUnit:test( "one true result", function()
                aBooneUnit:expect(true).is(true)
            end )
            _:expect( testTable:passed() ).is( true )
        end)
        _:test( "passed() returns true if there are two true results", function()
            local testTable = aBooneUnit:test( "two true results", function()
                aBooneUnit:expect(true).is(true)
                aBooneUnit:expect(false).is(false)
            end )
            _:expect( testTable:passed() ).is( true )
        end)
        
        _:test( "passed() returns true if there are ten true results", function()
            local testTable = aBooneUnit:test( "ten true results", function()
                for i = 1, 5 do
                    aBooneUnit:expect(true).is(true)
                    aBooneUnit:expect(false).is(false)
                end
            end )
            _:expect( testTable:passed() ).is( true )
        end)
        
        _:test( "passed() returns false if there is one false result", function()
            local testTable = aBooneUnit:test( "one false result", function()
                aBooneUnit:expect(true).is(false)
            end )
            _:expect( testTable:passed() ).is( false )
        end)
        
        _:test( "passed() returns false if there are ten true results and one false one", function()
            local testTable = aBooneUnit:test( "ten true results, one false", function()
                for i = 1, 5 do
                    aBooneUnit:expect(true).is(true)
                    aBooneUnit:expect(false).is(false)
                end
                aBooneUnit:expect(false).is(true)
            end )
            _:expect( testTable:passed() ).is( false )
        end)
        
    end )
    
    -- aBooneUnit:test():status() 
    --      Returns a string describing the aggregate result status
    --      ( Empty | Ignored ) < Passed < Failed
    --      ! no ignored test yet !
    --      ! no pending test yet !
    _:describe( 'aBooneUnit:test():status()\nReturns a string describing the aggregate result status', function()
        _:test( 'status() returns "empty" if there were no results', function() 
            aBooneUnit:reset()
            local testTable = aBooneUnit:test( "an empty test", function() end )
            _:expect( testTable:status() ).is( "empty" )
        end )
        _:test( "status() returns 'pass' if there is one true result", function()
            local testTable = aBooneUnit:test( "one true result", function()
                aBooneUnit:expect(true).is(true)
            end )
            _:expect( testTable:status() ).is( "pass" )
        end)
        _:test( "status() returns 'pass' if there are two true results", function()
            local testTable = aBooneUnit:test( "two true results", function()
                aBooneUnit:expect(true).is(true)
                aBooneUnit:expect(false).is(false)
            end )
            _:expect( testTable:status() ).is( "pass" )
        end)
        
        _:test( "status() returns 'pass' if there are ten true results", function()
            local testTable = aBooneUnit:test( "ten true results", function()
                for i = 1, 5 do
                    aBooneUnit:expect(true).is(true)
                    aBooneUnit:expect(false).is(false)
                end
            end )
            _:expect( testTable:status() ).is( "pass" )
        end)
        
        _:test( "status() returns 'fail' if there is one false result", function()
            local testTable = aBooneUnit:test( "one false result", function()
                aBooneUnit:expect(true).is(false)
            end )
            _:expect( testTable:status() ).is( "fail" )
        end)
        
        _:test( "status() returns 'fail' if there are ten true results and one false one", function()
            local testTable = aBooneUnit:test( "ten true results, one false", function()
                for i = 1, 5 do
                    aBooneUnit:expect(true).is(true)
                    aBooneUnit:expect(false).is(false)
                end
                aBooneUnit:expect(false).is(true)
            end )
            _:expect( testTable:status() ).is( "fail" )
        end)

    end )
end

function bestBooneUnitDelay()
    CodeaUnit.detailed = false
    aBooneUnit.silent = true
    _:describe( 'aBooneUnit:delay() executes the conclusion of a test'..
        ' after a certain amount of time has passed', function()
        aBooneUnit:reset()
        _:test( "aBooneUnit:delay() is a function", function()
            _:expect( type( aBooneUnit.delay ) ).is( "function" )
        end )
        _:test( "aBooneUnit:continue() is a function", function()
            _:expect( type( aBooneUnit.continue ) ).is( "function" )
        end )
        _:test( "aBooneUnit:delay() throws error if not inside a test", function()
            _:expect( function() aBooneUnit:delay() end ).throws( aBooneUnit.errorMsgs.delayWithoutTest )
        end )
        _:test( "aBooneUnit:delay() sets test status to pending", function()
            local doneDelayStuff = false
            local testTable = aBooneUnit:test( "do a delay", function()
                aBooneUnit:delay( 0.01, function() 
                    doneDelayStuff = true
                    _:expect( aBooneUnit.currentTest:status() ).is( "pending" )
                end )
            end )
        end )
        _:test( "aBooneUnit:continue() removes pending status ", function()
            local doneDelayStuff = false
            local testTable = aBooneUnit:test( "do a delay", function()
                aBooneUnit:delay( 0.001, function() 
                    doneDelayStuff = true
                end )
            end )
            tween.delay( 0.2, function()
                _:expect( testTable:status() ).isnt( "pending" )
            end )
        end )
        ---[[
        _:test( "aBooneUnit:continue() runs the function passed in aBooneUnit.delay", function()
            local doneDelayStuff = false
            aBooneUnit:test( "do a delay", function()
                print( "getting ready" )
                aBooneUnit:delay( 0.001, function() 
                    doneDelayStuff = true
                end )
                print( "did it work?" )
            end )
            tween.delay( 0.5, function() 
                _:expect( doneDelayStuff ).is( true )
            end )
        end )
        _:test( "aBooneUnit:expect() statements inside aBooneUnit:delay()"..
            " will register results with the appropriate test", function()
            local doneDelayStuff = false
            local test1 = aBooneUnit:test( "do a delay", function()
                aBooneUnit:delay( 0.8, function()
                    print("ok, back to work")
                    local thing = 5
                    aBooneUnit:expect( thing ).is(5)
                    doneDelayStuff = true
                end )
                print( "that's it for now" )
            end )
            local test2 = aBooneUnit:test( "empty test", function()end )
            tween.delay( 1, function()
                print( string.format( 'test1 status: %s', test1:status() ) )
                print( string.format( 'test2 status: %s', test2:status() ) )
                _:expect( test1:status() ).is( "pass" )
            end )
        end )
        --]]
    end )
    tween.delay( 2, function()
        _:summarize()
    end )
end


function testBooneUnitFeature() 
    -- Feature Creation --
    CodeaUnit.detailed = true
    aBooneUnit.silent = false
    aBooneUnit:reset()
    local atestDesc = "location: Springfield"
    local atestFunc = function ()
        print( "324 Evergreen Terrace" )
        return "Shelbyville"
    end
    local aFeatureDesc = "HomerSimpson"
    local aFeatureFunc = function() 
        print("woo-hoo!")
        aBooneUnit:test( testDesc, testFunc )
        return( 42 )
    end        
    _:describe( "aBooneUnit:describe() produces and stores a FeatureInfo object", function ()
        -- features is empty
        _:test( "after reset, aBooneUnit.features is empty", function ()
            aBooneUnit:reset()
            local f = aBooneUnit.features
            _:expect( f[1] ).is( nil )
            _:expect( #f ).is( 0 )
        end )
        
        _:test( "aBooneUnit.currentFeature is nil", function ()
            aBooneUnit:reset()
            _:expect( aBooneUnit.currentFeature ).is( nil )
        end )
        
        --call :describe()
        _:test( "call describe(), returns table", function ()
            _:expect( type( aBooneUnit:describe( aFeatureDesc, aFeatureFunc ) ) ).is( "table" )
        end )
        
        -- features not empty
        _:test( "The table returned by describe() is stored in aBooneUnit.features ", function ()
            aBooneUnit:reset()
            local myFeatureData = aBooneUnit:describe( "Empty Feature", function() end )
            _:expect( #aBooneUnit.features ).is( 1 )
            _:expect( aBooneUnit.features[1] ).isnt( nil )
            _:expect( aBooneUnit.features[1] ).is( myFeatureData )
        end )
        
        -- features not empty
        _:test( "The table returned by describe() is stored in aBooneUnit.features ", function ()
            aBooneUnit:reset()
            local someFeatureData = aBooneUnit:describe( aFeatureDesc, aFeatureFunc )
            local anotherFeatureData = aBooneUnit:describe( aFeatureDesc, aFeatureFunc )
            _:expect( someFeatureData ).isnt( anotherFeatureData )
            _:expect( #aBooneUnit.features ).is( 2 )
            _:expect( aBooneUnit.features[1] ).is( someFeatureData )
            _:expect( aBooneUnit.features[2] ).is( anotherFeatureData )
        end )
        
        _:test( "aBooneUnit.currentFeature is nil again", function ()
            _:expect( aBooneUnit.currentFeature ).is( nil )
        end )
    end )
    -- Feature Properties --
    _:describe( '"aBooneUnit:describe()" returns a FeatureInfo table, and stores that table', function()
        -- feature members 
        aBooneUnit:reset()
        local someFeatureData = aBooneUnit:describe( aFeatureDesc, aFeatureFunc )
        
        local featureMembers = { description = "string", 
                                 tests = "table", 
                                 makeTest = "function",
                                 intro = "function",
                                 tally = "function",
                                 report = "function",
                                 before = "function",
                                 after = "function" }
        memberTypeTest( "someFeatureData", someFeatureData, featureMembers )
        
        local featureValues = { description = aFeatureDesc, 
                                makeTest = aBooneUnit.FeatureInfo.makeTest,
                                intro   = aBooneUnit.FeatureInfo.intro, 
                                tally   = aBooneUnit.FeatureInfo.tally, 
                                report  = aBooneUnit.FeatureInfo.report, 
                                before  = aBooneUnit.FeatureInfo.before, 
                                after   = aBooneUnit.FeatureInfo.after }
        memberValueTest( "someFeatureData", someFeatureData, featureValues )
        
    end )
    
    _:describe( 'Test statements enclosed in a "describe()" statement produce'..
                ' TestInfo objects that are stored in "<FeatureInfo>.tests"', function() 
        -- Create a feature with some tests...
        local thisFeatureInfo, testOneInfo, testTwoInfo, testThreeInfo
        thisFeatureInfo = aBooneUnit:describe( "An Uneventful Group of Tests", function() 
            testOneInfo = aBooneUnit:test( "empty" )
            testTwoInfo = aBooneUnit:test( "passable", function() 
                aBooneUnit:expect( "foo" ).is( "foo" )
            end )
            testThreeInfo = aBooneUnit:test( "impassable", function() 
                aBooneUnit:expect( "foo" ).is( "bar" )
            end )
        end )
        -- ...Check the data in the feature object
        _:test( '"<FeatureInfo>.tests[1]" is <testOneInfo>', function()
            _:expect( thisFeatureInfo.tests[1] ).is( testOneInfo )
        end )
        _:test( '"<FeatureInfo>.tests[2]" is <testTwoInfo>', function()
            _:expect( thisFeatureInfo.tests[2] ).is( testTwoInfo )
        end )
        _:test( '"<FeatureInfo>.tests[3]" is <testThreeInfo>', function()
            _:expect( thisFeatureInfo.tests[3] ).is( testThreeInfo )
            _:expect( #thisFeatureInfo.tests ).is( 3 )
        end )
    end )
    
    
    _:describe( '"FeatureInfo:makeTest()" returns a TestInfo object', function()
        aBooneUnit:reset()
        --[[
        aBooneUnit:reset()
        local thisFeatureInfo, testOneInfo, testTwoInfo, testThreeInfo
        thisFeatureInfo = aBooneUnit:describe( "A Feature Description String")
        testOneInfo = thisFeatureInfo:makeTest( thisFeatureInfo, "empty" )
        testTwoInfo = thisFeatureInfo:makeTest( thisFeatureInfo, "passable", function()
            aBooneUnit:expect( "foo" ).is( "foo" )
        end )
        
        testThreeInfo = thisFeatureInfo:makeTest( thisFeatureInfo, "impassable", function()
            aBooneUnit:expect( "foo" ).is( "bar" )
        end )
        --]]
        _:test( 'returns table', function()
            aBooneUnit:reset()
            local thisFeatureInfo, testOneInfo, testTwoInfo, testThreeInfo
            thisFeatureInfo = aBooneUnit:describe( "A Feature Description String")
            testOneInfo = thisFeatureInfo:makeTest( thisFeatureInfo, "empty" )
            _:expect( type(testOneInfo)== 'table' ).is( true )
        end )
        _:test( 'returns TestInfo object', function()
            aBooneUnit:reset()
            local thisFeatureInfo, testOneInfo, testTwoInfo, testThreeInfo
            thisFeatureInfo = aBooneUnit:describe( "A Feature Description String")
            testOneInfo = thisFeatureInfo:makeTest( thisFeatureInfo, "empty" )
            _:expect( testOneInfo:is_a( aBooneUnit.TestInfo ) ).is( true )
        end )
        --next test BooneUnit:ignore ? or do existing tests
    end )


    _:describe( '"FeatureInfo:tally()" returns a table summarizing the outcomes of the tests in the feature', function()
        _:test( "FeatureInfo:tally() returns a table", function() 
            aBooneUnit:reset()
            local thisFeature = aBooneUnit:describe( "An Example for Tallying", function() 
                aBooneUnit:test()
            end )
            _:expect( type( thisFeature:tally() ) ).is( "table" )
        end )
        _:test( "FeatureInfo:tally() table has key indicating total number of tests ", function() 
            aBooneUnit:reset()
            local thisFeature = aBooneUnit:describe( "An Example for Tallying", function() 
                aBooneUnit:test()
            end )
            _:expect( thisFeature:tally().total ).isnt( nil )
        end )
        _:test( "FeatureInfo:tally() table has key holding sum of each category of test status"..
                ", if sum is zero, that key is nil", function() 
            aBooneUnit:reset()
            local thisFeature = aBooneUnit:describe( "An Example for Tallying", function() 
                aBooneUnit:test( "#1 Empty test" )
                aBooneUnit:test( "#2 Empty test" )
                aBooneUnit:test( "#3 Empty test" )
                aBooneUnit:test( "#1 Passing test", function()
                    aBooneUnit:expect( 1 + 1 ).is( 2 )
                end )
                aBooneUnit:test( "#2 Passing test", function()
                    aBooneUnit:expect( 2 + 2 ).is( 4 )
                end )
                aBooneUnit:test( "#1 Failing test", function()
                    aBooneUnit:expect( true ).is( false )
                end )
                aBooneUnit:ignore( "#1 Ignored test", function()
                    aBooneUnit:expect( 2 + 2 ).is( 4 )
                end )
            end )
            _:expect( thisFeature:tally().total ).is( 7 )
            _:expect( thisFeature:tally().empty ).is( 3 )
            _:expect( thisFeature:tally().pass ).is( 2 )
            _:expect( thisFeature:tally().fail ).is( 1 )
            _:expect( thisFeature:tally().ignore ).is( 1 )
            _:expect( thisFeature:tally().pending ).is( nil )
        end )
    end )
    _:describe( '"FeatureInfo:report()" returns a string summarizing the outcomes of'..
            ' the tests in the feature', function()
        aBooneUnit:reset()
        local thisFeature = aBooneUnit:describe( "An Example for Reporting", function() 
            aBooneUnit:test( "#1 Empty test" )
            aBooneUnit:test( "#2 Empty test" )
            aBooneUnit:test( "#3 Empty test" )
            aBooneUnit:test( "#4 Empty test" )
            aBooneUnit:test( "#1 Passing test", function()
                aBooneUnit:expect( 1 + 1 ).is( 2 )
            end )
            aBooneUnit:test( "#2 Passing test", function()
                aBooneUnit:expect( 2 + 2 ).is( 4 )
            end )
            aBooneUnit:test( "#3 Passing test", function()
                aBooneUnit:expect( 3 * 3 ).is( 9 )
            end )
            aBooneUnit:test( "#1 Failing test", function()
                aBooneUnit:expect( true ).is( false )
            end )
            aBooneUnit:test( "#2 Failing test", function()
                aBooneUnit:expect( "foo" ).is( "bar" )
            end )
            aBooneUnit:ignore( "#1 Ignored test", function()
                aBooneUnit:expect( 2 + 2 ).is( 4 )
            end )
        end )
        _:test( "FeatureInfo:report() returns a string", function() 
            _:expect( type( thisFeature:report() ) ).is( "string" )
        end )
        local featureTally = thisFeature:tally()
        local featureReport = thisFeature:report()
        _:test( 'report string contains number of total tests: 10', function()
            print( featureReport )
            _:expect( string.find( featureReport, featureTally.total ) ).isnt( nil )
        end )
        featureTally.total = nil  -- Already tested, need this empty to do the next section of tests
        for key, value in pairs( featureTally ) do
            _:test( string.format( 'report string contains "%s" and sum: %d',
                aBooneUnit._tallyCategoryNames[key], value ), function()
                print( featureReport )
                _:expect( string.find( featureReport, value .. " " ) ).isnt( nil )
                _:expect( string.find( featureReport, aBooneUnit._tallyCategoryNames[key] ) ).isnt( nil )
            end )
        end
        _:test( 'If a result category is empty, such as "pending" in this case,'..
                ' then it is not present in the report string', function() 
            _:expect( string.find( featureReport, aBooneUnit._tallyCategoryNames.pending ) ).is( nil )
        end )
    end )
    
end

function testTheMostRecent()
    CodeaUnit.detailed = true
    aBooneUnit.silent = nil
    
    _:describe( 'TestInfo:report()\nReturns a string describing the individual results of that test', function()
        aBooneUnit:reset()
        _:test( '"aBooneUnit:test():report()" returns a string', function() 
            _:expect( type( aBooneUnit:test():report() ) ).is( "string" )
        end )
        _:test( ' the "TestInfo:report()" string contains the test description string', function()
            local testDescription = "Blah Blah Blah and so on" 
            local testReportString = aBooneUnit:test( testDescription ):report()
            _:expect( string.find( testReportString, testDescription ) ).isnt( nil )
        end )
        _:test( ' the "TestInfo:report()" string contains the test status', function()
            local testDescription = "Blah Blah Blah and so on" 
            local aTest = aBooneUnit:test( testDescription, function()
                aBooneUnit:expect( true ).isnt( false )
            end)
            _:expect( string.find( aTest:report(), aTest:status() ) ).isnt( nil )
        end )
        _:test( ' the "TestInfo:report()" string contains an entry for each ":expect()" statement in the test', function()
            local testDescription = "Double Expectation" 
            local aTest = aBooneUnit:test( testDescription, function()
                aBooneUnit:expect( true ).isnt( false )
                aBooneUnit:expect( 2+2 ).is( 5 )
            end)
            _:expect( string.find( aTest:report(), "(a)" ) ).isnt( nil )
        end )
    end )
    
end


function isolate()
    CodeaUnit.detailed = true
    aBooneUnit.silent = nil
end
    
-- test output and report functions
-- test "test within test" error
