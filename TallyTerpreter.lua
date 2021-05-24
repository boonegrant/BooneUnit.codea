TallyTerpreter = class()

-- setup
do 
    TallyTerpreter.tallyCategoryOrder = { "pass", "ignore", "empty", "pending", "fail" } -- in ascending order of priority
    TallyTerpreter.tallyHeaderOrder = { "features", "total" }
    TallyTerpreter.tallyCategoryNames = { 
        pass     = "Passed", 
        ignore   = "Ignored", 
        empty    = "Empty",
        pending  = "Pending", 
        fail     = "Failed",
        total    = "Tests",
        features = "Features"
    }
    local green = color(17, 199, 30)
    local yellow = color(255, 229, 0)
    local red = color(255, 5, 0)
    local gray = color(184)
    local magenta = color(255, 0, 255)
    TallyTerpreter.tallyStatusColors = { 
        pass    = green, 
        ignore  = yellow,
        empty   = yellow,
        pending = yellow,
        fail    = red,
        none    = gray,
        other   = magenta
    }
end

function TallyTerpreter:init( tallyTable )
    tallyTable = tallyTable or {}
    for key, value in pairs( tallyTable ) do
        self[ key ] = value
    end
end

-- stringFromFilter
function TallyTerpreter:stringFromFilter( orderedCategoryTable, separator )
    orderedFilter = orderedFilter or {}
    separator = separator or "\n" -- Backfill default
    local textTable = {}
    -- assemble tally strings in prefered order
    for i, v in ipairs( orderedCategoryTable ) do
        if self[v] then
            local categoryString = string.format( "%3i %s", self[v], self.tallyCategoryNames[v] or v )
            table.insert( textTable, categoryString )
        end
    end
    return table.concat( textTable, separator )
end

function TallyTerpreter:bodyToString( separator )
    return self:stringFromFilter( self.tallyCategoryOrder, separator )
end

function TallyTerpreter:headerToString( separator )
    return self:stringFromFilter( self.tallyHeaderOrder, separator )
end

function TallyTerpreter:status()
    if (self.total == 0) then 
        return "No Tests Run", self.tallyStatusColors[ "none" ]
    end 
    -- itterate over tallyCategoryOrder in reverse (descending signifigance)
    for i = #self.tallyCategoryOrder, 1, -1 do
        local currentCategory = self.tallyCategoryOrder[i]
        local countString 
        if self[ currentCategory ] then -- found most significant category
            if self[ currentCategory ] == self.total then
                countString = "All"
            else
                countString = string.format( "%i", self[ currentCategory ] )
            end
            local statusString = string.format( "%s %s", 
                                 countString,
                                 self.tallyCategoryNames[ currentCategory ] )
            local statusColor = self.tallyStatusColors[ currentCategory ] or 
                                self.tallyStatusColors[ "other" ]
            return statusString, statusColor
        end
    end

end

