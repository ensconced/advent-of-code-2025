local function parse_input(input_path)
  local grid = {}
  for line in io.lines(input_path) do
    local row = {}
    for i = 1, #line do
      row[i] = line:sub(i, i)
    end
    table.insert(grid, row)
  end
  return grid
end


local function part1(input_path)
  local grid = parse_input(input_path)

  local total = 0
  for i = 2, #grid do
    local prev_row = grid[i - 1]
    local row = grid[i]

    for j = 1, #row do
      local above = prev_row[j]
      local here = row[j]
      if above == "S" or above == "|" then
        if here == "^" then
          if j - 1 > 0 then
            row[j - 1] = "|"
          end
          if j + 1 <= #row then
            row[j + 1] = "|"
          end
          total = total + 1
        else
          row[j] = "|"
        end
      end
    end
  end
  return total
end

assert(part1("./day7/example-input.txt") == 21)
assert(part1("./day7/input.txt") == 1605)
