booneUnit = {}
booneUnit._tallyCategoryOrder = { "pass", "empty", "ignore", "pending", "fail" }
booneUnit._tallyCategoryNames = { 
    pass    = "Passed", 
    ignore  = "Ignored", 
    empty   = "Empty",
    pending = "Pending", 
    fail    = "Failed"
    }
booneUnit.errorMsgs = { 
    testInsideTest = '"booneUnit:test()" declaration cannot be made inside another "test()" declaration',
    expectWithoutTest = '"booneUnit:expect()" statements should be placed inside a "test()" declaration',
    delayWithoutTest =  '"booneUnit:delay()" statements should be placed inside a "test()" declaration',
    throwsArgIsNotFunction = '"booneUnit:expect( arg ).throws()" -- arg must be a function' 
    }
function booneUnit:reset ()
    self.features = {}
    self.currentFeature = nil
    self.currentTest = nil
    self.aHomeForOrphanTests = nil
end
booneUnit:reset()

function booneUnit:describe( featureDescription, featureTests )
    -- Create feature info table
    local thisFeature = self.FeatureInfo( featureDescription )
    table.insert( self.features, thisFeature )   
    -- Announce feature
    if not self.silent then
        print( string.format( "Dwezil-%s", thisFeature:intro() ) )
    end
    -- Run tests
    self.currentFeature = thisFeature
    local runTests = featureTests or function() end
    runTests()
    self.currentFeature = nil
    -- Announce summary of results
    if not self.silent then
        print( string.format( "Dwezil-%s", thisFeature:report() ) )
    end
    return thisFeature
end

function booneUnit:before(setup)
    if self.currentFeature then self.currentFeature.before = setup end
    -- error message: before and after must be inside a describe: declaration
end
function booneUnit:after(teardown)
    if self.currentFeature then self.currentFeature.after = teardown end
end

function booneUnit:ignore( testDescription, scenario )
    local thisFeature = self.currentFeature or self:orphanage()
    local thisTest = thisFeature:makeTest( testDescription, scenario )
    thisTest:registerResult("ignore", "", "") 
    if not self.silent then
        print( string.format( '#%d Dwezil:ignore()\n%s', #thisFeature.tests ,thisTest:report() ) )
        -- thisTest:report( self.detailed )
    end
    return thisTest
end

function booneUnit:test( testDescription, scenario )
    if self.currentTest then  -- check if there is already an active test statement
        error( self.errorMsgs.testInsideTest, 2 )
    end
    local thisFeature = self.currentFeature or self:orphanage()
    local thisTest = thisFeature:makeTest( testDescription, scenario )
    thisFeature:before()
    self.currentTest = thisTest
    thisTest:run( scenario )
    self.currentTest = nil
    thisFeature:after()
    if not self.silent then
        print( string.format( '#%d Dwezil:test()\n%s', #thisFeature.tests ,thisTest:report() ) )
    end
    return thisTest
end

-- booneUnit:delay() used inside a test statement to delay evaluation of expectations
function booneUnit:delay( numSeconds, scenario )
    local thisTest = self.currentTest
    if thisTest == nil then
        error( self.errorMsgs.delayWithoutTest, 2 )
        return nil
    end
    thisTest:registerResult( "pending" ) -- next add tween id
    local pendingIndex = #thisTest.results
    tween.delay( numSeconds, function ()
        self:continue( thisTest, pendingIndex, scenario )
    end )
    -- return tween, test, callback,what?
end

function booneUnit:continue( thisTest, pendingIndex, scenario )
    self.currentTest = thisTest
    thisTest:run( scenario )
    self.currentTest = nil
    table.remove( thisTest.results, pendingIndex )
end

function booneUnit:expect( conditional ) -- TODO: add name arg
    local thisTest = self.currentTest
    if thisTest == nil then
        error( self.errorMsgs.expectWithoutTest, 2 ) -- 2 is where in stack level is returned for context
        return nil
    end
        
    local is = function(expected)
        -- notify(conditional == expected, expected)
        thisTest:registerResult( conditional == expected, conditional, expected )
        return(conditional == expected)
    end

    local isnt = function(expected)
        -- notify( conditional ~= expected, string.format("not %s", expected) )
        thisTest:registerResult( conditional ~= expected, conditional, string.format("NOT %s", expected) )
        return( conditional ~= expected )
    end

    local has = function(expected)
        local found = false
        local actual
        for k,v in pairs(conditional) do
            -- make sure they are not different userdata types; "==" will throw error
            if type( v ) ~= "userdata" 
                or type( expected ) ~= "userdata" 
                or  getmetatable( v ) == getmetatable( expected )
            then  -- test for equality
                if v == expected then
                    found = true
                    actual = string.format('[ %s ] is %s', k, v )
                end
            end
             
        end
        --notify(found, expected)
        thisTest:registerResult( found, actual, string.format("HAS %s", expected) )
        return found
    end

    local throws = function(expected)
        if type( conditional ) ~= "function" then 
            -- usage check : conditional is not function
            error(string.format( '%s -- is "%s"', 
                booneUnit.errorMsgs.throwsArgIsNotFunction, 
                type( conditional ) ), 2 )
        else 
            -- conditional is a function
            local ok, error = pcall( conditional )
            if ok then 
                -- no error thrown
                thisTest:registerResult( false, 
                                         "No error thrown", 
                                         string.format('THROWN: "%s"', expected) )
                return false
            else 
                -- some error was thrown 
                local foundExpectedError 
                if expected == nil then 
                    -- any error is good enough
                    foundExpectedError = true
                elseif type( expected ) == "string" and type( error ) == "string" then  
                    -- search for expected substring
                    foundExpectedError = ( string.find(error, expected, 1, true) ~= nil )
                else 
                    -- not nil, not a string: test for equality
                    foundExpectedError = ( expected == error ) 
                end
                -- register and return findings
                thisTest:registerResult( foundExpectedError, 
                                         string.format('ERROR- "%s"', error),
                                         string.format('THROWN- "%s"', expected) )
                return foundExpectedError
            end
        end
    end
    
    return {
        is = is,
        isnt = isnt,
        has = has,
        throws = throws
    }
end

function booneUnit:orphanage()  -- create a home for tests not placed inside a :describe() declaration
    -- this is so they can be grouped and tabulated together 
    -- ?Create new Feature for each group of orphan tests i.e. remove .aHomeForOrphanTests ?
    -- print( "Dwezil- Oh you poor lost test!" )
    if ( self.aHomeForOrphanTests == nil ) then  -- or aHomeForOrphanTests ~= self.features[#self.features]
        self.aHomeForOrphanTests = self.FeatureInfo( "No Description" )
        table.insert( self.features, self.aHomeForOrphanTests )   
        -- print( "Dwezil- I have made a home for you" )
    end
    -- print( string.format( "Dwezil- This is your home now: %s", self.aHomeForOrphanTests ) )
    return self.aHomeForOrphanTests
end

-- ------------------ --
-- Feature Info class --
-- ------------------ --
booneUnit.FeatureInfo = class()

function booneUnit.FeatureInfo:init( featureDescription )
    self.description = featureDescription or ""
    self.tests = {}
end

function booneUnit.FeatureInfo:makeTest( testDescription, scenario )
    theTest = booneUnit.TestInfo( self, testDescription, scenario )
    table.insert( self.tests, theTest )
    return theTest
end

function booneUnit.FeatureInfo:intro()
    return string.format( "Feature: %s \n tests:", self.description )
end
-- booneUnit.FeatureInfo:report()
--          Returns a string describing the results of the tests within the feature
function booneUnit.FeatureInfo:report() --change name to summary
    local theTally = self:tally()
    local reportCategories = {}
    local separator = ' ----------'
    -- assemble tally strings in prefered order
    for i, v in ipairs( booneUnit._tallyCategoryOrder ) do
        if theTally[v] then
            local category = string.format( "%3i %s", theTally[v], booneUnit._tallyCategoryNames[v] or v )
            table.insert( reportCategories, category )
        end
    end
    return string.format( "Feature: %s \n%3i Tests \n%s\n%s\n%s", 
                          self.description, 
                          theTally.total,
                          separator,
                          table.concat( reportCategories, "\n" ),
                          separator
                        )
end

-- booneUnit.FeatureInfo:tally()
--          Returns a table summing and totaling the test results in a feature
function booneUnit.FeatureInfo:tally()
    local theTally = { total = #self.tests }
    for i, v in ipairs( self.tests ) do
        local testStatus = v:status()
        if theTally[ testStatus ] then
            theTally[ testStatus ] = theTally[ testStatus ] + 1
        else
            theTally[ testStatus ] = 1
        end
    end
    return theTally
end
function booneUnit.FeatureInfo.before() end -- default empty function
function booneUnit.FeatureInfo.after() end  -- default empty function


-- --------------- --
-- Test Info class --
-- --------------- --
booneUnit.TestInfo = class()
function booneUnit.TestInfo:init( parent, testDescription, scenario )
    self.feature = parent  -- not sure I need this, may be useful for delayed reports
    self.description = tostring(testDescription or "")
    self.results = {}
end

function booneUnit.TestInfo:run( scenario )
    local status, error = pcall( scenario or function() end )
    if error then
        self:registerResult( false, "ERROR", error )
    end
end

function booneUnit.TestInfo:registerResult( outcome, actual, expected )
    table.insert( self.results, { outcome = outcome, actual = actual, expected = expected} )
    return #self.results
end

-- [test]:passed() - returns true if there is at least one result 
--                   recorded and all results are successful or ignored
function booneUnit.TestInfo:passed()
    local testPassed = #self.results > 0  -- at least one result recorded
    for i, v in ipairs( self.results ) do
        if v.outcome ~= true then return false end
    end
    return testPassed
end

function booneUnit.TestInfo:status()
    if #self.results == 0 then -- no results registered
        -- test is empty
        return "empty"
    end
    local isPending = false
    local isPassing = true
    for i, v in ipairs( self.results ) do
        if v.outcome == "ignore" then 
            -- test ignored
            return "ignore"
        elseif not v.outcome then -- nil or false
            -- test failed
            return "fail"
        elseif v.outcome == "pending" then 
            -- a result still pending
            isPending = true
        elseif v.outcome ~= true then -- some other value
            -- a result is not pass, fail, pending, or ignored
            isPassing = false
            isOther = v.outcome
        end
    end
    if isPending then return "pending" end
    if isPassing then return "pass" end
    return isOther
end

function booneUnit.TestInfo:report() --TODO: add 'detailed' parameter
    local bigDivider = '--------'
    local startChunk = '├─○ '
    local midChunk   = '│ │ '
    local endChunk   = '│ ╰>'
    local reportTable = {}
    table.insert( reportTable, string.format( '"%s"\n%s', self.description, bigDivider) )
    for i, v in ipairs( self.results ) do
        table.insert( reportTable, string.format( '%sexpected: %s', startChunk, v.expected ) )
        table.insert( reportTable, string.format( '%sactual:   %s', midChunk, v.actual ) )
        table.insert( reportTable, string.format( '%s(%s)', endChunk, v.outcome ) )
    end
    table.insert( reportTable, string.format( '%s\n[ %s ]', bigDivider, self:status() ) )
    return table.concat( reportTable, '\n' )
end
