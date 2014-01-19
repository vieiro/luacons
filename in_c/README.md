* Lua cons-cells in C

This implementation uses a C structure to build cons-cells,
the structure then keeps references to Lua objects.

This implementation does not handle cycles properly.

