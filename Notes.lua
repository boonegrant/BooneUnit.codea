loadOrder = function ()
    print( "Project Last" )
    print( "Left Tab Last" )
end

-- output to clipboard
-- output to project tab
-- output to text file
-- output to text box (soda)

--[[

( ) booneUnit:test() should protect and log errors when running :before() and :after()

(X) indicate private data members with underscore (i.e.  "aBooneUnit._tests")

(X) make booneunit a class
(X) booneUnits have id
(X) use booneunit to run self tests

() check where print() statements come from
() all print statements made by BooneUnit

() ?split out descriptor in result registration function? (HAS, ISNT, etc)

( ) testInfo.report() output to console
    detailed arg

(X) BooneUnit:tally()
(X) BooneUnit:summary()
( ) BooneUnit:report() 

() expect() takes description argument

() group orphan tests between features

() before and after statements clarification or warning without describe

() .has() works with strings

() import test generation functions 

(X) linebrake function

--]]


-- Each expectation registers a result in a test, a test's results determine its outcome, Features group tests and tally outcomes

--[[
local function alphaIndex( num )
  return string.char( string.byte( "a" ) + num - 1 )
end

00000000000
└╠╳╰⚪︎
--]]