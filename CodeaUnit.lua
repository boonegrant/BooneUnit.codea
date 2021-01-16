--CodeaUnit = class()
CodeaUnit = { status = "All Passed", totalFailed = 0 }

function CodeaUnit:describe(feature, allTests)
    self.tests = 0
    self.ignored = 0
    self.pending = 0
    self.failures = 0
    self._before = function() end
    self._after = function() end

    print(string.format("\n\n\n\n\n****************\n\nFeature: %s", feature))

    allTests()

    local passed = self.tests - self.failures - self.ignored - self.pending
    local summary = string.format("%s:\n%d Passed, %d Ignored, %d Pending, %d Failed"..
                                  "\n\n****************\n****************", 
                                  feature, passed, self.ignored, self.pending, self.failures)
    print(summary)
end

function CodeaUnit:before(setup)
    self._before = setup
end

function CodeaUnit:after(teardown)
    self._after = teardown
end

function CodeaUnit:ignore(description, scenario)
    self.description = tostring(description or "")
    self.tests = self.tests + 1
    self.ignored = self.ignored + 1
    if CodeaUnit.detailed then
        print(string.format("%d: %s \n-- Ignored", self.tests, self.description))
    end
end

function CodeaUnit:test(description, scenario)
    self.description = tostring(description or "")
    self.tests = self.tests + 1
    self._before()
    local status, err = pcall(scenario)
    if err then
        self.failures = self.failures + 1
        self.totalFailed = self.totalFailed + 1
        self.status = string.format( "%d FAILED", self.totalFailed )
        print(string.format("%d: %s -- %s \n--FAIL", self.tests, self.description, err))
    end
    self._after()
end

function CodeaUnit:delay( numSeconds, scenario )
    self.pending = self.pending + 1
    local testNum = self.tests
    local description = self.description
    tween.delay( numSeconds, function ()
        local status, err = pcall(scenario)
        if err then
            self.failures = self.failures + 1
            self.totalFailed = self.totalFailed + 1
            self.status = string.format( "%d FAILED", self.totalFailed )
            print(string.format("%d: %s -- %s \n--FAIL", testNum, description, err))
        end
    end )
end

function CodeaUnit:expect(conditional)
    local message = string.format("%d: %s", (self.tests or 1), self.description)

    local passed = function()
        if CodeaUnit.detailed then
            local actual = tostring(conditional)
            print(string.format("%s -- %s \n-- OK", message, actual))
        end
    end

    local failed = function()
        self.failures = self.failures + 1
        self.totalFailed = self.totalFailed + 1
        self.status = string.format( "%d FAILED", self.totalFailed )
        local actual = tostring(conditional)
        local expected = tostring(self.expected)
        print(string.format("%s -- Actual: %s, Expected: %s \n-- FAIL", message, actual, expected))
    end

    local notify = function(result)
        if result then
            passed()
        else
            failed()
        end
    end
    
    local is = function(expected)
        self.expected = expected
        notify(conditional == expected)
    end

    local isnt = function(expected)
        self.expected = expected
        notify(conditional ~= expected)
    end

    local has = function(expected)
        self.expected = expected
        local found = false
        for k,v in pairs(conditional) do
            if v == expected then
                found = true
            end
        end
        notify(found)
    end

    local throws = function(expected)
        self.expected = expected
        local status, error = pcall(conditional)
        if not error then
            conditional = "nothing thrown"
            notify(false)
        else
            notify(string.find(error, expected, 1, true))
        end
    end

    return {
        is = is,
        isnt = isnt,
        has = has,
        throws = throws
    }
end

function CodeaUnit:summarize()
        print( string.format("\n\n------- %s -------\n", CodeaUnit.status ) )
end

CodeaUnit.execute = function()
    CodeaUnit.status = "All Passed"
    CodeaUnit.totalFailed = 0
    for i,v in pairs(listProjectTabs()) do
        local source = readProjectTab(v)
        for match in string.gmatch(source, "function%s-(test.-%(%))") do
            loadstring(match)()
        end
    end
    CodeaUnit.summarize()
end

CodeaUnit.detailed = true

--_ = CodeaUnit()
_ = CodeaUnit

parameter.action("CodeaUnit Runner", function()
    _ = CodeaUnit
    _.execute()
end) 