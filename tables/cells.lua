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
        s = s .. '.' .. tostring(c) .. ')'
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

-- fallback __index table
local cell_methods = {
      is_cons   = M.is_cons,
      is_nil    = M.is_nil,
      is_atom   = M.is_atom,

      car       = M.car,
      cdr       = M.cdr,
      cadr      = M.cadr,
      cddr      = M.cddr,
      caddr     = M.caddr,
      cdddr     = M.cdddr,
      cadddr    = M.cadddr,
      cddddr    = M.cddddr,

      last      = M.last,
      length    = M.length,
      nth       = M.nth,

      set_car   = M.set_car,
      set_cdr   = M.set_cdr,

      tostring  = M.tostring,
}

local cell_metatable = {
  __tostring = M.tostring,
  __index    = cell_methods,
}


-- Creates a new cell with (car, cdr)
M.cons = function (car, cdr)
  if car == nil and cdr == nil then return nil end
  local cons_cell = {
    [1] = car,
    [2] = cdr,
    [3] = 'cell'
  }
  return setmetatable(cons_cell, cell_metatable);
end

return M
