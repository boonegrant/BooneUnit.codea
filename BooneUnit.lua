booneUnit = {resultTypes={"pass", "ignore", "pending", "empty", "fail"},
             errorMsgs={ expectWithoutTest = 'booneUnit-"expect()" statements should be placed inside a "test" declaration' }
            }
function booneUnit:reset ()
    self.features = {}
    self.currentFeature = nil
    self.currentTest = nil
    self.aHomeForOrphanTests = nil
end
booneUnit:reset()

function booneUnit:describe( featureDescription, featureTests )
    local thisFeature = self.newFeature( featureDescription, featureTests )
    table.insert( self.features, thisFeature )   
    self.currentFeature = thisFeature
    thisFeature:runTests()
    self.currentFeature = nil
    -- print( thisFeature:report( self.detailed ) )
    return thisFeature
end

function booneUnit:test( testDescription, scenario )
    print( string.format( "Dwezil-booneUnit.test( %s)", testDescription ) )
    local thisFeature = self.currentFeature or self:orphanage()
    local thisTest = booneUnit.newTest( thisFeature, testDescription, scenario )
    table.insert( thisFeature.tests, thisTest )   
    thisFeature:before()
    self.currentTest = thisTest
    thisTest:run()
    self.currentTest = nil
    thisFeature:after()
    -- thisTest:report( self.detailed )
    return thisTest
end

function booneUnit:ignore( testDescription, scenario )
    print( string.format( "Dwezil-booneUnit.ignore( %s)", testDescription ) )
    local thisFeature = self.currentFeature or self:orphanage()
    local thisTest = booneUnit.newTest( thisFeature, testDescription )
    thisTest:registerResult("ignore") 
    table.insert( thisFeature.tests, thisTest )   
    return thisTest
end

function booneUnit:orphanage()      -- create a home for tests outside of a :define() call
    -- print( "Dwezil- Oh you poor lost test!" )
    if ( self.aHomeForOrphanTests == nil ) then
        self.aHomeForOrphanTests = self.newFeature( "Undefined", function() end )
        table.insert( self.features, self.aHomeForOrphanTests )   
        -- print( "Dwezil- I have made a home for you" )
    end
    -- print( string.format( "Dwezil- This is your home now: %s", self.aHomeForOrphanTests ) )
    return self.aHomeForOrphanTests
end

function booneUnit:before(setup)
    if self.currentFeature then self.currentFeature.before = setup end
    -- error message: before and after must be inside a describe: declaration
end
function booneUnit:after(teardown)
    if self.currentFeature then self.currentFeature.after = teardown end
end

function booneUnit:expect( conditional )
    local thisTest = self.currentTest
    if thisTest == nil then
        error( self.errorMsgs.expectWithoutTest )
        return nil
    end
    
    local notify = function( result, expectation )
        if result then
            thisTest:registerResult( true, conditional, expectation )
        else
            thisTest:registerResult( false, conditional, expectation )
        end
    end
    
    local is = function(expected)
        -- self.expected = expected
        notify(conditional == expected, expected)
        return(conditional == expected)
    end

    local isnt = function(expected)
        -- self.expected = expected
        notify( conditional ~= expected, string.format("not %s", expected) )
        return( conditional ~= expected )
    end

    local has = function(expected)
        -- self.expected = expected
        local found = false
        local actual
        for k,v in pairs(conditional) do
            if v == expected then
                found = true
                actual = string.format('target[ %s ] is %s', k, v )
            end
        end
        thisTest:registerResult( found, actual, expected )
        --notify(found, expected)
        return found
    end

    local throws = function(expected)
        -- self.expected = expected
        local status, error = pcall(conditional)
        if not error then
            conditional = "nothing thrown"
            notify(false)
            return false
        else
            notify(string.find(error, expected, 1, true), error)
            return true
        end
    end
    
    return {
        is = is,
        isnt = isnt,
        has = has,
        throws = throws
    }
end


-- Feature class --
booneUnit.newFeature = class()
function booneUnit.newFeature:init( featureDescription , allFeatureTests )
    self.description = featureDescription or ""
    self.tests = {}
    self.featureTests = allFeatureTests or ( function() end )  -- test for value = function?
end
function booneUnit.newFeature:runTests()
    print( string.format( "Dwezil-%s", self:intro() ) )
    self.tests = {}
    self.featureTests()
    print( string.format( "Dwezil-%s", self:results() ) )
end
function booneUnit.newFeature:intro()
    return string.format( "Feature: %s \ntests:", self.description )
end
-- [feature]:results( detailed )
function booneUnit.newFeature:results()
    return string.format( "Feature: %s \nResults go here", self.description )
    -- do some tallying
end
function booneUnit.newFeature.before() end
function booneUnit.newFeature.after() end

-- Test class --
booneUnit.newTest = class()
function booneUnit.newTest:init( parent, testDescription, scenario )
    self.feature = parent
    self.description = testDescription or ""
    self.test = scenario or ( function() end )
    self.results = {}
end
function booneUnit.newTest:run()
    local status, err = pcall(self.test)
    if err then
        --self.failures = self.failures + 1
        self:registerResult( false, err )
        --store result
    end
end

function booneUnit.newTest:registerResult( outcome, actual, expected )
    table.insert( self.results, { outcome = outcome, actual = actual, expected = expected} )
    print( string.format( "  actual: %s \nexpected: %s \nDwezil-Result: %s ", actual, expected, outcome ) )
end

-- [test]:passed() - returns true if there is at least one result 
--                   recorded and all results are successful
function booneUnit.newTest:passed()
    local testPassed = #self.results > 0  -- at least one result recorded
    for i, v in ipairs( self.results ) do
        if v.outcome ~= true then return false end
    end
    return testPassed
end

function booneUnit.newTest:status()
    if #self.results == 0 then
        return "empty"
    end
    local isPending = false
    local isPassing = true
    for i, v in ipairs( self.results ) do
        if v.outcome == "ignore" then 
            return v.outcome
        elseif v.outcome == false then 
            return "fail"
        elseif v.outcome == "pending" then 
            isPending = true
        elseif v.outcome ~= true then
            isPassing = false
            isOther = v.outcome
        end
    end
    if isPending then return "pending" end
    if isPassing then return "pass" end
    return isOther
end

function booneUnit.newTest:report()
end
