booneUnit = {}
booneUnit.resultTypes = { "pass", "ignore", "empty", "pending", "fail" }
booneUnit.errorMsgs = { 
    expectWithoutTest = 'booneUnit - "expect()" statements should be placed inside a "test()" declaration',
    delayWithoutTest =  'booneUnit - "delay()" statements should be placed inside a "test()" declaration',
    throwsArgIsNotFunction = 'booneUnit - ":expect( arg ).throws()" ; arg must be a function'
    --, testInsideTest = 'booneUnit-a "test()" declaration cannot be made inside another "test()" declaration'
    }
function booneUnit:reset ()
    self.features = {}
    self.currentFeature = nil
    self.currentTest = nil
    self.aHomeForOrphanTests = nil
end
booneUnit:reset()

function booneUnit:describe( featureDescription, featureTests )
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
    local thisTest = booneUnit.TestInfo( thisFeature, testDescription )

    table.insert( thisFeature.tests, thisTest )   
    thisTest:registerResult("ignore") 
    if not self.silent then
        print( string.format( "Dwezil:ignore( %s)", testDescription ) )
        -- thisTest:report( self.detailed )
    end
    return thisTest
end

function booneUnit:test( testDescription, scenario )
    local thisFeature = self.currentFeature or self:orphanage()
    local thisTest = booneUnit.TestInfo( thisFeature, testDescription, scenario )

    table.insert( thisFeature.tests, thisTest )   
    thisFeature:before()
    self.currentTest = thisTest
    thisTest:run( scenario )
    self.currentTest = nil
    thisFeature:after()
    if not self.silent then
        print( string.format( "Dwezil:test( %s )\n" ..
            "   [ %s ]", thisTest.description, thisTest:status() ) )
        -- thisTest:report( self.detailed )
    end
    return thisTest
end

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
        error( self.errorMsgs.expectWithoutTest, 2 )
        return nil
    end
        
    local is = function(expected)
        -- notify(conditional == expected, expected)
        thisTest:registerResult( conditional == expected, conditional, expected )
        return(conditional == expected)
    end

    local isnt = function(expected)
        -- notify( conditional ~= expected, string.format("not %s", expected) )
        thisTest:registerResult( conditional ~= expected, conditional, string.format("not %s", expected) )
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
                    actual = string.format('target[ %s ] is %s', k, v )
                end
            end
             
        end
        --notify(found, expected)
        thisTest:registerResult( found, actual, expected )
        return found
    end

    local throws = function(expected)
        if type( conditional ) ~= "function" then 
            -- usage check : conditional is not function
            thisTest:registerResult( -- TODO: should throw error
                false, 
                string.format( 'arg is "%s", not "function"', type( conditional )),
                booneUnit.errorMsgs.throwsArgIsNotFunction 
            )
            return false
        else 
            -- conditional is a function
            local ok, error = pcall( conditional )
            if ok then 
                -- no error thrown
                thisTest:registerResult( false, "Nothing thrown", expected )
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
                thisTest:registerResult( foundExpectedError, error, expected )
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
    -- print( "Dwezil- Oh you poor lost test!" )
    if ( self.aHomeForOrphanTests == nil ) then  -- or aHomeForOrphanTests ~= self.features[#self.features]
        self.aHomeForOrphanTests = self.FeatureInfo( "No Description" )
        table.insert( self.features, self.aHomeForOrphanTests )   
        -- print( "Dwezil- I have made a home for you" )
    end
    -- print( string.format( "Dwezil- This is your home now: %s", self.aHomeForOrphanTests ) )
    return self.aHomeForOrphanTests
end


-- Feature class --
booneUnit.FeatureInfo = class()
function booneUnit.FeatureInfo:init( featureDescription, allFeatureTests )
    self.description = featureDescription or ""
    self.tests = {}
end
function booneUnit.FeatureInfo:intro()
    return string.format( "Feature: %s \ntests:", self.description )
end
-- [feature]:report( detailed )
function booneUnit.FeatureInfo:report()
    local theTally = self:tally()
    local theReport = string.format( "Feature: %s \n%d tests", self.description, theTally.total )
    for i, v in ipairs( booneUnit.resultTypes ) do
        
    end
    return theReport
    -- do some tallying
end
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

-- Test class --
booneUnit.TestInfo = class()
function booneUnit.TestInfo:init( parent, testDescription, scenario )
    self.feature = parent  -- not sure I need this,
    self.description = testDescription or ""
    self.test = scenario or ( function() end )
    self.results = {}
end
function booneUnit.TestInfo:run( scenario )
    local status, error = pcall( scenario or function() end )
    if error then
        self:registerResult( false, "error", error )
    end
end

function booneUnit.TestInfo:registerResult( outcome, actual, expected )
    table.insert( self.results, { outcome = outcome, actual = actual, expected = expected} )
    print( string.format( "  actual: %s \nexpected: %s \nDwezil-Result: %s ", actual, expected, outcome ) )
    return #self.results
end

-- [test]:passed() - returns true if there is at least one result 
--                   recorded and all results are successful
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

function booneUnit.TestInfo:report( detailed )

end
