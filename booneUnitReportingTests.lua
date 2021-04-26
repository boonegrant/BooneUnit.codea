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

function testBooneUnitTally()
    -- local _ = BooneUnit("Testor")
    CodeaUnit.detailed = false
    local aBooneUnit = BooneUnit("Dweezil")
    aBooneUnit.silent = false
    
    local doSomeTests = function() --run some tests
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
        end)
        _:test( "aBooneUnit:tally().total is zero if no tests have"..
                " been run, and test categories are nil when "..
                "corresponding sum is zero", function()
            -- No tests run
            aBooneUnit:reset() 
            _:expect( aBooneUnit:tally().total  ).is( 0 )
            _:expect( aBooneUnit:tally().pass   ).is( nil )
            _:expect( aBooneUnit:tally().fail   ).is( nil )
            _:expect( aBooneUnit:tally().ignore ).is( nil )
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
            _:expect( theFullTally.pass    ).is( 4 )
            _:expect( theFullTally.empty   ).is( 2 )
            _:expect( theFullTally.ignore  ).is( 1 )
            _:expect( theFullTally.fail    ).is( 2 )
            _:expect( theFullTally.pending ).is( nil )
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

function testBooneUnitSummary()
    CodeaUnit.detailed = true
    local aBooneUnit = BooneUnit("Dweezil")
    aBooneUnit.silent = true

    local doSomeTests = function() --run some tests
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
    
    _:describe( "BooneUnit:summary() returns a string reporting number "..
                "and outcomes of tests run", function()
        _:test( "BooneUnit:summary() returns a string", function()
            _:expect( type( aBooneUnit:summary() ) ).is( "string" )
        end )
        _:test( "BooneUnit:summary() string contains total number of "..
                "tests recorded", function()
            print( aBooneUnit:summary() )
            _:expect( string.find( aBooneUnit:summary(), 
                                   " "..string.format( "%i", (aBooneUnit:tally().total) ) 
                                  ) ).isnt( nil )
            doSomeTests()
            print( aBooneUnit:summary() )
            _:expect( string.find( aBooneUnit:summary(), 
                                   " "..string.format( "%i", (aBooneUnit:tally().total) ) 
                                  ) ).isnt( nil )
            
        end)
    end)
end

function testBooneUnitStatus()
    CodeaUnit.detailed = true
    local aBooneUnit = BooneUnit("Dweezil")
    aBooneUnit.silent = true
    -- local _ = BooneUnit( "Testor" )
    
    local doTest = function( tester, pass, testDescription )
        tester:describe( string.format( "%i", #tester.features + 1 ), function()
            tester:test( testDescription, function()
                tester:expect( pass ).is( true )
            end)
        end)
    end
    
    local doPassingTest = function( tester )
        doTest( tester, true, "A Passing Test" )
    end
    
    local doFailingTest = function( tester )
        doTest( tester, false, "A Failing Test" )
    end
        
    local doIgnoredTest = function( tester )
        tester:describe( string.format( "%i", #tester.features + 1 ), function()
            tester:ignore( "An Ignored Test", function()end )
        end)
    end
    local doEmptyTest = function( tester )
        tester:describe( string.format( "%i", #tester.features + 1 ), function()
            tester:test( "An Empty Test", function()end )
        end)
    end
    local doPendingTest = function( tester )
        tester:describe( string.format( "%i", #tester.features + 1 ), function()
            tester:test( "A Pending Test", function()
                tester:delay( 1, function()end )
            end)
        end)
    end
    
    _:describe( "BooneUnit:status() returns a string reflecting the most "..
                "pertinent test outcomes, e.g.: '5 tests failed', "..
                "'2 ignored', 'All Passed', etc", function() 
        
        _:test( "BooneUnit:status() returns a string", function()
            _:expect( type( aBooneUnit:status() ) ).is( "string" )
        end)
        
        _:test( "When no tests have run, BooneUnit:status() string "..
                "contains 'no tests'", function()
            aBooneUnit:reset()
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "no tests" ) ).isnt( nil )
        end)
        
        _:test( "When any tests have failed, BooneUnit:status() string "..
                "contains word 'failed'", function() 
            aBooneUnit:reset()
            
            doFailingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
            
            doPassingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
            
            doPassingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
            
            doIgnoredTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
            
            doEmptyTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
            
            aBooneUnit:reset()
            for i = 1, 10 do
                doPassingTest( aBooneUnit )
            end
            doFailingTest( aBooneUnit )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
        end )
        
        _:test( "BooneUnit:status() prioritizes overall status in this order: "..
                "any Failed > any Pending > any Empty > any Ignored > "..
                "any Passed", function()
            aBooneUnit:reset()
            
            doPassingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "passed" ) ).isnt( nil )
            
            doIgnoredTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "ignored" ) ).isnt( nil )
            
            doPassingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "ignored" ) ).isnt( nil )
            
            doEmptyTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "empty" ) ).isnt( nil )
            
            doIgnoredTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "empty" ) ).isnt( nil )
            
            doPendingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "pending" ) ).isnt( nil )
            
            doEmptyTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "pending" ) ).isnt( nil )
            
            doFailingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
            
            doPendingTest( aBooneUnit )
            local statusString = string.lower( aBooneUnit:status() )
            _:expect( string.find( statusString, "failed" ) ).isnt( nil )
        end)
        
        -- _:test("'All'")
        -- _:test("Count")
    end )
    _:describe( "BooneUnit.status() also returns a color "..
                "representing status", function() 
        _:test( "BooneUnit.status() returns a color as 2nd return", function() 
            aBooneUnit:reset()
            local statusString, statusColor = aBooneUnit:status()
            _:expect( type( statusColor ) ).is( type( color(0)) )
        end )
        _:test( "BooneUnit.status() returns a different color when "..
                "passing than when failing", function() 
            aBooneUnit:reset()
            -- test color difference
            local threshold = 255/3
            
            -- get colors
            doPassingTest( aBooneUnit )
            local passingString, passingColor = aBooneUnit:status()
            
            doFailingTest( aBooneUnit )
            local failingString, failingColor = aBooneUnit:status()
            
            -- compare colors
            local isDifferent = ( math.abs( passingColor.r - failingColor.r ) > threshold ) or
                                ( math.abs( passingColor.g - failingColor.g ) > threshold ) or
                                ( math.abs( passingColor.b - failingColor.b ) > threshold )
            _:expect( isDifferent ).is( true )
        end )
    end )
end

function testExecute()
    CodeaUnit.detailed = true
    local aBooneUnit = BooneUnit("Dweezil")
    aBooneUnit.silent = true
    --local _ = BooneUnit( "Testor" )
    
    
end
    
-- test output and report functions
-- test "test within test" error
currentTest = testBooneUnitStatus
parameter.action( "testCurrent()", currentTest )