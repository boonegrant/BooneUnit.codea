BooneUnit = class()
BooneUnit.id = "BooneUnit"
BooneUnit._tallyCategoryOrder = { "pass", "ignore", "empty", "pending", "fail" }
BooneUnit._tallyCategoryNames = { 
    pass    = "Passed", 
    ignore  = "Ignored", 
    empty   = "Empty",
    pending = "Pending", 
    fail    = "Failed",
    total   = "Tests"
    }
BooneUnit._errorMsgs = { 
    testInsideTest = '"BooneUnit:test()" declaration cannot be made inside another "test()" declaration',
    expectWithoutTest = '"BooneUnit:expect()" statements should be placed inside a "test()" declaration',
    delayWithoutTest =  '"BooneUnit:delay()" statements should be placed inside a "test()" declaration',
    throwsArgIsNotFunction = '"BooneUnit:expect( <arg> ).throws()" -- <arg> must be a function' 
    }
function BooneUnit:reset ()
    self.features = {}
    self._currentFeature = nil
    self._currentTest = nil
    self._aHomeForOrphanTests = nil
end
BooneUnit:reset()

function BooneUnit:init ( id )
    -- Stores id to differentiate text output, mostly for 
    -- self-testing purposes 
    self.id = id or ""
    self:reset()
end

function BooneUnit:execute()
    self:reset()
    for i,v in pairs(listProjectTabs()) do
        local source = readProjectTab(v)
        for match in string.gmatch(source, "function%s-(test.-%(%))") do
            -- self._activeFunction = match
            load(match)()
            -- self._activeFunction = nil
        end
    end
    self:summarize()
end

function BooneUnit:describe( featureDescription, featureTests )
    -- Create feature info table
    local thisFeature = self.FeatureInfo( featureDescription )
    table.insert( self.features, thisFeature )   
    -- Announce feature
    if not self.silent then
        print( string.format( "%s-%s", self.id, thisFeature:intro() ) )
    end
    -- Run tests
    self._currentFeature = thisFeature
    local runTests = featureTests or function() end
    runTests()
    self._currentFeature = nil
    -- Announce summary of results
    if not self.silent then
        print( string.format( "%s-%s", self.id, thisFeature:report() ) )
    end
    return thisFeature
end

function BooneUnit:before(setup)
    if self._currentFeature then self._currentFeature.before = setup end
    -- error message: before and after must be inside a describe: declaration
end
function BooneUnit:after(teardown)
    if self._currentFeature then self._currentFeature.after = teardown end
end

function BooneUnit:ignore( testDescription, scenario )
    local thisFeature = self._currentFeature or self:_orphanage()
    local thisTest = thisFeature:registerTest( testDescription, scenario )
    thisTest:registerResult("ignore", "", "") 
    if not self.silent then
        print( string.format( '#%d %s:ignore()\n%s', #thisFeature.tests, self.id, thisTest:report() ) )
        -- thisTest:report( self.detailed )
    end
    return thisTest
end

function BooneUnit:test( testDescription, scenario )
    if self._currentTest then  -- check if there is already an active test statement
        error( self._errorMsgs.testInsideTest, 2 )
    end
    local thisFeature = self._currentFeature or self:_orphanage()
    local thisTest = thisFeature:registerTest( testDescription, scenario )
    thisFeature:before()
    self._currentTest = thisTest
    thisTest:run( scenario )
    self._currentTest = nil
    thisFeature:after()
    if not self.silent then
        print( string.format( '#%d %s:test()\n%s', #thisFeature.tests, self.id, thisTest:report() ) )
    end
    return thisTest
end

-- BooneUnit:delay() used inside a test statement to delay evaluation of expectations
function BooneUnit:delay( numSeconds, scenario )
    local thisTest = self._currentTest
    if thisTest == nil then
        error( self._errorMsgs.delayWithoutTest, 2 )
        return nil
    end
    thisTest:registerResult( "pending" ) -- next add tween id
    local pendingIndex = #thisTest.results
    tween.delay( numSeconds, function ()
        self:_continue( thisTest, pendingIndex, scenario )
    end )
    -- return tween, test, callback,what?
end

function BooneUnit:_continue( thisTest, pendingIndex, scenario )
    self._currentTest = thisTest
    thisTest:run( scenario )
    self._currentTest = nil
    table.remove( thisTest.results, pendingIndex )
end

function BooneUnit:expect( conditional ) -- TODO: add name arg
    local thisTest = self._currentTest
    -- Usage check: expect statements must occur inside a test statement
    if thisTest == nil then
        error( self._errorMsgs.expectWithoutTest, 2 ) -- 2 is where in stack level is returned for context
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
            -- usage check : conditional must be function
            error(string.format( '%s -- is "%s"', 
                BooneUnit._errorMsgs.throwsArgIsNotFunction, 
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

function BooneUnit:_orphanage()  -- create a home for tests not placed inside a :describe() declaration
    -- this is so they can be grouped and tabulated together 
    -- ?Create new Feature for each group of orphan tests ?
    if ( self._aHomeForOrphanTests == nil ) then  -- or aHomeForOrphanTests ~= self.features[#self.features]
        self._aHomeForOrphanTests = self.FeatureInfo( "No Description" )
        table.insert( self.features, self._aHomeForOrphanTests )   
    end
    return self._aHomeForOrphanTests
end


-- Reporting Functions
--
-- returns table
function BooneUnit:tally()
    local unitTally = {}
    unitTally.features = #self.features
    unitTally.total = 0
    -- itterate over features
    for i,v in ipairs( self.features ) do
        featureTally = v:tally()
        -- itterate over feature tally results 
        for category, count in pairs( featureTally ) do
            if ( unitTally[ category ] ) then
                -- category already exists
                unitTally[ category ] = unitTally[ category ] + count
            else
                -- create category
                unitTally[ category ] = count
            end
        end
    end
    return unitTally
end

-- untested
function BooneUnit:status(tallyTable)
    local unitTally = tallyTable or self:tally()
    if (unitTally.total == 0) then 
        return "No Tests Run"
    end 
    for i = #self._tallyCategoryOrder, 1, -1 do
        local currentCategory = self._tallyCategoryOrder[i]
        local countString 
        print( currentCategory )
        if unitTally[ currentCategory ] then
            if unitTally[ currentCategory ] == unitTally.total then
                countString = "All"
            else
                countString = string.format( "%i", unitTally[ currentCategory ] )
            end
            local statusString = string.format( "%s %s", 
                                  countString,
                                  self._tallyCategoryNames[ currentCategory ] )
            print( statusString )
            return statusString
        end
    end
    return string.format( "%i tests", unitTally.total )
end

-- returns string
function BooneUnit:summary(tallyTable)
    local unitTally = tallyTable or self:tally()
    return string.format( "summary: %i tests", unitTally.total ) 
end

-- ---------------------- --
--   Feature Info class   --
-- ---------------------- --
BooneUnit.FeatureInfo = class()

function BooneUnit.FeatureInfo:init( featureDescription )
    self.description = featureDescription or ""
    self.tests = {}
end

function BooneUnit.FeatureInfo:registerTest( testDescription, scenario )
    aTest = BooneUnit.TestInfo( self, testDescription, scenario )
    table.insert( self.tests, aTest )
    return aTest
end

function BooneUnit.FeatureInfo:intro()
    return string.format( "Feature: %s \n tests:", self.description )
end

-- BooneUnit.FeatureInfo:report()
--      Returns a string describing the results of the tests within the feature
function BooneUnit.FeatureInfo:report() --change name to summary; report will be enitre report
    local theTally = self:tally()
    local reportCategories = {}
    local separator = ' ----------'
    -- assemble tally strings in prefered order
    for i, v in ipairs( BooneUnit._tallyCategoryOrder ) do
        if theTally[v] then
            local category = string.format( "%3i %s", theTally[v], BooneUnit._tallyCategoryNames[v] or v )
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

-- BooneUnit.FeatureInfo:tally()
--          Returns a table summing and totaling the test results in a feature
function BooneUnit.FeatureInfo:tally()
    local theTally = { total = #self.tests }
    -- walk through tests
    for i, v in ipairs( self.tests ) do
        local testStatus = v:status()
        -- tally by category
        if theTally[ testStatus ] then
            theTally[ testStatus ] = theTally[ testStatus ] + 1
        else
            theTally[ testStatus ] = 1
        end
    end
    return theTally
end

function BooneUnit.FeatureInfo.before() end -- default empty function
function BooneUnit.FeatureInfo.after() end  -- default empty function


-- ------------------- --
--   Test Info class   --
-- ------------------- --
BooneUnit.TestInfo = class()
function BooneUnit.TestInfo:init( parent, testDescription, scenario )
    self.feature = parent  -- not sure I need this, may be useful for delayed reports
    self.description = tostring(testDescription or "")
    self.results = {}
end

function BooneUnit.TestInfo:run( scenario )
    local status, error = pcall( scenario or function() end )
    if error then
        self:registerResult( false, "ERROR", error )
    end
end

function BooneUnit.TestInfo:registerResult( outcome, actual, expected )
    table.insert( self.results, { outcome = outcome, actual = actual, expected = expected} )
    return #self.results
end

-- [test]:passed() - returns true if there is at least one result 
--                   recorded and all results are successful or ignored
function BooneUnit.TestInfo:passed()
    local testPassed = #self.results > 0  -- at least one result recorded
    for i, v in ipairs( self.results ) do
        if v.outcome ~= true then return false end
    end
    return testPassed
end

function BooneUnit.TestInfo:status()
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

function BooneUnit.TestInfo:report() --TODO: add 'detailed' parameter
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

function BooneUnit.TestInfo:formatHeader( description )
    return "header"
end

function BooneUnit.TestInfo:formatResult( expected, actual, outcome )
    return "result"
end

function BooneUnit.TestInfo:formatStatus( status )
    return "status"
end
