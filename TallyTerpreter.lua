TallyTerpreter = class()

function TallyTerpreter:init( tallyTable )
    tallyTable = tallyTable or {}
    for key, value in pairs( tallyTable ) do
        self[ key ] = value
    end
end

do 
    TallyTerpreter.tallyCategoryOrder = BooneUnit._tallyCategoryOrder
    TallyTerpreter.tallyHeaderOrder = { "total", "features" }
    TallyTerpreter.tallyCategoryNames = BooneUnit._tallyCategoryNames
    local green = color(17, 199, 30)
    local yellow = color(255, 229, 0)
    local red = color(255, 5, 0)
    TallyTerpreter.statusColors = { pass = green, fail = red }
end

function TallyTerpreter:toStringFilter( orderedCategoryTable, separator )
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
    separator = separator or "\n" -- Backfill default
    return self:toStringFilter( self.tallyCategoryOrder, separator )
end

function TallyTerpreter:headerToString( separator )
    separator = separator or ", " -- Backfill default
    return self:toStringFilter( self.tallyHeaderOrder, separator )
end

function TallyTerpreter:footer()
end

function TallyTerpreter:status()
    if (self.total == 0) then 
        return "No Tests Run"
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
            return statusString
        end
    end

end

