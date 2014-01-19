--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

local cells = require 'cells'

local cons    = cells.cons
local car     = cells.car
local cdr     = cells.cdr
local append  = cells.append
local last    = cells.last
local length  = cells.length
local is_atom = cells.is_atom
local is_cons = cells.is_cons
local is_nil  = cells.is_nil

local a = cons("A")
local b = cons(cons("A"), cons("B"))
local c = cons("A", cons("B"))

local v = {a,b,c}

for _, a in ipairs(v) do
  print("SEXPR      : ", a)
  print("is_cons    : ", a:is_cons())
  print("is_nil     : ", a:is_nil())
  print("is_atom    : ", a:is_atom())

  print("car        : ", car(a))
  print(":car       : ", a:car())
  print("car is_atom: ", is_atom(car(a)))

  print("cdr        : ", cdr(a))
  print(":cdr       : ", a:cdr())
  print("cdr is_atom: ", is_atom(cdr(a)))

  print("last       : ", a:last())
  print("length     : ", a:length())
  print(":nth(1)    : ", a:nth(1))
  print()
end

print("B            = ", b)
print("C            = ", c)
print("(append B C) = ", append(b, c))
a:set_car(a)

a = nil
b = nil
c = nil

