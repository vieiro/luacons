--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

local memory = collectgarbage 'count'

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
local is_list = cells.is_list
local last    = cells.last
local length  = cells.length
local list    = cells.list
local nth     = cells.nth

local a = cons('A')
local b = cons(cons('A'), cons('B'))
local c = cons('A', cons('B'))

-- predicate tests
assert(is_cons(cons('A')))
assert(is_cons(cons('A', 'B')))
assert(is_list(cons('A')), '(A) must be a list')
assert(not is_list(cons('A', 'B')))

-- tostring checks

assert(a:tostring() == '(A)')
assert(b:tostring() == '((A) B)')
assert(c:tostring() == '(A B)')
assert(cons():tostring() == '(())')

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
local n, a = list(0)
assert(n == 1 and cells.tostring(a) == '()')

local n, a = list(3, 'A', 'B', 'C')
assert(n == 1 and cells.tostring(a) == '(A B C)')

local n, a = list(3, nil, nil, nil)
assert(n == 1 and cells.tostring(a) == '(() () ())')

-- A list of cons-cells with functions
local f = function (x) return x end
local n, a = list(3, f, f, f)
assert(a:car() == f)
assert(a:cadr() == f)
assert(a:caddr() == f)

print('cells','All tests passed.')

----------------------------------------------------------------------
-- LEXER Unit tests
----------------------------------------------------------------------

local lexer = require 'lexer'

local count_tokens = function(text, expected_token_count, verbose)
  local l = lexer.new(text)
  local token_count = 0
  if verbose then
    print('Tokenizing: ', text)
    print('Token', 'Line', 'Column')
  end
  while true do
    local token = l:next_token()
    if token == nil then assert(token_count == expected_token_count) return end
    token_count = token_count + 1
    if verbose then print(token, token.line, token.column) end
  end
end

count_tokens('(a b)', 4)
count_tokens('(a ;A comment\n b)', 4)
count_tokens('(123.456 . .45)', 5)
count_tokens(' ( a ( b ) . .45 0.45 )', 9)
count_tokens(' ( a ( b ) . -.45 -0.45 )', 9)
count_tokens('  "Foo\\"Foo\\"Foo" "Bar" ', 2)
count_tokens('"Foo" "Bar"', 2)

print('lexer','All tests passed.')

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
  assert(s == expected_text, 'Got "' .. s .. '" expected "' .. expected_text .. '"')

end

test_reader("'42", "(quote 42)")
test_reader('(A   B )', '(A B)')
test_reader("42 '43", '42:(quote 43)')
test_reader('(A B) (C D)', '(A B):(C D)')
test_reader("  ( A . B )  ' ( C  D ) ", '(A . B):(quote (C D))')

-- s-expressions with errors
local r = reader.new('(A')
local c, e = r:read()
assert(c == nil and e and e == '1:2:Unexpected end of file', "Errors are: " .. e)

local r = reader.new('(A . B C)')
local c,e = r:read()
assert(c == nil and e == '1:8:Malformed dotted pair')

print('reader','All tests passed.')

----------------------------------------------------------------------
-- MAP Unit tests
----------------------------------------------------------------------

local _,l1 = list(4, 10,20,30,40)
local _,l2 = list(4, 'a','b','c','d')
local _,l3 = list(3, 4,5,6)

local map   = cells.map
local apply = cells.apply
local zip   = cells.zip

local n,r = map(1, list, l1)
assert(n == 1 and r:tostring() == '((10) (20) (30) (40))')
local n,r = map(2, list, l1, l2)
assert(n == 1 and r:tostring() == '((10 a) (20 b) (30 c) (40 d))')
local n,r = map(2, list, l1, l3)
assert(n == 1 and r:tostring() == '((10 4) (20 5) (30 6))')
local n,r = map(2, list, l3, l1)
assert(n == 1 and r:tostring() == '((4 10) (5 20) (6 30))')
local n,r = map(2, list, l1, nil)
assert(n == 1 and cells.is_nil(r))
print('map','All tests passed.')

----------------------------------------------------------------------
-- APPLY Unit tests
----------------------------------------------------------------------

local _,l1 = list(4, 1,2,3,4)
local _,l2 = list(1, 5)

local adder = function(n, ...)
  local args = {...}
  local sum = 0
  for i=1,n do
    sum = sum + tonumber(tostring(args[i]))
  end
  return 1, sum
end

local n,r = apply(1, adder, l1)
assert(n == 1 and r == 1+2+3+4)
local n,r = apply(5, adder, 1, 2, 3, 4, l2)
assert(n == 1 and r == 1+2+3+4+5)
print('apply','All tests passed.')

----------------------------------------------------------------------
-- ZIP Unit tests
----------------------------------------------------------------------

local _, l1 = list(3,  'one', 'two', 'three')
local _, l2 = list(3,  1, 2, 3)
local _, l3 = list(6, 'odd', 'even', 'odd', 'even', 'odd', 'even')

local n,r = zip(3, l1, l2, l3)
assert(n == 1 and r:tostring() == '((one 1 odd) (two 2 even) (three 3 odd))')
local n,r = zip(1, l1)
assert(n == 1 and r:tostring() == '((one) (two) (three))')

print('zip','All tests passed.')

print( 1024 * ( collectgarbage('count') - memory) , 'bytes used')
