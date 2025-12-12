local Rect = {}
Rect.__index = Rect

function Rect:from_opposite_corners(corner_a, corner_b)
  local min_x = math.min(corner_a.x, corner_b.x)
  local max_x = math.max(corner_a.x, corner_b.x)
  local min_y = math.min(corner_a.y, corner_b.y)
  local max_y = math.max(corner_a.y, corner_b.y)

  local width = max_x - min_x + 1
  local height = max_y - min_y + 1
  local area = width * height

  local rect = { area = area }
  setmetatable(rect, self)
  return rect
end

local function parse_input(input_path)
  local nodes = {}
  for line in io.lines(input_path) do
    local x, y = line:match("^(%d+),(%d+)$")
    table.insert(nodes, { x = tonumber(x), y = tonumber(y) })
  end
  return nodes
end


local function all_sorted_rects(nodes)
  local rects = {}
  for i = 1, #nodes do
    local node_a = nodes[i]
    for j = i, #nodes do
      local node_b = nodes[j]
      table.insert(rects, Rect:from_opposite_corners(node_a, node_b))
    end
  end
  table.sort(rects, function(a, b) return a.area > b.area end)
  return rects
end

local function part1(input_path)
  local nodes = parse_input(input_path)
  local sorted_rects = all_sorted_rects(nodes)
  return sorted_rects[1].area
end

local function part2(input_path)
end

assert(part1("./day9/example-input.txt") == 50)
assert(part1("./day9/input.txt") == 4781235324)
-- assert(part2("./day9/example-input.txt") == 24)
