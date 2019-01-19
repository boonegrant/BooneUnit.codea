booneUnit = {}
function booneUnit:reset ()
    self.features = {}
    self.currentFeature = nil
    self.currentTest = nil
    self.aHomeForOrphanTests = nil
    self.bork = 17
    self.beck = 0.852
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
    thisFeature = self.currentFeature or self:orphanage()
    thisTest = booneUnit.newTest( thisFeature, testDescription, scenario )
    table.insert( thisFeature.tests, thisTest )   
    self.currentTest = thisTest
    thisFeature:before()
    thisTest:run()
    thisFeature:after()
end

function booneUnit:ignore( description, scenario ) 
end

function booneUnit:before(setup)
    if self.currentFeature then self.currentFeature.before = setup end
end
function booneUnit:after(teardown)
    if self.currentFeature then self.currentFeature.after = teardown end
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
end
function booneUnit.newTest:run()
    local status, err = pcall(self.test)
    if err then
        --self.failures = self.failures + 1
        print(string.format("%d: %s -- %s \n--FAIL", 69, self.description, err))
        --store result
    end
end
function booneUnit.newTest:registerResult()
end

