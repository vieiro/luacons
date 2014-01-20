--
-- cons cells using Lua tables
--
-- (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
-- MIT License
--

-- L : Lexer

local L = {}

local update_linecount = function(lexer, start_index, end_index)
  for i = start_index, end_index do
    if lexer.txt:byte(i) == 10 then
      lexer.line = lexer.line + 1
      lexer.column = 1
    else
      lexer.column = lexer.column + 1
    end
  end
end

-- skips whitespace
local skip_whitespace_and_comments = function (lexer)
  local start_index = lexer.index
  while true do
    -- EOF
    if lexer.index > lexer.len then return end
    -- Find whitespace
    local s,e = lexer.txt:find('^%s+', lexer.index)
    if s then
      lexer.index = e + 1
      update_linecount(lexer, s, e)
    end
    -- EOF
    if lexer.index > lexer.len then return end
    -- Find comments
    local s,e = lexer.txt:find('^;[^\n]+[\n]', lexer.index)
    if s then
      lexer.index = e + 1
      update_linecount(lexer, s, e)
    end
    -- EOF
    if lexer.index > lexer.len then return end
    -- Any advances?
    if lexer.index == start_index then return end
    start_index = lexer.index
  end
end

local TOKEN_METATABLE = {
  -- __tostring = function (token) return string.format('"%s"@(%d,%d)', token.txt, token.line, token.column) end
  __tostring = function (token) return token.txt end
}

local create_token = function (lexer, s, e)
  local token = {
    txt    = lexer.txt:sub(s, e),
    line   = lexer.line,
    column = lexer.column,
  }
  lexer.index = e + 1
  update_linecount(lexer, s, e)
  return setmetatable(token, TOKEN_METATABLE)
end

local consume_quoted_string = function(lexer)
  local start = lexer.index
  while true do
    lexer.index = lexer.index + 1
    local s,e = lexer.txt:find('^[^"]+"', lexer.index)
    if s then 
      if lexer.txt:sub(e-1,e-1) ~= '\\' then
        return create_token(lexer, start, e)
      else
        lexer.index = e+1
      end
    else
      error('Unfinished string')
    end
  end
end

L.next_token = function (lexer)
  -- if EOF return nil
  if lexer.index > lexer.len then return nil end

  -- skip whitespace
  skip_whitespace_and_comments(lexer)

  -- if EOF return nil
  if lexer.index > lexer.len then return nil end

  -- Find next token
  local c = lexer.txt:sub(lexer.index, lexer.index)
  if     c == '(' then return create_token(lexer, lexer.index, lexer.index)
  elseif c == ')' then return create_token(lexer, lexer.index, lexer.index)
  elseif c == "'" then return create_token(lexer, lexer.index, lexer.index)
  elseif c == '"' then return consume_quoted_string(lexer) 
  else
    -- Strings
    -- Numbers (1)
    local s, e = lexer.txt:find('^[+-]?%d+%.%d*', lexer.index)
    if s then return create_token(lexer, s, e) end
    -- Numbers (2)
    local s, e = lexer.txt:find('^[+-]?%.%d+', lexer.index)
    if s then return create_token(lexer, s, e) end
    -- Dot
    if c == '.' then return create_token(lexer, lexer.index, lexer.index) end
    -- Non whitespace nor comment
    local s, e = lexer.txt:find('^[^%s().;]+', lexer.index)
    if s then return create_token(lexer, s, e) end
  end
end

L.tostring = function (lexer)
  return string.format('[LEXER index %d line %d column %d char "%s"]',
      lexer.index,
      lexer.line,
      lexer.column,
      lexer.index > lexer.len and 'EOF' or lexer.txt:sub(lexer.index, lexer.index))
end

local LEXER_METATABLE = {
  __tostring = L.tostring,
}

L.new = function (text)
  assert(text)
  local lexer = {
    txt        = text,
    index      = 1,
    len        = text:len(),
    line       = 1,
    column     = 1,
    next_token = L.next_token,
  }
  return setmetatable(lexer, LEXER_METATABLE)
end

return L
