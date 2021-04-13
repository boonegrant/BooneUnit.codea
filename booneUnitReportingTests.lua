function testTestReport()
    CodeaUnit.detailed = true
    local aBooneUnit = BooneUnit("Dweezil")
    aBooneUnit.silent = nil
    
    _:describe( 'TestInfo:report()\nReturns a string describing the individual results of that test',
                function()
        aBooneUnit:reset()
        _:test( '"aBooneUnit:test():report()" returns a string', function() 
            _:expect( type( aBooneUnit:test():report() ) ).is( "string" )
        end )
        _:test( 'the "TestInfo:report()" string contains the test description string', function()
            local testDescription = "Blah Blah Blah and so on" 
            local testReportString = aBooneUnit:test( testDescription ):report()
            _:expect( string.find( testReportString, testDescription, 1, true ) ).isnt( nil )
        end )
        _:test( 'the "TestInfo:report()" string contains the test status', function()
            local testDescription = "Blah Blah Blah and so on" 
            local aTest = aBooneUnit:test( testDescription, function()
                aBooneUnit:expect( true ).isnt( false )
            end)
            _:expect( string.find( aTest:report(), aTest:status(), 1, true ) ).isnt( nil )
        end )
        _:ignore( 'the "TestInfo:report()" string contains an entry for each '..
                '":expect()" statement in the test', function()
            local testDescription = "Double Expectation" 
            local aTest = aBooneUnit:test( testDescription, function()
                aBooneUnit:expect( true ).isnt( false )
                aBooneUnit:expect( 2+2 ).is( 5 )
            end)
            _:expect( string.find( aTest:report(), "(a)", 1, true ) ).isnt( nil )
        end )
    end )
    
end


function testCurrent()
    -- local _ = BooneUnit("Testor")
    CodeaUnit.detailed = true
    local aBooneUnit = BooneUnit("Dweezil")
    aBooneUnit.silent = true
    local doSomeTests = function()
        aBooneUnit:describe( "The First Feature", function()
            aBooneUnit:test( "1st test: passing 1", function()
                aBooneUnit:expect( 1+1 ).is( 2 )
            end)
            aBooneUnit:test( "2nd test: passing 2", function()
                aBooneUnit:expect( 2+2 ).is( 4 )
            end)
            aBooneUnit:test( "3rd test: empty 1" )
        end)
        aBooneUnit:describe( "The Second Feature", function()
            aBooneUnit:test( "4th test: passing 3", function()
                aBooneUnit:expect( 4+4 ).is( 8 )
            end)
            aBooneUnit:test( "5 test: failing 1", function()
                aBooneUnit:expect( 2+2 ).is( 5 )
            end)
            aBooneUnit:test( "6th test: empty 2" )
            aBooneUnit:test( "7th test: passing 4", function()
                aBooneUnit:expect( 1==1 ).is( true )
            end)
        end)
        -- third Feature - undeclared
        aBooneUnit:ignore( "8th test: ignored 1", function()
            aBooneUnit:expect( "something" ).is( "nothing" )
        end)
        aBooneUnit:test( "9th test: failing 2", function() 
            aBooneUnit:expect( true ).isnt( true )
        end)
        
    end
    _:describe( "BooneUnit:tally() returns a table categorizing "..
                "the results of all tests run", function()
        _:test( "aBooneUnit:tally() returns a table", function()
            -- No tests run
            aBooneUnit:reset() 
            _:expect( type( aBooneUnit:tally() ) ).is( "table" )
            _:expect( aBooneUnit:tally().total ).is( 0 )
        end)
        _:test( "aBooneUnit:tally() table records total # of tests", 
                function()
            -- do some tests
            aBooneUnit:reset()
            doSomeTests()
            _:expect( aBooneUnit:tally().total ).is( 9 )
        end)
        _:test( "aBooneUnit:tally() table records count of each "..
                "result category", function()
            -- do some tests
            aBooneUnit:reset()
            doSomeTests()
            local theFullTally = aBooneUnit:tally()
            _:expect( theFullTally.pass   ).is( 4 )
            _:expect( theFullTally.empty  ).is( 2 )
            _:expect( theFullTally.ignore ).is( 1 )
            _:expect( theFullTally.fail   ).is( 2 )
        end)
        _:test( "aBooneUnit:tally() table records total "..
                "# of features", function()
            -- do some tests
            aBooneUnit:reset()
            doSomeTests()
            _:expect( aBooneUnit:tally().features ).is( 3 )
        end)
        
    end)
end
    
-- test output and report functions
-- test "test within test" error
parameter.action( "testCurrent()", testCurrent )