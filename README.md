## S-Expressions in Lua

### Manipulating S-Expressions

See [cells.lua](cells.lua)

```lua
local cells = require 'cells'

local cons = cells.cons
local car  = cells.car
local cadr = cells.cadr
local cddr = cells.cddr
local list = cells.list
-- etc.

local _, c = list(3, 'A', 'B', 'C')
print(c)       -- (A B C)
print(car(c))  -- A
print(cadr(c)) -- B
print(cddr(c)) -- (C)
```

### Reading S-Expresions

```lua
local reader = require 'reader'

local r = reader.new('(A    (B    "string"    -123.456    (C . D))) (x y)')
local c, errors = r:read()

print(#c)   -- 2
print(c[1]) -- (A (B "string" -123.456 (C . D))
print(c[2]) -- (x y)
```

See [reader.lua](reader.lua)

### More examples

See [test.lua](test.lua) for examples on how to do reading and for examples of use of 'map', 'zip' and 'apply'.

### Features

* 2014-01-23: list, map, apply, zip. Since Lua does not handle [varargs properly](http://lua-users.org/wiki/VarargTheSecondClassCitizen)
adding an integer as companion to all varargs '{...}' and as result to all 'return' clauses.

* 2014-01-21: reads quoted strings, parses some Scheme source code

* 2014-01-20: cons, cdr, car, set-car, set-cdr et al [cells.lua](cells.lua).
* 2014-01-20: prints cells with cycles
* 2014-01-20: a reader with line/column debugging info [reader.lua](reader.lua)
* 2014-01-20: The [in_c](in_c) directory keeps an old C version that does not handle cycles properly (GC), but it's still kept there for historical reasons.
