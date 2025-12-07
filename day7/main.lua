local function parse_input(input_path)
  local grid = { rows = {} }
  for line in io.lines(input_path) do
    local row = {}
    for i = 1, #line do
      row[i] = line:sub(i, i)
    end
    table.insert(grid.rows, row)
    grid.width = #row
  end
  return grid
end


local function part1(input_path)
  local grid = parse_input(input_path)

  local total = 0
  for i = 2, #grid.rows do
    local prev_row = grid.rows[i - 1]
    local row = grid.rows[i]

    for j = 1, grid.width do
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

local function find_start(grid)
  for i = 1, #grid.rows do
    local row = grid.rows[i]
    for j = 1, grid.width do
      if row[j] == "S" then
        return i, j
      end
    end
  end
  error("failed to find start")
end

local function part2(input_path)
  local cache = {}

  local function count_paths_from(grid, row_idx, col_idx)
    local cache_key = (row_idx << 16) | col_idx
    local cached_result = cache[cache_key]
    if cached_result then
      return cached_result
    end

    local result = nil
    if col_idx < 1 or col_idx > grid.width then
      result = 0
    elseif grid.rows[row_idx][col_idx] == "^" then
      result = count_paths_from(grid, row_idx, col_idx - 1) + count_paths_from(grid, row_idx, col_idx + 1)
    elseif row_idx == #grid.rows then
      result = 1
    else
      result = count_paths_from(grid, row_idx + 1, col_idx)
    end

    cache[cache_key] = result
    return result
  end


  local grid = parse_input(input_path)
  local start_row, start_col = find_start(grid)
  return count_paths_from(grid, start_row, start_col)
end

assert(part1("./day7/example-input.txt") == 21)
assert(part1("./day7/input.txt") == 1605)
assert(part2("./day7/example-input.txt") == 40)
assert(part2("./day7/input.txt") == 29893386035180)
