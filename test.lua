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
local list    = cells.list

local a = cons('A')
local b = cons(cons('A'), cons('B'))
local c = cons('A', cons('B'))

local unit_test_count = 0


-- tostring checks

assert(a:tostring() == '(A)')
assert(b:tostring() == '((A) B)')
assert(c:tostring() == '(A B)')
assert(cons() == nil)

-- (A B C)
local a = cons('A', cons('B', cons ('C', nil)))
assert(cells.tostring(a) == '(A B C)')

-- A list with one cycle
a:set_car(a)
assert(cells.tostring(a) == '#1=(#1# B C)')

-- A list with car and cdr with cycles
a:set_cdr(a)
assert(cells.tostring(a) == '#1=(#1# #1#)')

-- Two cycles
local b = cons('B')
local c = cons('C')
local a = cons(b, cons(c, cons(b, cons(c))))
assert(cells.tostring(a) == '(#1=(B) #2=(C) #1# #2#)')

-- Testing 'list' function
local a = list()
assert(cells.tostring(a) == '()')

local a = list('A', 'B', 'C')
assert(cells.tostring(a) == '(A B C)')

-- A list with functions
local f = function (x) return x end
local a = list(f, f, f)
assert(a:car() == f)
assert(a:cadr() == f)
assert(a:caddr() == f)

print('All tests passed')
