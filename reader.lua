--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

local cells = require 'cells'
local lexer = require 'lexer'

-- P: parser

local P = {}

P.read_next_token = function (parser)
  parser.token      = parser.next_token
  parser.next_token = parser.lexer:next_token()
  return parser.token
end

P.read = function (parser)
  local token = P.read_next_token(parser)
  if token == nil then
    P.add_error(parser, nil, 'Unexpected end of file')
    return nil
  elseif token.txt == '.' then
    P.add_error(parser, parser.token, 'Unexpected dot')
    return nil
  elseif token.txt == "'" then
    -- P.read_next_token(parser)
    local e, err = P.read(parser)
    if cells.is_nil(e) then 
      return nil
    elseif cells.is_atom(e) then
      return e
    else
      token.txt = 'quote'
      return cells.cons(token, cells.cons(e, nil))
    end
  elseif token.txt == '(' then
    return P.read_list(parser)
  else
    return token
  end
end


P.add_error = function (parser, token, text)
  if token == nil then
    table.insert(parser.errors, text)
  else
    table.insert(parser.errors, 
        string.format("%d:%d:%s", token.line, token.column, text))
  end
end

P.read_dotted_pair = function (parser, car)
  local cdr = P.read(parser)
  if cdr == nil then return nil end
  if parser.next_token.txt == ')' then
    P.read_next_token(parser)
    return cells.cons(car, cdr)
  else
    P.add_error(parser, parser.next_token, 'Malformed dotted pair')
    return nil
  end
end

P.read_after_car = function (parser, car)
  if car == nil then 
    return nil
  end

  if parser.next_token and parser.next_token.txt == '.' then
    P.read_next_token(parser)
    return P.read_dotted_pair(parser, car)
  end

  if parser.next_token and parser.next_token.txt == ')' then
    P.read_next_token(parser)
    return cells.cons(car)
  end

  local cdr = P.read_list(parser)
  if cdr == nil then return nil end
  return cells.cons(car, cdr)

end

P.read_list = function(parser)

  if parser.next_token and parser.next_token.txt == ')' then
    P.read_next_token(parser)
    return nil
  end

  local car = P.read(parser)

  return P.read_after_car(parser, car)
end

P.new = function (text)
  assert(text)
  local lexer      = lexer.new(text)
  local token      = nil
  local next_token = lexer:next_token()
  local parser     = {
    lexer      = lexer,
    token      = token,
    next_token = next_token,
    errors     = {},
  }
  return parser
end

-- R: reader

local R = {}

R.read = function(reader)
  assert(reader)
  assert(reader.parser)

  local cells  = {}
  local errors = {}

  while true do
    local cell = P.read(reader.parser)
    if #reader.parser.errors > 0 then
      table.insert(errors, table.concat(reader.parser.errors,'\n'))
      break
    else
      table.insert(cells, cell)
    end
    if reader.parser.next_token == nil then break end
  end
  if #errors > 0 then
    return nil, table.concat(errors, '\n')
  else
    return cells, nil
  end
end

R.new = function (text)
  return {
    parser = P.new(text),
    read   = R.read,
  }
end

return R
