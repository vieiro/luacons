--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

local M = {}

M.is_atom = function (c)
  return c ~= nil and c._t == nil
end

M.is_nil = function (c)
  return c == nil
end

M.is_cons = function (c)
  return c ~= nil and c._t == 'cell'
end

M.tostring = function (c)
  if M.is_nil(c) then
    return '()'
  elseif M.is_atom(c) then
    return tostring(c)
  else
    local s = '('
    while true do
       s = s .. M.tostring(c._car)
       c = c._cdr
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

M.car    = function (c) return c._car end
M.cdr    = function (c) return c._cdr end
M.cadr   = function (c) return c._cdr._car end
M.cddr   = function (c) return c._cdr._cdr end
M.caddr  = function (c) return c._cdr._cdr._car end
M.cdddr  = function (c) return c._cdr._cdr._cdr end
M.cadddr = function (c) return c._cdr._cdr._cdr._car end
M.cddddr = function (c) return c._cdr._cdr._cdr._cdr end

M.last = function (c)
  while true do
    if c._cdr == nil then
      return c._car
    end
    c = c._cdr
  end
end

M.length = function (c)
  local len = 0
  while c ~= nil do
    len = len + 1
    c = c._cdr
  end
  return len
end

M.nth = function (c, n)
  while n > 1 do
    n = n - 1
    c = c._cdr
  end
  return c._car
end

M.append = function (a, b)
  local clone_conses = function (l)
    if l == nil then
      return nil, nil
    else
      local first = M.cons(a._car, nil)
      local previous = first
      l = l._cdr
      while true do
        if l == nil then
          last = previous
          previous._cdr = nil
          return first, last
        else
          local c = M.cons(l._car, nil)
          previous._cdr = c
          previous = c
          l = l._cdr
        end
      end
    end
  end
  if a == nil then
    return b
  else
    local clone, last = clone_conses(a)
    last._cdr = a == nil and nil or b
    return clone
  end
end

local cell_metatable = {
  __tostring = M.tostring,
}

M.cons = function (...)
  local arg = {...}
  local c = setmetatable({
      _t        = 'cell',
      _car      = arg[1],
      _cdr      = arg[2],
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
      }, cell_metatable);
  return c
end

return M
