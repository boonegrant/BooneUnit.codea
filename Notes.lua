
-- output to clipboard
-- output to project tab
-- output to text box (soda)

--[[

make method call FeatureInfo:registerTest (logTest?, addTest?)

BooneUnit.test.status() I have no idea how ignored is handled

check where print() statements come from

? split out descriptor in result registration function ? (HAS, ISNT, etc)

make booneunit a class
use booneunit to run self tests

indicate private data members with underscore (i.e.  "aBooneUnit._tests")

testInfo.report() output to console
    detailed

BooneUnit.tally()
BooneUnit.report() 

all print statements made by BooneUnit

expect() takes description argument

group orphan tests between features

before and after statements clarification or warning without describe

.has() works with strings

import test generation functions 

linebrake function
--]]


-- Each expectation registers a result in a test, a test's results determine its outcome, Features tally outcomes

--[[
local function alphaIndex( num )
  return string.char( string.byte( "a" ) + num - 1 )
end

00000000000
└╠╳╰⚪︎
--]]