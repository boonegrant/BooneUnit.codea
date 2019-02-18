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
    
function testBooneUnit()
    CodeaUnit.detailed = false
    booneUnit.silent = true
    -- local theFeature = ""
    local atestDesc = "location: Springfield"
    local atestFunc = function ()
        print( "324 Evergreen Terrace" )
        return "Shelbyville"
    end
    local afeatureDesc = "HomerSimpson"
    local afeatureFunc = function() 
        print("woo-hoo!")
        booneUnit:test( testDesc, testFunc )
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
                                    reset = "function",
                                    ignore = "function",
                                    test = "function",
                                    delay = "function",
                                    before = "function",
                                    after = "function" }
        memberTypeTest( "public methods: booneUnit", booneUnit, publicUnitMethods )
        --tableKeyValueTypeTest
        --tableKeyValueTest
        
        -- Result categories 
        local definedResultTypes = { "pass", "fail", "ignore", "pending", "empty"}
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
                                     continue = "function", 
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
    
function testBooneUnitExpect()
    booneUnit:reset()
    _:describe( "Function booneUnit:expect() takes an argument and returns" ..
                " a set of functions which evaluate that argument.", function()
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
    
    _:describe( "booneUnit:expect( table ).has( value ) returns true when"..
                " the table has that value stored under any key", function()
        local aVar = "bar"
        local emptyTable = {}
        local alphaTable = {"a","b","c"}
        local sameTable = alphaTable
        local aFunction = function(num) return num * num end
        local otherFunc = math.sin
        local aVector = vec2(5,2)
        local aColor = color(43)
        local aTable = { true, false, "foo", aVar, "24", 24, 
                         emptyTable, alphaTable, aFunction, otherFunc,
                         aFunction(otherFunc(16)), 0.3296, math.pi, 
                         aVector, aColor }
        local bTable = { true, false, "foo", "bar", "24", 24, 
                         emptyTable, sameTable, aFunction, math.sin,
                         aFunction(math.sin(16)), 00.329600, math.pi, 
                         vec2(5,2), aColor }
        for i, v in ipairs( bTable ) do
            local testDesc = string.format('booneUnit:expect(table).has(%s)', v )
            _:test( testDesc, function()
                booneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "table has value %s:%s ", type(v), v )
                booneUnit:test( dweezilTestDesc, function() 
                    expectation = booneUnit:expect( aTable )
                end )
                _:expect( expectation.has( v ) ).is( true ) -- does this need to be moved out like this?
            end )
        end
    end )
    
    _:describe( "booneUnit:expect( table ).has( value ) returns false when"..
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
            local testDesc = string.format('booneUnit:expect(table).has(%s)', v )
            _:test( testDesc, function()
                booneUnit:reset()
                local expectation 
                local dweezilTestDesc = string.format( "table has value %s:%s ", type(v), v )
                booneUnit:test( dweezilTestDesc, function() 
                    expectation = booneUnit:expect( aTable )
                end )
                _:expect( expectation.has( v ) ).is( false ) 
            end )
        end
    end )
    
    _:describe( 'booneUnit:expect( <function> ).throws( <something> ) executes the function'..
        ' given to expect() and returns true if it throws an error containing <error>'..
        ' ( usually a string )', function()
        -- produces failed result if expect( arg ); arg is not a function.
        _:test( 'expect( func ).throws() returns false if no function is evaluated', function()
            local expectation 
            local throwTest = booneUnit:test( "a nil expectation", function()
                expectation = booneUnit:expect( nil )
            end )
            _:expect( expectation.throws() ).is( false )
            _:expect( throwTest:passed() ).is( false )
        end )
        
        -- produces failed result if function does not throw error
        _:test( 'expect().throws() returns false if no error is thrown', function()
            local expectation 
            booneUnit:test( "an empty function", function()
                expectation = booneUnit:expect( function()end )
            end )
            _:expect( expectation.throws("") ).is( false )
        end )
    end )
    
    -- produces passing result if throw() has no argument and any error is thrown
    _:describe( 'booneUnit:expect( <function> ).throws( nil ) returns true for any error\n', function()
        local thingsToThrow = { "", "a foo test", "a bar exam", 7, math.pi, {"table"}, function() end }        
            for i, v in ipairs( thingsToThrow ) do
            _:test( string.format( 'expect( <function> ).throws() \ncatches: %s', v ), function()
                local expectation 
                booneUnit:test( string.format("throw and catch: %s", v ), function()
                    expectation = booneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws() ).is( true )
            end )
        end
        _:test( 'expect( <function> ).throws( nil ) \ncatches: nil', function()
            local expectation 
            booneUnit:test( 'throw and catch: nil', function()
                expectation = booneUnit:expect( function()
                    error( nil )
                end )
            end )
            _:expect( expectation.throws( ) ).is( true )
        end )
    end )
        
    _:describe( 'booneUnit:expect(<func>).throws( "" ) returns true if any error string is thrown', function()
        local stringsToThrow = { "", "a foo test", "a bar exam", "error", "booneUniterrorMsgsexpectWithoutTest" }        
        for i, v in ipairs( stringsToThrow ) do
            _:test( string.format( 'expect( <function throws "%s"> ).throws("") \ncatches: "%s"', v, v ), function()
                local expectation 
                booneUnit:test( string.format('throw and catch: "%s"', v ), function()
                    expectation = booneUnit:expect( function()
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
                booneUnit:test( string.format('throw and catch: "%s"', v ), function()
                    expectation = booneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws( "" ) ).is( false )
            end )
        end
        _:test( 'expect( <function throws nil> ).throws("") \ncatches: nil', function()
            local expectation 
            booneUnit:test( 'throw and catch: nil', function()
                expectation = booneUnit:expect( function()
                    error( nil )
                end )
            end )
            _:expect( expectation.throws( "" ) ).is( false )
        end )
    end )
    
    _:describe( 'booneUnit:expect(<func>).throws( <string> ) returns true'..
        ' only if <string> is found in the error', function()
        local barStrings = { "bar", "Barbara", "foobar" }
        for i, v in ipairs( barStrings ) do
            _:test( string.format( 'expect( <function throws "%s"> ).throws("bar") \ncatches: "%s"', v, v ), function()
                local expectation 
                booneUnit:test( 'catch: "bar"', function()
                    expectation = booneUnit:expect( function()
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
                booneUnit:test( 'catch: "bar"', function()
                    expectation = booneUnit:expect( function()
                        error( v )
                    end )
                end )
                _:expect( expectation.throws( "bar" ) ).is( false )
            end )
        end
        
    end )
end

function estBooneUnitIgnore()    
    -- Testing booneUnit.ignore()
    _:describe( "booneUnit.ignore() stores a result but does not run a test", function()
        _:test( "booneUnit.ignore is a function", function()        
            _:expect( type( booneUnit.ignore ) ).is( "function" )
        end )
        -- test() returns a table
        _:test( "booneUnit:ignore( description_string, function ) returns a table", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            _:expect( type( booneUnit:ignore( testDesc, emptyTestFunc ) ) ).is( "table" )
        end )
        -- test() without arguments returns a table
        _:test( "booneUnit:ignore() without arguments returns a table", function()
            _:expect( type( booneUnit:ignore() ) ).is( "table" )
        end )
        -- test() returns a table of class NewTable
        _:test( "booneUnit:ignore() returns a table of class NewTable", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testReturn = booneUnit:ignore( testDesc, emptyTestFunc )
            _:expect( testReturn:is_a( booneUnit.TestInfo ) ).is( true )

        end )
        -- properties of that table
        do
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testTable = booneUnit:ignore( testDesc, emptyTestFunc )
            local testTableProperties = { passed = "function",
                                          report = "function",
                                          results = "table",
                                          description = "string",
                                          registerResult = "function" }
            memberTypeTest("booneUnit:ignore produces object", testTable, testTableProperties )
        end
        _:test( "booneUnit:ignore():passed() returns false", function() 
            booneUnit:reset()
            local testTable = booneUnit:ignore( "one true result", function()
                booneUnit:expect(true).is(true)
            end )
            _:expect( testTable:passed() ).is( false )
        end )
        _:test( 'booneUnit:ignore():status() returns "ignore"', function() 
            booneUnit:reset()
            local testTable = booneUnit:ignore( "one true result", function()
                booneUnit:expect(true).is(true)
            end )
            _:expect( testTable:status() ).is( "ignore" )
        end )
    end )
end

function estBooneUnitTest()
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
        -- test() returns a table of class NewTable
        _:test( "booneUnit:test() returns a table of class NewTable", function()
            local testDesc = "Gingerbread Man"
            local emptyTestFunc = function() end 
            local testReturn = booneUnit:test( testDesc, emptyTestFunc )
            _:expect( testReturn:is_a( booneUnit.TestInfo ) ).is( true )

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
    --test.registerResult() appends table
    _:describe( "test:registerResult() appends a table to test.results", function()
        for i = 0, 5 do
            thisTestDesc = string.format( "call test.registerResult() %d times, results length is %d", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = "Stinky-Cheese Man"
                local anEmptyTestFunc = function() end 
                local testTable = booneUnit:test( aTestDesc, anEmptyTestFunc )
                for j = 1, i do
                    testTable:registerResult( true, "foo", "bar" )
                end
                _:expect( #testTable.results ).is( i )
            end )
        end
    end )
    
    --test.registerResult(result, actual, expected) stores data
    _:describe( "test:registerResult(outcome, expected, actual) stores data in test.results", function()
        for i = 1, 5 do
            thisTestDesc = string.format( 'registerResult(true, "foo", n^2); result[n] matches; n=%d', i )
            _:test( thisTestDesc, function() 
                local aTestDesc = "Stinky-Cheese Man"
                local anEmptyTestFunc = function() end 
                local testTable = booneUnit:test( aTestDesc, anEmptyTestFunc )
                for j = 1, i do
                    testTable:registerResult( true, "foo", j*j )
                    --appends entry to table test.results
                end
                local target = testTable.results[#testTable.results]
                _:expect( target.expected ).is( i*i )
            end )
        end
    end )
    
    -- booneUnit:expect().is() also appends a table to aTest.results
    _:describe( "booneUnit:expect().is() also appends a table to aTest.results", function()
        for i = 0, 5 do
            thisTestDesc = string.format( "call expect().is() %d times, results length is %d", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                local testTable = booneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        booneUnit:expect( j*j ).is( j*j )
                    end
                end )
                _:expect( #testTable.results ).is( i )
            end )
        end
    end )
    
    -- booneUnit:expect().is() stores data in [test].results
    _:describe( "booneUnit:expect().is() stores data in [test].results", function()
        for i = 1, 5 do
            thisTestDesc = string.format( "call expect(n).is(n) %d times, results[%d] contains n", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                local testTable = booneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        booneUnit:expect( j*j ).is( j*j )
                    end
                end )
                target = testTable.results[ #testTable.results ]
                _:expect( target.actual ).is( i*i )
            end )
        end
    end )
    
    -- booneUnit:expect().isnt() stores data in [test].results
    _:describe( "booneUnit:expect().isnt() stores data in [test].results", function()
        for i = 1, 3 do
            thisTestDesc = string.format( "call expect(n).isnt(n) %d times, results[%d] contains n", i, i )
            _:test( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                local testTable = booneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        booneUnit:expect( j*j ).isnt( j*j )
                    end
                end )
                target = testTable.results[ #testTable.results ]
                _:expect( target.outcome ).is( false )
            end )
        end
    end )
    
    -- booneUnit:expect().has() stores data in [test].results
    _:describe( "booneUnit:expect().has() stores data in [test].results", function()
        local vipData = { lat = 834.5677, long = true }
        local aTable = { "foo", "bar", other = "baz", diameter = math.pi, vip = vipData, vec3(24,7,365.25) }
        local bTable = { "foo", "Bar", vipData, math.pi } 
        for i, v in ipairs( bTable ) do
            thisTestDesc = string.format( "call expect( table ).has( value ) %d times," ..
                                          " results[%d] contains value %s", i, i, v )
            _:test( thisTestDesc, function() 
                local aTestDesc = string.format( "%d expectations", i )
                 testTable = booneUnit:test( aTestDesc, function()
                    for j = 1, i do
                        booneUnit:expect( aTable ).has( bTable[ j ] )
                    end
                end )
                target = testTable.results[ #testTable.results ]
                _:expect( target.expected ).is( v )
            end )
        end
    end )

    -- booneUnit:test():passed() 
    --      returns true if all results are true and there is at least one result. 
    _:describe( "booneUnit:test():passed()\nReturns true if there is at least one result,"..
                " and all results are true", function()
        _:test( "passed() returns false if there were no results", function() 
            booneUnit:reset()
            local testTable = booneUnit:test( "an empty test", function()end )
            _:expect( testTable:passed() ).is( false )
        end )
        _:test( "passed() returns true if there is one true result", function()
            local testTable = booneUnit:test( "one true result", function()
                booneUnit:expect(true).is(true)
            end )
            _:expect( testTable:passed() ).is( true )
        end)
        _:test( "passed() returns true if there are two true results", function()
            local testTable = booneUnit:test( "two true results", function()
                booneUnit:expect(true).is(true)
                booneUnit:expect(false).is(false)
            end )
            _:expect( testTable:passed() ).is( true )
        end)
        
        _:test( "passed() returns true if there are ten true results", function()
            local testTable = booneUnit:test( "ten true results", function()
                for i = 1, 5 do
                    booneUnit:expect(true).is(true)
                    booneUnit:expect(false).is(false)
                end
            end )
            _:expect( testTable:passed() ).is( true )
        end)
        
        _:test( "passed() returns false if there is one false result", function()
            local testTable = booneUnit:test( "one false result", function()
                booneUnit:expect(true).is(false)
            end )
            _:expect( testTable:passed() ).is( false )
        end)
        
        _:test( "passed() returns false if there are ten true results and one false one", function()
            local testTable = booneUnit:test( "ten true results, one false", function()
                for i = 1, 5 do
                    booneUnit:expect(true).is(true)
                    booneUnit:expect(false).is(false)
                end
                booneUnit:expect(false).is(true)
            end )
            _:expect( testTable:passed() ).is( false )
        end)
        
    end )
    
    -- booneUnit:test():status() 
    --      Returns a string describing the aggregate result status
    --      ( Empty | Ignored ) > Failed > Passed
    _:describe( 'booneUnit:test():status()\nReturns a string describing the aggregate result status', function()
        _:test( 'status() returns "empty" if there were no results', function() 
            booneUnit:reset()
            local testTable = booneUnit:test( "an empty test", function()end )
            _:expect( testTable:status() ).is( "empty" )
        end )
        _:test( "status() returns 'pass' if there is one true result", function()
            local testTable = booneUnit:test( "one true result", function()
                booneUnit:expect(true).is(true)
            end )
            _:expect( testTable:status() ).is( "pass" )
        end)
        _:test( "status() returns 'pass' if there are two true results", function()
            local testTable = booneUnit:test( "two true results", function()
                booneUnit:expect(true).is(true)
                booneUnit:expect(false).is(false)
            end )
            _:expect( testTable:status() ).is( "pass" )
        end)
        
        _:test( "status() returns 'pass' if there are ten true results", function()
            local testTable = booneUnit:test( "ten true results", function()
                for i = 1, 5 do
                    booneUnit:expect(true).is(true)
                    booneUnit:expect(false).is(false)
                end
            end )
            _:expect( testTable:status() ).is( "pass" )
        end)
        
        _:test( "status() returns 'fail' if there is one false result", function()
            local testTable = booneUnit:test( "one false result", function()
                booneUnit:expect(true).is(false)
            end )
            _:expect( testTable:status() ).is( "fail" )
        end)
        
        _:test( "status() returns 'fail' if there are ten true results and one false one", function()
            local testTable = booneUnit:test( "ten true results, one false", function()
                for i = 1, 5 do
                    booneUnit:expect(true).is(true)
                    booneUnit:expect(false).is(false)
                end
                booneUnit:expect(false).is(true)
            end )
            _:expect( testTable:status() ).is( "fail" )
        end)

    end )
end

function bestBooneUnitDelay()
    CodeaUnit.detailed = false
    booneUnit.silent = true
    _:describe( 'booneUnit:delay() evaluates the conclusion to a test'..
        ' after a certain amount of time has passed', function()
        booneUnit:reset()
        _:test( "booneUnit:delay() is a function", function()
            _:expect( type( booneUnit.delay ) ).is( "function" )
        end )
        _:test( "booneUnit:continue() is a function", function()
            _:expect( type( booneUnit.continue ) ).is( "function" )
        end )
        _:test( "booneUnit:delay() throws error if not inside a test", function()
            _:expect( function() booneUnit:delay() end ).throws( booneUnit.errorMsgs.delayWithoutTest )
        end )
        _:test( "booneUnit:delay() sets test status to pending", function()
            local doneDelayStuff = false
            local testTable = booneUnit:test( "do a delay", function()
                booneUnit:delay( 0.01, function() 
                    doneDelayStuff = true
                    _:expect( booneUnit.currentTest:status() ).is( "pending" )
                end )
            end )
        end )
        _:test( "booneUnit:continue() removes pending status ", function()
            local doneDelayStuff = false
            local testTable = booneUnit:test( "do a delay", function()
                booneUnit:delay( 0.001, function() 
                    doneDelayStuff = true
                end )
            end )
            tween.delay( 0.2, function()
                _:expect( testTable:status() ).isnt( "pending" )
            end )
        end )
        ---[[
        _:test( "booneUnit:continue() runs the function passed in booneUnit.delay", function()
            local doneDelayStuff = false
            booneUnit:test( "do a delay", function()
                print( "getting ready" )
                booneUnit:delay( 0.001, function() 
                    doneDelayStuff = true
                end )
                print( "did it work?" )
            end )
            tween.delay( 0.5, function() 
                _:expect( doneDelayStuff ).is( true )
            end )
        end )
        _:test( "booneUnit:expect() statements inside booneUnit:delay()"..
            " will register results in appropriate test", function()
            local doneDelayStuff = false
            local test1 = booneUnit:test( "do a delay", function()
                booneUnit:delay( 0.8, function()
                    print("ok, back to work")
                    local thing = 5
                    booneUnit:expect( thing ).is(5)
                    doneDelayStuff = true
                end )
                print( "that's it for now" )
            end )
            local test2 = booneUnit:test( "empty test", function()end )
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


function testMoonUnitFeature() 
    -- Feature Creation --
    CodeaUnit.detailed = true
    booneUnit.silent = false
    booneUnit:reset()
    local atestDesc = "location: Springfield"
    local atestFunc = function ()
        print( "324 Evergreen Terrace" )
        return "Shelbyville"
    end
    local aFeatureDesc = "HomerSimpson"
    local aFeatureFunc = function() 
        print("woo-hoo!")
        booneUnit:test( testDesc, testFunc )
        return( 42 )
    end        
    _:describe( "booneUnit:describe() creates FeatureInfo table", function ()
        -- features is empty
        _:test( "after reset, booneUnit.features is empty", function ()
            booneUnit:reset()
            local f = booneUnit.features
            _:expect( f[1] ).is( nil )
            _:expect( #f ).is( 0 )
        end )
        
        _:test( "booneUnit.currentFeature is nil", function ()
            booneUnit:reset()
            _:expect( booneUnit.currentFeature ).is( nil )
        end )
        
        --call :describe()
        _:test( "call describe(), returns table", function ()
            _:expect( type( booneUnit:describe( aFeatureDesc, aFeatureFunc ) ) ).is( "table" )
        end )
        
        -- features not empty
        _:test( "The table returned by describe() is stored in booneUnit.features ", function ()
            booneUnit:reset()
            local myFeatureData = booneUnit:describe( "Empty Feature", function() end )
            _:expect( #booneUnit.features ).is( 1 )
            _:expect( booneUnit.features[1] ).isnt( nil )
            _:expect( booneUnit.features[1] ).is( myFeatureData )
        end )
        
        -- features not empty
        _:test( "The table returned by describe() is stored in booneUnit.features ", function ()
            booneUnit:reset()
            local someFeatureData = booneUnit:describe( aFeatureDesc, aFeatureFunc )
            local anotherFeatureData = booneUnit:describe( aFeatureDesc, aFeatureFunc )
            _:expect( someFeatureData ).isnt( anotherFeatureData )
            _:expect( #booneUnit.features ).is( 2 )
            _:expect( booneUnit.features[1] ).is( someFeatureData )
            _:expect( booneUnit.features[2] ).is( anotherFeatureData )
        end )
        
        _:test( "booneUnit.currentFeature is nil again", function ()
            _:expect( booneUnit.currentFeature ).is( nil )
        end )
    end )
    -- Feature Properties --
    _:describe( '"booneUnit:describe()" returns a FeatureInfo table, and stores that table', function()
        -- feature members 
        booneUnit:reset()
        local someFeatureData = booneUnit:describe( aFeatureDesc, aFeatureFunc )
        local featureMembers = { description = "string", 
                                 tests = "table", 
                                 intro = "function",
                                 tally = "function",
                                 report = "function",
                                 before = "function",
                                 after = "function" }
        memberTypeTest( "someFeatureData", someFeatureData, featureMembers )
        
        local featureValues = { description = aFeatureDesc, 
                                intro = booneUnit.FeatureInfo.intro, 
                                tally = booneUnit.FeatureInfo.tally, 
                                report = booneUnit.FeatureInfo.report, 
                                before = booneUnit.FeatureInfo.before, 
                                after = booneUnit.FeatureInfo.after }
        
        memberValueTest( "someFeatureData", someFeatureData, featureValues )
        
    end )
    ---[[
    _:describe( '"FeatureInfo:tally()" returns a table summarizing the outcomes of the tests in the feature', function()
        _:test( "FeatureInfo:tally() returns a table", function() 
            booneUnit:reset()
            local thisFeature = booneUnit:describe( "An Example for Tallying", function() 
                booneUnit:test()
            end )
            _:expect( type( thisFeature:tally() ) ).is( "table" )
        end )
        _:test( "FeatureInfo:tally() table has key indicating total number of tests ", function() 
            booneUnit:reset()
            local thisFeature = booneUnit:describe( "An Example for Tallying", function() 
                booneUnit:test()
            end )
            _:expect( thisFeature:tally().total ).isnt( nil )
        end )
        _:test( "FeatureInfo:tally() table has key holding sum of each category of test status ", function() 
            booneUnit:reset()
            local thisFeature = booneUnit:describe( "An Example for Tallying", function() 
                booneUnit:test( "#1 Empty test" )
                booneUnit:test( "#2 Empty test" )
                booneUnit:test( "#3 Empty test" )
                booneUnit:test( "#1 Passing test", function()
                    booneUnit:expect( 1 + 1 ).is( 2 )
                end )
                booneUnit:test( "#2 Passing test", function()
                    booneUnit:expect( 2 + 2 ).is( 4 )
                end )
                booneUnit:test( "#1 Failing test", function()
                    booneUnit:expect( true ).is( false )
                end )
                booneUnit:ignore( "#1 Ignored test", function()
                    booneUnit:expect( 2 + 2 ).is( 4 )
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
    --]]
end

-- test output and report functions
