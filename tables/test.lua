--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

local cells = require 'cells'

local cons   = cells.cons
local car    = cells.car
local cdr    = cells.cdr
local append = cells.append
local last   = cells.last
local length = cells.length

local a = cons("A")
local b = cons(cons("A"), cons("B"))
local c = cons("A", cons("B"))

local v = {a,b,c}

for _, a in ipairs(v) do
  print("SEXPR   : ", a)
  print("is_cons : ", a:is_cons())
  print("is_nil  : ", a:is_nil())
  print("car     : ", car(a))
  print("cdr     : ", cdr(a))
  print(":car    : ", a:car())
  print(":cdr    : ", a:cdr())
  print("last    : ", a:last())
  print("length  : ", a:length())
  print(":nth(1) : ", a:nth(1))
  print()
end

print("B            = ", b)
print("C            = ", c)
print("(append B C) = ", append(b, c))
