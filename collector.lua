local collector = collector or {}

function collector.Collect(filepath)
 local function find_funcs_index_and_names(str)
  local t = {}                   -- table to store the indices
  local n= {}  --table to store the names.
  local i = 0
  while true do
    i, j = string.find(str, "function", i+1) -- find where " function namehere(" is at.
    if i == nil or j == nil then break end
    local e,l = string.find(str, "[(]", j+2)
    
    local quote = string.sub(str, j+ 1, e - 1)
    
    print(quote)
    table.insert(t, i)
    local ind = 0
    for _,v in ipairs(t) do
     if v == i then
      ind = _
     end
    end
    n[ind] = quote
  end
  return t, n
 end

 local function remove_local_funcs(str, index_table, name_table)
  for ind, val in pairs(index_table) do
   if string.sub(str, val - 6, val -1 ) == "local " then
    table.remove(index_table, ind)
    table.remove(name_table, ind)
   end
  end
  return index_table, name_table
 end

 local function setup_table(name_table)
  local ret_tbl = "return { "
  for ind,val in pairs(name_table) do
   local entry = val .. " = " .. val..", "
   ret_tbl = ret_tbl .. entry
  end
  ret_tbl = ret_tbl .. " }"
  return ret_tbl
 end

 local function get_file_contents(filepath)
  local fh = assert(io.open(filepath, 'rb'))
  local source = fh:read'*a'
  fh:close()
  return source
 end

 local function write_file_contents(filepath, contents)
  local fh = assert(io.open(filepath, 'a'))
  fh:write(contents)
  fh:close()
 end

 local function read_collect_and_write(filepath)
  local content = get_file_contents(filepath)
  local i,n = find_funcs_index_and_names(content)
  i,n = remove_local_funcs(content, i, n)
  local rt = setup_table(n)
  write_file_contents(filepath, rt)
 end

 read_collect_and_write(filepath)
end


return collector
