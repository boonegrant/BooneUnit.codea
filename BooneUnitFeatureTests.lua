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
        
        _:test( "aBooneUnit._currentFeature is nil", function ()
            aBooneUnit:reset()
            _:expect( aBooneUnit._currentFeature ).is( nil )
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
        
        _:test( "aBooneUnit._currentFeature is nil again", function ()
            _:expect( aBooneUnit._currentFeature ).is( nil )
        end )
    end )
    -- Feature Properties --
    _:describe( '"aBooneUnit:describe()" returns a FeatureInfo table, and stores that table', function()
        -- feature members 
        aBooneUnit:reset()
        local someFeatureData = aBooneUnit:describe( aFeatureDesc, aFeatureFunc )
        
        local featureMembers = { description = "string", 
                                 tests = "table", 
                                 registerTest = "function",
                                 intro = "function",
                                 tally = "function",
                                 report = "function",
                                 before = "function",
                                 after = "function" }
        memberTypeTest( "someFeatureData", someFeatureData, featureMembers )
        
        local featureValues = { description = aFeatureDesc, 
                                registerTest = aBooneUnit.FeatureIregisterTestTest,
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
    
    
    _:describe( '"FeatureInfo:registerTest()" returns a TestInfo object', function()
        aBooneUnit:reset()
        --[[
        aBooneUnit:reset()
        local thisFeatureInfo, testOneInfo, testTwoInfo, testThreeInfo
        thisFeatureInfo = aBooneUnit:describe( "A Feature Description String")
        testOneInfo = thisFeatureInfo:registerTest( thisFeatureInfo, "empty" )
        testTwoInfo = thisFeatureInfo:registerTest( thisFeatureInfo, "passable", function()
            aBooneUnit:expect( "foo" ).is( "foo" )
        end )
        
        testThreeInfo = thisFeatureInfo:registerTest( thisFeatureInfo, "impassable", function()
            aBooneUnit:expect( "foo" ).is( "bar" )
        end )
        --]]
        _:test( 'returns table', function()
            aBooneUnit:reset()
            local thisFeatureInfo, testOneInfo, testTwoInfo, testThreeInfo
            thisFeatureInfo = aBooneUnit:describe( "A Feature Description String")
            testOneInfo = thisFeatureInfo:registerTest( thisFeatureInfo, "empty" )
            _:expect( type(testOneInfo)== 'table' ).is( true )
        end )
        _:test( 'returns TestInfo object', function()
            aBooneUnit:reset()
            local thisFeatureInfo, testOneInfo, testTwoInfo, testThreeInfo
            thisFeatureInfo = aBooneUnit:describe( "A Feature Description String")
            testOneInfo = thisFeatureInfo:registerTest( thisFeatureInfo, "empty" )
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

