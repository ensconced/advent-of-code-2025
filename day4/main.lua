local function parse_input(input_path)
  local rows = {}
  local width = 0
  local height = 0
  for line in io.lines(input_path) do
    width = #line
    height = height + 1
    local row = {}
    for ch in line:gmatch(".") do
      table.insert(row, ch)
    end
    table.insert(rows, row)
  end
  return { width = width, height = height, rows = rows, }
end

local function adjacency_count(parsed, i, j)
  local result = 0
  for delta_x = -1, 1 do
    for delta_y = -1, 1 do
      if (not (delta_x == 0 and delta_y == 0)) then
        local y = i + delta_y
        local x = j + delta_x
        if (x > 0 and x <= parsed.width) and (y > 0 and y <= parsed.height) and (parsed.rows[y][x] == "@") then
          result = result + 1
        end
      end
    end
  end
  return result
end

local function part1(input_path)
  local parsed = parse_input(input_path)
  local sum = 0
  for i = 1, parsed.height do
    for j = 1, parsed.width do
      if parsed.rows[i][j] == "@" and adjacency_count(parsed, i, j) < 4 then
        sum = sum + 1
      end
    end
  end
  return sum
end

local function part2(input_path)
  local parsed = parse_input(input_path)
  local total_sum = 0
  repeat
    local round_sum = 0
    for i = 1, parsed.height do
      for j = 1, parsed.width do
        if parsed.rows[i][j] == "@" and adjacency_count(parsed, i, j) < 4 then
          parsed.rows[i][j] = "."
          round_sum = round_sum + 1
        end
      end
    end
    total_sum = total_sum + round_sum
  until round_sum == 0
  return total_sum
end


assert(part1("./day4/example-input.txt") == 13)
assert(part1("./day4/input.txt") == 1537)
assert(part2("./day4/example-input.txt") == 43)
assert(part2("./day4/input.txt") == 8707)
