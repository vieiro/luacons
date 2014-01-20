## S-Expressions in Lua

### Manipulating S-Expressions

See [cells.lua](cells.lua)

   local cells = require 'cells'

   local cons = cells.cons
   local car  = cells.car
   local list = cells.list
   -- etc.

   local c = list('A', 'B', 'C')
   print(c) -- (A B C)
   print(car(c)) -- A


### Reading S-Expresions

   local reader = require 'reader'

   local r = reader.new('(A    (B    "string"    -123.456    (C . D))) (x y)')
   local c, errors = r:read()

   print(c[1]) -- (A (B "string" -123.456 (C . D))
   print(c[2]) -- (x y)

See [reader.lua](reader.lua)

### More examples

See [test.lua](test.lua) for examples on how to use it (unit tests).

### Features

* 2014-01-20: cons, cdr, car, set-car, set-cdr et al [cells.lua](cells.lua).
* 2014-01-20: prints cells with cycles
* 2014-01-20: a reader with line/column debugging info [reader.lua](reader.lua)
* 2014-01-20: The [in_c](in_c) directory keeps an old C version that does not handle cycles properly (GC), but it's still kept there for historical reasons.
