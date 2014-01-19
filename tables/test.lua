--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

local cells = require 'cells'

local append  = cells.append
local car     = cells.car
local cdr     = cells.cdr
local cons    = cells.cons
local is_atom = cells.is_atom
local is_cons = cells.is_cons
local is_nil  = cells.is_nil
local last    = cells.last
local length  = cells.length

local a = cons('A')
local b = cons(cons('A'), cons('B'))
local c = cons('A', cons('B'))

local unit_test_count = 0


-- tostring checks

assert(a:tostring() == '(A)')
assert(b:tostring() == '((A) B)')
assert(c:tostring() == '(A B)')
assert(cons() == nil)

-- cyclic cells

local a = cons('A', cons('B', cons ('C', nil)))
assert(a:tostring() == '(A B C)')

a:set_car(a)
assert(a:tostring() == '#1=(#1# B C)')

a:set_cdr(a)
assert(a:tostring() == '#1=(#1# #1#)')

print('All tests passed')



