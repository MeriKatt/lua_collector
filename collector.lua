local collector = collector or {}

function collector.Collect(filepath)
 local function find_globals(str)
  local words = {}
  local cur_depth = 0
  local function split_string(String)
    local seperater = "%s"
    local t = {}
    local i = 0
    for str in string.gmatch(String, "([^"..seperater.."]+)") do
      t[i] = str
      i = i + 1
    end
    return t
  end
  local function get_next(str, i)
    return str[i + 1]
  end
  local all_words = split_string(str)
  local prev_is_local = false
  for i,w in ipairs(all_words) do -- Get global functions and variables.
      prev_is_local = (all_words[i - 1] == "local")
      if not prev_is_local then
        if (w == "function") and (cur_depth == 0) then
          table.insert(words, get_next(all_words, i))
          cur_depth = cur_depth + 1
        end
        if w == "end" then
          cur_depth = cur_depth - 1
        end
        if (get_next(all_words, i) == "=") and (cur_depth == 0) then
          table.insert(words, w)
        end
        if w == "return" and cur_depth == 0 then
          break
        end
      else
        if (w == "function") then
          cur_depth = cur_depth + 1
        end
      end

  end
  return words
 end

 local function setup_table(name_table, content)
  local function test_is_there(content, table)
   if string.match(content,table) then
    return "y"
   else
    return "n"
   end
  end

  local ret_tbl = "\nreturn { "
  
  local middle = ""
  local matches = "n"
  for ind,val in ipairs(name_table) do
    print(#name_table)
   local entry = val.. " = " .. val..", "
   middle = middle .. entry
   matches = test_is_there(content, middle)
   print(matches)
  end
  if matches == "y" then return " " end
  ret_tbl = ret_tbl .. middle ..  " }"
  return ret_tbl
 end

 local function get_file_contents(filepath)
  local fh = assert(io.open(filepath, 'rb'))
  local source = fh:read'*a'
  fh:close()
  return source
 end

 local function write_file_contents(filepath, contents, table ,eofFile )
  if table == " " then return end -- no need to update or write since its already there.
  local str = string.sub(contents, 0, eofFile)
  str = str .. table
  local fh = assert(io.open(filepath, 'wb'))
  fh:write(str)
  fh:close()
 end

 local function read_collect_and_write(filepath)
  --print(filepath)
  local content = get_file_contents(filepath)
  local n = find_globals(content)
  local rt = setup_table(n, content)
  -- get the last end
  local t = {} -- table to store the indices
  local i = 0
  while true do
    i = string.find(content, "end", i+1) 
    if i == nil then break end
    table.insert(t, i)
  end
  -- now that we have the last end we want to get the index right after it :)
  local last = #t
  if t[last] == nil then return end
  write_file_contents(filepath, content, rt, t[last] + 3)
 end

 read_collect_and_write(filepath)
end


return collector
