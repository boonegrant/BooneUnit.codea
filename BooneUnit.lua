booneUnit = {resultTypes={"pass", "ignore", "pending", "empty test", "fail"},
             errorMsgs={ noCurrentTest = ":expect() statements should be placed inside a :test declaration" }
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
    return thisFeature
end

function booneUnit:test( testDescription, scenario )
    print( string.format( "booneUnit.test( %s, %s )", testDescription, scenario ) )
    local thisFeature = self.currentFeature or self:orphanage()
    local thisTest = booneUnit.newTest( thisFeature, testDescription, scenario )
    table.insert( thisFeature.tests, thisTest )   
    thisFeature:before()
    self.currentTest = thisTest
    thisTest:run()
    self.currentTest = nil
    thisFeature:after()
    return thisTest
end

function booneUnit:ignore( description, scenario ) 
end

function booneUnit:orphanage()      -- create a home for tests outside of a :define() call
    print( "Oh you poor lost test!" )
    if ( self.aHomeForOrphanTests == nil ) then
        self.aHomeForOrphanTests = self.newFeature( "Undefined", function() end )
        table.insert( self.features, self.aHomeForOrphanTests )   
        print( "I have made a home for you" )
    end
    print( string.format( "This is your home now: %s", self.aHomeForOrphanTests ) )
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
    print( "booneUnit now expecting…" )
    local thisTest = self.currentTest
    if thisTest == nil then
        -- error( self.errorMsgs[ noCurrentTest ] )
        return nil
    end
    
    local notify = function( result, expectation )
        if result then
            thisTest:registerResult( "pass", expectation )
        else
            thisTest:registerResult( "fail", expectation )
        end
    end
    
    local is = function(expected)
        -- self.expected = expected
        notify(conditional == expected, expected)
    end

    local isnt = function(expected)
        -- self.expected = expected
        notify( conditional ~= expected, string.format("not %s", expected) )
    end

    local has = function(expected)
        -- self.expected = expected
        local found = false
        for k,v in pairs(conditional) do
            if v == expected then
                found = true
            end
        end
        notify(found, expected)
    end

    local throws = function(expected)
        -- self.expected = expected
        local status, error = pcall(conditional)
        if not error then
            conditional = "nothing thrown"
            notify(false)
        else
            notify(string.find(error, expected, 1, true), error)
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
    print( self:intro() )
    self.tests = {}
    self.featureTests()
    print( self:results() )
end
function booneUnit.newFeature:intro()
    return string.format( "Feature: %s \ntests:", self.description )
end
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
        print(string.format("%d: %s -- %s \n--FAIL", 69, self.description, err))
        self:registerResult( "fail", err )
        --store result
    end
end
function booneUnit.newTest:registerResult( outcome, expected )
    print( string.format( "Result: %s -- %s", outcome, expected ) )
end
function booneUnit.newTest:report()
end
function booneUnit.newTest:passed()
end

