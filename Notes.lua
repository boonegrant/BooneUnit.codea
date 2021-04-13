
-- output to clipboard
-- output to project tab
-- output to text file
-- output to text box (soda)

--[[

(X) indicate private data members with underscore (i.e.  "aBooneUnit._tests")

(X) make booneunit a class
(X) booneUnits have id
( ) use booneunit to run self tests

() check where print() statements come from
() all print statements made by BooneUnit

() ?split out descriptor in result registration function? (HAS, ISNT, etc)

( ) testInfo.report() output to console
    detailed arg

(X) BooneUnit.tally()
( ) BooneUnit.report() 

() expect() takes description argument

() group orphan tests between features

() before and after statements clarification or warning without describe

() .has() works with strings

() import test generation functions 

() linebrake function
--]]


-- Each expectation registers a result in a test, a test's results determine its outcome, Features tally outcomes

--[[
local function alphaIndex( num )
  return string.char( string.byte( "a" ) + num - 1 )
end

00000000000
└╠╳╰⚪︎
--]]