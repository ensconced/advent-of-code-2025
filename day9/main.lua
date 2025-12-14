local function find_middle(list)
  return list[#list // 2 + 1]
end

local InclusiveRange = {}
InclusiveRange.__index = InclusiveRange

function InclusiveRange:new(lower, upper)
  local range = { lower = lower, upper = upper }
  setmetatable(range, InclusiveRange)
  return range
end

function InclusiveRange:contains(x)
  return x >= self.lower and x <= self.upper
end

function InclusiveRange:intersects(other_range)
  return other_range.upper >= self.lower and other_range.lower <= self.upper
end

local RectTree = {}
RectTree.__index = RectTree

function RectTree:new(rect, horizontal_splitters, vertical_splitters)
  local rect_tree = nil
  local splitter = rect:pick_best_splitter(horizontal_splitters, vertical_splitters)

  if splitter then
    local child_a, child_b = rect:split(splitter)
    local horizontal_splitters_for_child_a = child_a:intersecting_horizontal_splitters(horizontal_splitters)
    local vertical_splitters_for_child_a = child_a:intersecting_vertical_splitters(vertical_splitters)
    local horizontal_splitters_for_child_b = child_b:intersecting_horizontal_splitters(horizontal_splitters)
    local vertical_splitters_for_child_b = child_b:intersecting_vertical_splitters(vertical_splitters)

    local child_a_tree = RectTree:new(child_a, horizontal_splitters_for_child_a, vertical_splitters_for_child_a)
    local child_b_tree = RectTree:new(child_b, horizontal_splitters_for_child_b, vertical_splitters_for_child_b)

    rect_tree = { rect = rect, children = { child_a_tree, child_b_tree } }
  else
    -- We have found a leaf rect
    rect_tree = { rect = rect, children = nil }
  end
  setmetatable(rect_tree, RectTree)
  return rect_tree
end

local Rect = {}
Rect.__index = Rect

function Rect:from_bounds(min_x, max_x, min_y, max_y)
  local width = max_x - min_x + 1
  local height = max_y - min_y + 1
  local area = width * height

  local rect = {
    area = area,
    width = width,
    height = height,
    x = InclusiveRange:new(min_x, max_x),
    y = InclusiveRange:new(min_y, max_y)
  }
  setmetatable(rect, self)
  return rect
end

function Rect:from_opposite_corners(corner_a, corner_b)
  local min_x = math.min(corner_a.x, corner_b.x)
  local max_x = math.max(corner_a.x, corner_b.x)
  local min_y = math.min(corner_a.y, corner_b.y)
  local max_y = math.max(corner_a.y, corner_b.y)

  return self:from_bounds(min_x, max_x, min_y, max_y)
end

function Rect:split(splitter)
  if splitter.dir == "U" or splitter.dir == "D" then
    local left = Rect:from_bounds(self.x.lower, splitter.x, self.y.lower, self.y.upper)
    local right = Rect:from_bounds(splitter.x + 1, self.x.upper, self.y.lower, self.y.upper)

    left.is_outside = splitter.dir == "U"
    right.is_outside = not left.is_outside
    return left, right
  else
    local top = Rect:from_bounds(self.x.lower, self.x.upper, self.y.lower, splitter.y)
    local bottom = Rect:from_bounds(self.x.lower, self.x.upper, splitter.y + 1, self.y.upper)

    top.is_outside = splitter.dir == "R"
    bottom.is_outside = not top.is_outside
    return top, bottom
  end
end

function Rect:intersecting_horizontal_splitters(splitters)
  local intersecting = {}
  for _, splitter in pairs(splitters) do
    local rect_range_x = InclusiveRange:new(self.x.lower, self.x.upper - 1)
    local rect_range_y = InclusiveRange:new(self.y.lower, self.y.upper - 1)
    if rect_range_y:contains(splitter.y) and rect_range_x:intersects(splitter.x) then
      table.insert(intersecting, splitter)
    end
  end
  return intersecting
end

function Rect:intersecting_vertical_splitters(splitters)
  local intersecting = {}
  for _, splitter in pairs(splitters) do
    local rect_range_x = InclusiveRange:new(self.x.lower, self.x.upper - 1)
    local rect_range_y = InclusiveRange:new(self.y.lower, self.y.upper - 1)
    if rect_range_x:contains(splitter.x) and rect_range_y:intersects(splitter.y) then
      table.insert(intersecting, splitter)
    end
  end
  return intersecting
end

function Rect:pick_best_splitter(horizontal_splitters, vertical_splitters)
  local wide = self.width > self.height
  return find_middle(wide and vertical_splitters or horizontal_splitters) or
      find_middle(wide and horizontal_splitters or vertical_splitters)
end

function Rect:intersects(other_rect)
  return self.x:intersects(other_rect.x) and self.y:intersects(other_rect.y)
end

function Rect:intersects_any_outside_rect(rect_tree)
  if self:intersects(rect_tree.rect) then
    if rect_tree.children == nil then
      return rect_tree.rect.is_outside
    end
    return self:intersects_any_outside_rect(rect_tree.children[1]) or
        self:intersects_any_outside_rect(rect_tree.children[2])
  end
  return false
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

local function get_splitters(nodes)
  -- We are assuming that the node path is always given in the clockwise order - it is for both examples
  local horizontal_splitters = {}
  local vertical_splitters = {}
  for i, current in pairs(nodes) do
    local next = i == #nodes and nodes[1] or nodes[i + 1]
    if next.x > current.x then
      table.insert(horizontal_splitters, { dir = "R", y = current.y - 1, x = InclusiveRange:new(current.x, next.x - 1) })
    elseif current.x > next.x then
      table.insert(horizontal_splitters, { dir = "L", y = current.y, x = InclusiveRange:new(next.x, current.x - 1) })
    elseif current.y > next.y then
      table.insert(vertical_splitters, { dir = "U", x = current.x - 1, y = InclusiveRange:new(next.y, current.y - 1) })
    else
      table.insert(vertical_splitters, { dir = "D", x = current.x, y = InclusiveRange:new(current.y, next.y - 1) })
    end
  end
  table.sort(horizontal_splitters, function(a, b) return a.y < b.y end)
  table.sort(vertical_splitters, function(a, b) return a.x < b.x end)
  return horizontal_splitters, vertical_splitters
end

local function get_node_bounds(nodes)
  local min_x = math.maxinteger
  local max_x = 0
  local min_y = math.maxinteger
  local max_y = 0

  for _, node in pairs(nodes) do
    min_x = math.min(min_x, node.x)
    max_x = math.max(max_x, node.x)
    min_y = math.min(min_y, node.y)
    max_y = math.max(max_y, node.y)
  end

  return { min_x = min_x, max_x = max_x, min_y = min_y, max_y = max_y }
end

local function part1(input_path)
  local nodes = parse_input(input_path)
  local sorted_rects = all_sorted_rects(nodes)
  return sorted_rects[1].area
end

local function part2(input_path)
  local nodes = parse_input(input_path)
  local horizontal_splitters, vertical_splitters = get_splitters(nodes)
  local node_bounds = get_node_bounds(nodes)
  local world_rect = Rect:from_bounds(node_bounds.min_x, node_bounds.max_x, node_bounds.min_y, node_bounds.max_y)
  local rect_tree = RectTree:new(world_rect, horizontal_splitters, vertical_splitters)
  local sorted_rects = all_sorted_rects(nodes)
  for _, rect in pairs(sorted_rects) do
    if not rect:intersects_any_outside_rect(rect_tree) then
      return rect.area
    end
  end
end

assert(part1("./day9/example-input.txt") == 50)
assert(part1("./day9/input.txt") == 4781235324)
assert(part2("./day9/example-input.txt") == 24)
assert(part2("./day9/input.txt") == 1566935900)
