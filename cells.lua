--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

local M = {}

-- Index '1' is used for car
-- Index '2' is used for cdr
-- Index '3' is used for type (to distinguish between cells and other tables)

-- Returns true if c is nil
M.is_nil = function (c)
  return c == nil
end

-- Returns true if c is a cell (a table with [3] == 'cell')
M.is_cons = function (c)
  return c ~= nil and type(c) == 'table' and c[3] == 'cell'
end

-- Returns true if c is an atom (an object not nil and not a cell)
M.is_atom = function (c)
  return not M.is_nil(c) and not M.is_cons(c)
end

-- Returns true if c is a list (a cons or nil)
M.is_list = function (c)
  return M.is_nil(c) or (M.is_cons(c) and M.is_list(c[2]))
end

-- Checks for cycles and assigns numbers to them for later printing
local function compute_labels_for_cycles (c, visited, labels, next_label)
  if M.is_cons(c) then
    if visited[c] then
      if not labels[c] then
        labels[c] = next_label
        next_label = next_label + 1
      end
    else
      visited[c] = true
      next_label = compute_labels_for_cycles(c[1], visited, labels, next_label)
      next_label = compute_labels_for_cycles(c[2], visited, labels, next_label)
    end
  end
  return next_label
end

local function collect_tostring (c, visited, labels)
  if M.is_nil(c) then
    return '()'
  elseif M.is_atom(c) then
    return tostring(c)
  else
    -- An already visited cell
    if visited[c] then return '#' .. labels[c] .. '#' end
    -- Visit the cell and continue
    visited[c] = true
    -- A visited cell that has a label
    local s = labels[c] and '#' .. labels[c] .. '=(' or '('
    while true do
      s = s .. collect_tostring(c[1], visited, labels)
      c = c[2]
      if visited[c] then 
        s = s .. ' #' .. labels[c] .. '#)'
        break
      elseif M.is_nil(c) then
        s = s .. ')'
        break
      elseif M.is_atom(c) then
        s = s .. ' . ' .. tostring(c) .. ')'
        break
      else
        s = s .. ' '
      end
    end
    return s
  end
end

M.tostring = function (c)
  local visited = {}
  local labels  = {}
  local next_label = compute_labels_for_cycles(c, visited, labels, 1)
  return collect_tostring(c, {}, labels)
end

-- Quick & dirty print function, without cycles
M.tostring_old = function (c)
  if M.is_nil(c) then
    return '()'
  elseif M.is_atom(c) then
    return tostring(c)
  else
    local s = '('
    while true do
       s = s .. M.tostring(c[1])
       c = c[2]
       if M.is_nil(c) then
         s = s .. ')'
         break
       elseif M.is_atom(c) then
         s = s .. ' . ' .. M.tostring(c) .. ')'
         break
       else
         s = s .. ' '
       end
     end
     return s
  end
end

-- Miscellaneous functions
M.car    = function (c) return c[1] end
M.cdr    = function (c) return c[2] end
M.cadr   = function (c) return c[2][1] end
M.cdar   = function (c) return c[1][2] end
M.cddr   = function (c) return c[2][2] end
M.caddr  = function (c) return c[2][2][1] end
M.cdddr  = function (c) return c[2][2][2] end
M.cadddr = function (c) return c[2][2][2][1] end
M.cddddr = function (c) return c[2][2][2][2] end
M.set_car = function (c, car) c[1] = car end
M.set_cdr = function (c, cdr) c[2] = cdr end

-- Returns last in cell
M.last = function (c)
  while true do
    if c[2] == nil then
      return c[1]
    end
    c = c[2]
  end
end

-- Returns length
M.length = function (c)
  local len = 0
  while c ~= nil do
    len = len + 1
    c = c[2]
  end
  return len
end

-- Returns nth
M.nth = function (c, n)
  while n > 1 do
    n = n - 1
    c = c[2]
  end
  return c[1]
end

-- Appends two cons cells
M.append = function (a, b)
  local clone_conses = function (l)
    if l == nil then
      return nil, nil
    else
      local first = M.cons(a[1], nil)
      local previous = first
      l = l[2]
      while true do
        if l == nil then
          last = previous
          previous[2] = nil
          return first, last
        else
          local c = M.cons(l[1], nil)
          previous[2] = c
          previous = c
          l = l[2]
        end
      end
    end
  end
  if a == nil then
    return b
  else
    local clone, last = clone_conses(a)
    last[2] = a == nil and nil or b
    return clone
  end
end

-- map
M.map = function(n, proc, ...)
  assert(proc and type(proc) == 'function')
  assert(n and type(n) == 'number')
  local lists = {...}
  assert(lists and #lists >= 1)
  for i=1,n do
    if M.is_nil(lists[i]) then return 1, nil end
  end
  for i=1,n do
    if not M.is_list(lists[i]) then 
      return nil, 'Map requires arguments being lists, but element ' .. i .. '[' .. lists[i] .. '] is not a list'
    end
  end
  local function map_rec (proc, n, lists)
    assert(proc and type(proc) == 'function')
    assert(n and type(n) == 'number')
    local cars = {}
    for i=1,n do
      local car = lists[i][1] -- M.car(lists[i])
      if M.is_nil(car) then return 1, nil end
      table.insert(cars, car)
    end
    local _, cars = proc(n, unpack(cars))
    local cdrs = {}
    for i=1,n do
      local cdr = lists[i][2] -- M.cdr(lists[i])
      if M.is_nil(cdr) then return 1, M.cons(cars, nil) end
      table.insert(cdrs, cdr)
    end
    local _, cdrs = map_rec(proc, n, cdrs)
    return 1, M.cons(cars, cdrs)
  end
  return map_rec(proc, n, lists)
end

-- apply
M.apply = function(n, proc, ...)
  assert(n and type(n) == 'number' and n > 0, "Expected number of varargs for apply, but got " .. tostring(n))
  assert(proc and type(proc) == 'function', "Expected a procedure for apply, but got " .. tostring(proc))
  local elements = {}
  local args = {...}
  local m = 0
  for i=1,n do
    local arg = args[i]
    if i == n then
      if not M.is_list(arg) then return nil, 'Apply requires a list as a last argument, but got ' .. tostring(arg) end
      local arg_len  = M.length(arg)
      for j=1,arg_len do
        local e = M.nth(arg, j)
        table.insert(elements, e)
        m = m + 1
      end
    else
      table.insert(elements, arg)
      m = m + 1
    end
  end
  return proc(m, unpack(elements))
end

-- (define (zip list1 . more-lists) (apply map list list1 more-lists))
M.zip = function (n, ...)
  local args = {...}
  return M.map(n, M.list, unpack(args))
end

-- fallback __index table
local cell_methods = {
      is_cons   = M.is_cons,
      is_nil    = M.is_nil,
      is_atom   = M.is_atom,

      car       = M.car,
      cdr       = M.cdr,
      cadr      = M.cadr,
      cddr      = M.cddr,
      cdar      = M.cdar,
      caddr     = M.caddr,
      cdddr     = M.cdddr,
      cadddr    = M.cadddr,
      cddddr    = M.cddddr,

      last      = M.last,
      length    = M.length,
      nth       = M.nth,

      set_car   = M.set_car,
      set_cdr   = M.set_cdr,

      apply     = M.apply,
      map       = M.map,
      zip       = M.zip,

      tostring  = M.tostring,
}

local cell_metatable = {
  __tostring = M.tostring,
  __index    = cell_methods,
}

-- Creates a new cell with (car, cdr)
M.cons = function (car, cdr)
  local cons_cell = {
    [1] = car,
    [2] = cdr,
    [3] = 'cell'
  }
  return setmetatable(cons_cell, cell_metatable);
end

-- Creates a list with a variable number of arguments
-- Returns 1, list
M.list = function (n, ...)
  assert(type(n)=='number')
  local args = {...}
  local cell = nil
  for i=n,1,-1 do
    cell = M.cons(args[i], cell)
  end
  return 1, cell
end


return M
