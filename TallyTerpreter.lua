TallyTerpreter = class()

function TallyTerpreter:init( tallyTable )
    tallyTable = tallyTable or {}
    for key, value in pairs( tallyTable ) do
        self[ key ] = value
    end
end

do 
    TallyTerpreter.tallyCategoryOrder = BooneUnit._tallyCategoryOrder
    TallyTerpreter.headerCategories = { "total", "features" }
    TallyTerpreter.categoryNames = BooneUnit._tallyCategoryNames
    local green = color(17, 199, 30)
    local yellow = color(255, 229, 0)
    local red = color(255, 5, 0)
    TallyTerpreter.statusColors = { pass = green, fail = red }
end

function TallyTerpreter:toString()
end

function TallyTerpreter:body( separator )
end

function TallyTerpreter:header( separator )
end

function TallyTerpreter:footer()
end

function TallyTerpreter:status()
    local unitTally = self
    if (unitTally.total == 0) then 
        return "No Tests Run"
    end 
    for i = #self.tallyCategoryOrder, 1, -1 do
        local currentCategory = self.tallyCategoryOrder[i]
        local countString 
        -- print( currentCategory )
        if unitTally[ currentCategory ] then
            if unitTally[ currentCategory ] == unitTally.total then
                countString = "All"
            else
                countString = string.format( "%i", unitTally[ currentCategory ] )
            end
            local statusString = string.format( "%s %s", 
                                  countString,
                                  self.categoryNames[ currentCategory ] )
            -- print( statusString )
            return statusString
        end
    end

end

