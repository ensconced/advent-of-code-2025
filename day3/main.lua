local function max_joltage(line, digit_count)
  local next_available_index = 1
  local result = ""

  local function pick_next_digit()
    local max_digit = nil
    local max_digit_index = nil
    for i = next_available_index, #line - (digit_count - #result - 1) do
      local digit = line:sub(i, i)
      if not max_digit or digit > max_digit then
        max_digit = digit
        max_digit_index = i
      end
    end
    next_available_index = max_digit_index + 1
    return max_digit
  end

  for _ = 1, digit_count do
    result = result .. pick_next_digit()
  end

  return tonumber(result)
end

local function part1(input_path)
  local sum = 0
  for line in io.lines(input_path) do
    sum = sum + max_joltage(line, 2)
  end
  return sum
end

local function part2(input_path)
  local sum = 0
  for line in io.lines(input_path) do
    sum = sum + max_joltage(line, 12)
  end
  return sum
end

assert(part1("./day3/example-input.txt") == 357)
assert(part1("./day3/input.txt") == 17179)
assert(part2("./day3/example-input.txt") == 3121910778619)
assert(part2("./day3/input.txt") == 170025781683941)
