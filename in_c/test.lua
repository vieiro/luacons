--
-- Lua cons cells using C
--

local cons = require 'cons'

local gc = function()
  collectgarbage("collect")
  print("Used memory: ", collectgarbage("count"))
end

local a = cons.new("A", "B")

print(a)
gc()

a = cons.new("A", cons.new("B", "C"))

print(a)
gc()

a = cons.new(cons.new("A", cons.new("B", "C")))

print(a)
print("car", a:car())
print("cdr", a:cdr())
gc()

a = nil

gc()
