function lestBooneUnitDelay()
    CodeaUnit.detailed = false
    local aBooneUnit = BooneUnit("Dwezil") 
    aBooneUnit.silent = true
    _:describe( 'aBooneUnit:delay() executes the conclusion of a test '..
                'after a certain amount of time has passed', function()
        aBooneUnit:reset()
        _:test( "aBooneUnit:delay() is a function", function()
            _:expect( type( aBooneUnit.delay ) ).is( "function" )
        end )
        _:test( "aBooneUnit:_continue() is a function", function()
            _:expect( type( aBooneUnit._continue ) ).is( "function" )
        end )
        _:test( "aBooneUnit:delay() throws error if not inside a test", function()
            _:expect( function() aBooneUnit:delay() end ).throws( aBooneUnit._errorMsgs.delayWithoutTest )
        end )
        _:test( "aBooneUnit:delay() sets test status to pending", function()
            local doneDelayStuff = false
            local thisTestInfo = aBooneUnit:test( "do a delay", function()
                aBooneUnit:delay( 0.01, function() 
                    doneDelayStuff = true
                    _:expect( aBooneUnit._currentTest:status() ).is( "pending" )
                end )
            end )
        end )
        _:test( "aBooneUnit:_continue() removes pending status ", function()
            local doneDelayStuff = false
            local thisTestInfo = aBooneUnit:test( "do a delay", function()
                aBooneUnit:delay( 0.001, function() 
                    doneDelayStuff = true
                end )
            end )
            tween.delay( 0.2, function()
                _:expect( thisTestInfo:status() ).isnt( "pending" )
            end )
        end )
        ---[[
        _:test( "aBooneUnit:_continue() runs the function passed in aBooneUnit.delay", function()
            local doneDelayStuff = false
            aBooneUnit:test( "do a delay", function()
                print( "getting ready" )
                aBooneUnit:delay( 0.001, function() 
                    doneDelayStuff = true
                end )
                print( "did it work?" )
            end )
            tween.delay( 0.5, function() 
                _:expect( doneDelayStuff ).is( true )
            end )
        end )
        _:test( "aBooneUnit:expect() statements inside aBooneUnit:delay()"..
            " will register results with the appropriate test", function()
            local doneDelayStuff = false
            local test1 = aBooneUnit:test( "do a delay", function()
                aBooneUnit:delay( 0.8, function()
                    print("ok, back to work")
                    local thing = 5
                    aBooneUnit:expect( thing ).is(5)
                    doneDelayStuff = true
                end )
                print( "that's it for now" )
            end )
            local test2 = aBooneUnit:test( "empty test", function()end )
            tween.delay( 1, function()
                print( string.format( 'test1 status: %s', test1:status() ) )
                print( string.format( 'test2 status: %s', test2:status() ) )
                _:expect( test1:status() ).is( "pass" )
            end )
        end )
        --]]
    end )
    tween.delay( 2, function()
        _:summarize()
    end )
end


