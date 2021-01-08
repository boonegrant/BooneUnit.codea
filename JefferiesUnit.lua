JeffriesUnit = class()

function JeffriesUnit:describe(feature, allTests)
    self.tests = 0
    self.ignored = 0
    self.failures = 0
    self._before = function()
    end
    self._after = function()
    end
    
    local f_string = string.format("Feature: %s", feature)
    JeffriesUnit._summary = JeffriesUnit._summary .. f_string .. "\n"
    print(f_string)
    
    allTests()
    
    local passed = self.tests - self.failures - self.ignored
    local summary = string.format("%d Passed, %d Ignored, %d Failed", passed, self.ignored, self.failures)
    JeffriesUnit._summary = JeffriesUnit._summary .. summary .. "\n"
    print(summary)
end

function JeffriesUnit:before(setup)
    self._before = setup
end

function JeffriesUnit:after(teardown)
    self._after = teardown
end

function JeffriesUnit:ignore(description, scenario)
    self.description = tostring(description or "")
    self.tests = self.tests + 1
    self.ignored = self.ignored + 1
    if JeffriesUnit.detailed then
        print(string.format("%d: %s -- Ignored", self.tests, self.description))
    end
end

function JeffriesUnit:test(description, scenario)
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

function JeffriesUnit:expect(conditional, msg)
    local message = string.format("%d: %s %s", (self.tests or 1), self.description, (msg or ""))
    
    local passed = function()
        if JeffriesUnit.detailed then
            print(string.format("%s -- OK", message))
        end
    end
    
    local failed = function()
        self.failures = self.failures + 1
        local actual = tostring(conditional)
        local expected = tostring(self.expected)
        print(string.format("%s -- Actual: %s, Expected: %s", message, actual, expected))
    end
    
    local notify = function(result)
        if result then
            passed()
        else
            failed()
        end
    end
    
    local is = function(expected, epsilon)
        self.expected = expected
        if epsilon then
            notify(expected - epsilon <= conditional and conditional <= expected + epsilon)
        else
            notify(conditional == expected)
        end
    end
    
    local isnt = function(expected)
        self.expected = expected
        notify(conditional ~= expected)
    end
    
    local has = function(expected)
        self.expected = expected
        local found = false
        for i,v in pairs(conditional) do
            if v == expected then
                found = true
            end
        end
        notify(found)
    end
    
    local hasnt = function(expected)
        self.expected = expected
        local missing = true
        for i,v in pairs(conditional) do
            if v == expected then
                missing = false
            end
        end
        notify(missing)
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
    hasnt = hasnt,
    throws = throws
    }
end

JeffriesUnit.execute = function()
    JeffriesUnit._summary = ""
    for i,v in pairs(listProjectTabs()) do
        local source = readProjectTab(v)
        for match in string.gmatch(source, "function%s-(test.-%(%))") do
            print("loading", match)
            loadstring(match)()
        end
    end
    return JeffriesUnit._summary
end

JeffriesUnit.detailed = true



-- _ = JeffriesUnit()

parameter.action("JeffriesUnit Runner", function()
    JeffriesUnit.execute()
end)

-- make these JeffriesUnit.etc
-- create a fake main?
-- create a starting tests tab

-- or do we start from an example?

function runTests()
    local det = JeffriesUnit.detailed
    JeffriesUnit.detailed = false
    Console = _.execute()
    JeffriesUnit.detailed = det
end

function showTests()
    pushMatrix()
    pushStyle()
    fontSize(50)
    textAlign(CENTER)
    if not Console:find("0 Failed") then
        stroke(255,0,0)
        fill(255,0,0)
    elseif not Console:find("0 Ignored") then
        stroke(255,255,0)
        fill(255,255,0)
    else
        fill(0,128,0)
    end
    text(Console, WIDTH/2, HEIGHT-200)
    popStyle()
    popMatrix()
end
