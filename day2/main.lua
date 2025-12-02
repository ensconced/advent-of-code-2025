local function part1(input_path)
  local file = assert(io.open(input_path, "r"))
  local input = file:read()

  local sum = 0
  for first, last in input:gmatch("(%d+)-(%d+)") do
    for i = tonumber(first), tonumber(last) do
      local invalid = tostring(i):match("^(.*)%1$")
      if invalid then
        sum = sum + i
      end
    end
  end

  file:close()
  return sum
end



local function part2(input_path)
  local function is_repeat_of(unit, str)
    return str == unit:rep(str:len() // unit:len())
  end

  local function is_invalid(str)
    for i = 1, #str // 2 do
      if is_repeat_of(str:sub(1, i), str) then
        return true
      end
    end
    return false
  end

  local file = assert(io.open(input_path, "r"))
  local input = file:read()

  local sum = 0
  for first, last in input:gmatch("(%d+)-(%d+)") do
    for i = tonumber(first), tonumber(last) do
      if is_invalid(tostring(i)) then
        sum = sum + i
      end
    end
  end

  file:close()
  return sum
end


assert(part1("./day2/example-input.txt") == 1227775554)
assert(part1("./day2/input.txt") == 18700015741)
assert(part2("./day2/example-input.txt") == 4174379265)
assert(part2("./day2/input.txt") == 20077272987)
