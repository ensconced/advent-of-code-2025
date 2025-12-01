local function part1(input_path)
  local position = 50
  local zeroes = 0

  for line in io.lines(input_path) do
    local direction, rest = line:match("^(.)(.*)$")
    local distance = tonumber(rest)

    if direction == "R" then
      position = position + distance
    else
      position = position - distance
    end
    position = position % 100
    if position == 0 then
      zeroes = zeroes + 1
    end
  end

  return zeroes
end

local function part2(input_path)
  local position = 50
  local zeroes = 0

  for line in io.lines(input_path) do
    local direction, rest = line:match("^(.)(.*)$")
    local distance = tonumber(rest)
    local delta = direction == "R" and 1 or -1

    for _ = 1, distance do
      position = (position + delta) % 100
      if position == 0 then
        zeroes = zeroes + 1
      end
    end
  end

  return zeroes
end

local function assert_result(part, input_path, expected)
  local fn = part == "1" and part1 or part2
  assert(
    fn(input_path) == expected,
    string.format("part %s: expected %d for input: %s", part, expected, input_path)
  )
end

assert_result("1", "./day1/example-input.txt", 3)
assert_result("1", "./day1/input.txt", 995)
assert_result("2", "./day1/example-input.txt", 6)
assert_result("2", "./day1/input.txt", 5847)
