## cons-cells in Lua using tables

This module implements cons-cells using Lua tables.

See [test.lua](test.lua) for examples on how to use it.

### Features

* 2014-01-20: cons, cdr, car, set-car, set-cdr et al [cells.lua](cells.lua).
* 2014-01-20: prints cells with cycles
* 2014-01-20: a reader with line/column debugging info [reader.lua](reader.lua)
* 2014-01-20: The [in_c](in_c) directory keeps an old C version that does not handle cycles properly (GC), but it's still kept there for historical reasons.
