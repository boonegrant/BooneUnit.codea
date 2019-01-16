booneUnit = {}
function booneUnit:reset ()
    self.features = {}
    self.numTests = 0
end

function booneUnit:describe ( description, allTests )
    local feature = {}
    table.insert( self.features, feature )   
    feature.description = description
    feature.tests = {} 
    feature.numTests = 0
    function feature:runTests ()
        allTests()
    end
    function feature:test( description, scenario )
        
    end
     
end

function testBooneUnit()
    --CodeaUnit.detailed = false
    local unitMembers = { "features", "numTests", "describe" }
    local featureMembers = { "description", "tests", "numTests", "runTests", "test" }
    local featureDesc = "print"
    _:describe( "booneUnit", function ()
        _:test( "booneUnit exists", function ()
            _:expect( booneUnit ).isnt( nil )
        end )
        
        -- init
        _:test( "set/reset", function ()
            _:expect( booneUnit.reset ).isnt( nil )
            _:expect( booneUnit:reset() ).is( nil )
        end )
        
        --members
        for i, v in ipairs( unitMembers ) do
            _:test( "booneUnit contains " .. v, function ()
                _:expect( booneUnit[ v ] ).isnt( nil )
            end )
        end
        
        -- features is empty
        _:test( "booneUnit.features is empty", function ()
            local f = booneUnit.features
            _:expect( f[1] ).is( nil )
            _:expect( #f ).is( 0 )
        end )
        
        --call :describe()
        _:test( "call describe()", function ()
            _:expect( booneUnit:describe( featureDesc, function() 
                print("woo-hoo!") end) ).is( nil )
        end )
        
        -- features not empty
        _:test( "booneUnit.features not empty", function ()
            local f = booneUnit.features
            _:expect( #f ).is( 1 )
            _:expect( f[1] ).isnt( nil )
        end )
        
        -- feature members 
        for i, v in ipairs( featureMembers ) do
            _:test( "features[1] has " .. v, function ()
                local f = booneUnit.features
                _:expect( f[ 1 ][ v ] ).isnt( nil )
            end )
        end
        
        -- feature description 
        _:test( "feature description matches argument", function ()
            local target = booneUnit.features[1]
            _:expect( target.description ).is( featureDesc )
        end )
        
        
    end )
end
