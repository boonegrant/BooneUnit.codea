TallyTerpreter = class()

function TallyTerpreter:init()
    
end

do 
    TallyTerpreter.tallyCategories = BooneUnit._tallyCategories
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
    
end

