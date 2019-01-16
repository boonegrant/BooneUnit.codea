booneUnit = {}
function booneUnit:reset ()
    self.features = {}
    self.numTests = 0
end

function booneUnit:describe ( description, allTests )
    local thisFeature = {}
    table.insert( self.features, thisFeature )   
    thisFeature.description = description
    thisFeature.tests = {} 
    thisFeature.numTests = 0
    
    function thisFeature:runTests ()
        scope = self
        return allTests()
    end
    
    function thisFeature:test( description, scenario )
        local thisTest = {}
        table.insert( self.tests, thisTest )
        thisTest.testNum = #self.tests 
        thisTest.description = description
    end
    
end

