--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

----------------------------------------------------------------------
-- CELLS unit tests
----------------------------------------------------------------------

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

-- A list of cons-cells with functions
local f = function (x) return x end
local a = list(f, f, f)
assert(a:car() == f)
assert(a:cadr() == f)
assert(a:caddr() == f)

print('cells: All tests passed')

----------------------------------------------------------------------
-- READER Unit tests
----------------------------------------------------------------------

local reader = require 'reader'

local test_reader = function (input_text, expected_text)

  local r = reader.new(input_text)
  local cells, errors = r:read()
  local s = ''
  for i,cell in ipairs(cells) do
    s = s .. tostring(cell) .. (i == #cells and '' or ':')
  end
  assert(errors == nil)
  assert(#cells > 0)
  assert(s == expected_text)

end

test_reader('(A   B )', '(A B)')
test_reader('42 43', '42:43')
test_reader('(A B) (C D)', '(A B):(C D)')
test_reader("  ( A . B )  ' ( C  D ) ", '(A . B):(quote (C D))')

-- s-expressions with errors
local r = reader.new('(A')
local c, e = r:read()
assert(c == nil and e == 'Unexpected end of file')

local r = reader.new('(A . B C)')
local c,e = r:read()
assert(c == nil and e == '1:8:Malformed dotted pair')

print('reader: All tests passed')

