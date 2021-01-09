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

function tryThis() 
    booneUnit:test( "An outside test", function() 
        booneUnit:test( "An inside test" )
    end )
end

function bestBasics()
    local _ = booneUnit
    _.detailed = true

    _:describe("Unit Tester Basic Functionality", function()

        _:before(function()
            -- Some setup
        end)

        _:after(function()
            -- Some teardown
        end)
        
        _:test("Equality test", function()
            _:expect("Foo").is("Foo")
        end)

        _:test("Negation test", function()
            _:expect("Bar").isnt("Foo")
        end)

        _:test("Containment test", function()
            local aTable = { foo = "Bar", bopper = "Big", 42}
            _:expect(aTable).has("Bar")
            _:expect(aTable).has(42)
            _:expect(aTable).has("Baz")
        end)

        _:test("Thrown test", function()
            _:expect(function()
                print( "I don't feel so good…" )
                error('Cookies Tossed!')
            end).throws("Cookies")
        end)

        _:ignore("Ignored test", function()
            _:expect("Foo").is("Foo")
        end)

        _:test("Failing test", function()
            _:expect("Foo").is("Bar")
        end)

        _:test("Test with Great Expectations", function()
            local someWord = "Foo"
            local someNumber = (2+2)
            _:expect(someWord).is("Foo")
            _:expect(someWord).is("foo")
            someWord = "Bar"
            _:expect(someWord).is("Bar")
            _:expect(someNumber).is(4)
        end)
        
    end)
end

parameter.action( "Basic Tests", bestBasics )

