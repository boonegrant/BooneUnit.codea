function testCodeaUnitFunctions()
    local ut = booneUnit
    local bart = "Cowabunga!"
    ut:test( "bart is bart", function() 
        ut:expect( bart ).is( bart )
    end )
    ut:test( "bart is string", function() 
        ut:expect( type( bart ) ).is( "string" )
    end )
end


-- output to clipboard
-- output to project tab
-- output to text box (soda)
