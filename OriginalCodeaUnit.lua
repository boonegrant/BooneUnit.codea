OriginalCodeaUnit = class()

function OriginalCodeaUnit:describe(feature, allTests)
    self.tests = 0
    self.ignored = 0
    self.failures = 0
    self._before = function()
    end
    self._after = function()
    end
    
    print(string.format("Feature: %s", feature))
    
    allTests()
    
    local passed = self.tests - self.failures - self.ignored
    local summary = string.format("%d Passed, %d Ignored, %d Failed", passed, self.ignored, self.failures)
    
    print(summary)
end

function OriginalCodeaUnit:before(setup)
    self._before = setup
end

function OriginalCodeaUnit:after(teardown)
    self._after = teardown
end

function OriginalCodeaUnit:ignore(description, scenario)
    self.description = tostring(description or "")
    self.tests = self.tests + 1
    self.ignored = self.ignored + 1
    if OriginalCodeaUnit.detailed then
        print(string.format("%d: %s \n-- Ignored", self.tests, self.description))
    end
end

function OriginalCodeaUnit:test(description, scenario)
    self.description = tostring(description or "")
    self.tests = self.tests + 1
    self._before()
    local status, err = pcall(scenario)
    if err then
        self.failures = self.failures + 1
        print(string.format("%d: %s -- %s", self.tests, self.description, err))
    end
    self._after()
end

function OriginalCodeaUnit:expect(conditional)
    local message = string.format("%d: %s", (self.tests or 1), self.description)
    
    local passed = function()
        if OriginalCodeaUnit.detailed then
            local actual = tostring(conditional)
            print(string.format("%s -- %s \n-- OK", message, actual))
        end
    end
    
    local failed = function()
        self.failures = self.failures + 1
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
        local ok, error = pcall(conditional)
        if ok then
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

OriginalCodeaUnit.execute = function()
    for i,v in pairs(listProjectTabs()) do
        local source = readProjectTab(v)
        for match in string.gmatch(source, "function%s-(test.-%(%))") do
            loadstring(match)()
        end
    end
end

OriginalCodeaUnit.detailed = true



-- _ = OriginalCodeaUnit()

parameter.action("OriginalCodeaUnit Runner", function()
    OriginalCodeaUnit.execute()
end)