booneUnit = {}
function booneUnit:reset ()
    self.features = {}
    self.currentFeature = nil
    self.currentTest = nil
    self.bork = 17
    self.beck = 0.852
end

function booneUnit:describe ( featureDescription, allTests )
    self.currentTest = nil    
    
    local thisFeature = self.newFeature( featureDescription, allTests )
    self.currentFeature = thisFeature
    table.insert( self.features, thisFeature )    
    print( thisFeature:intro() )
    thisFeature:runTests()
    print( thisFeature:results() )
end

function booneUnit:test( description, scenario )
        
end

function booneUnit:ignore ( description, scenario )
    
end




-- Feature class --
booneUnit.newFeature = class()
function booneUnit.newFeature:init( featureDescription , allTests )
    self.description = featureDescription or ""
    self.tests = {}
    self.ignored = {}
    -- does runTests work with dot and colon? 
    -- should runTests be called loadTests?
    self.runTests = allTests or ( function() end )  -- test for value = function?
end
function booneUnit.newFeature:intro()
    string.format( "Feature: %s", self.description )
end
function booneUnit.newFeature:results()
    string.format( "Feature: %s -- Results go here", self.description )
end

-- Test class --
booneUnit.newTest = class()
function booneUnit.newTest:init( testDescription, scenario )
    self.description = testDescription or ""
    self.runTest = scenario or ( function() end )
end
