local Rect = {}
Rect.__index = Rect

function Rect:from_bounds(min_x, max_x, min_y, max_y)
  local width = max_x - min_x + 1
  local height = max_y - min_y + 1
  local area = width * height

  local rect = { min_x = min_x, max_x = max_x, min_y = min_y, max_y = max_y, area = area }
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
  if splitter.type == "vertical" then
    local left = Rect:from_bounds(self.min_x, splitter.x, self.min_y, self.max_y)
    local right = Rect:from_bounds(splitter.x + 1, self.max_x, self.min_y, self.max_y)

    left.is_outside = splitter.origin_direction == "D"
    right.is_outside = not left.is_outside
    return left, right
  else
    local top = Rect:from_bounds(self.min_x, self.max_x, self.min_y, splitter.y)
    local bottom = Rect:from_bounds(self.min_x, self.max_x, splitter.y + 1, self.max_y)

    top.is_outside = splitter.origin_direction == "L"
    bottom.is_outside = not top.is_outside
    return top, bottom
  end
end

function Rect:intersecting_horizontal_splitters(splitters)
  error("todo")
end

function Rect:intersecting_vertical_splitters(splitters)
  error("todo")
end

local function find_middle(list)
  error("todo")
end

function Rect:pick_best_splitter(horizontal_splitters, vertical_splitters)
  local splitter = nil
  local wide = self.width > self.height
  if wide then
    splitter = find_middle(vertical_splitters)
  else
    splitter = find_middle(horizontal_splitters)
  end

  if not splitter then
    if wide then
      splitter = find_middle(horizontal_splitters)
    else
      splitter = find_middle(vertical_splitters)
    end
  end

  return splitter
end

function Rect:find_outside_parts(all_horizontal_splitters, all_vertical_splitters)
  local leaves = {}

  local function split_recursively(rect, horizontal_splitters, vertical_splitters)
    local splitter = rect:pick_best_splitter(horizontal_splitters, vertical_splitters)
    if splitter then
      local part_a, part_b = rect:split(splitter)
      split_recursively(part_a, part_a:intersecting_horizontal_splitters(horizontal_splitters),
        part_a:intersecting_vertical_splitters(vertical_splitters))
      split_recursively(part_b, part_b:intersecting_horizontal_splitters(horizontal_splitters),
        part_b:intersecting_vertical_splitters(vertical_splitters))
    else
      table.insert(leaves, rect)
    end
  end

  split_recursively(self, all_horizontal_splitters, all_vertical_splitters)

  local outside_leaves = {}
  for _, leaf_rect in pairs(leaves) do
    if leaf_rect.is_outside then
      table.insert(outside_leaves, leaf_rect)
    end
  end

  return outside_leaves
end

local Edge = {}
Edge.__index = Edge

function Edge:new(start_node, end_node)
  local edge = nil
  if end_node.x > start_node.x then
    edge = { direction = "R", y = start_node.y, start_x = start_node.x, end_x = end_node.x }
  elseif start_node.x > end_node.x then
    edge = { direction = "L", y = start_node.y, start_x = start_node.x, end_x = end_node.x }
  elseif start_node.y > end_node.y then
    edge = { direction = "U", x = start_node.x, start_y = start_node.y, end_y = end_node.y }
  else
    edge = { direction = "D", x = start_node.x, start_y = start_node.y, end_y = end_node.y }
  end
  setmetatable(edge, Edge)
  return edge
end

local Splitter = {}
Splitter.__index = Splitter

function Splitter:from_clockwise_edge(edge)
  if edge.direction == "R" then
    return { type = "horizontal", origin_direction = "R", y = edge.y - 1, min_x = edge.start_x, max_x = edge.end_x }
  elseif edge.direction == "L" then
    return { type = "horizontal", origin_direction = "L", y = edge.y, min_x = edge.end_x, max_x = edge.start_x }
  elseif edge.direction == "U" then
    return { type = "vertical", origin_direction = "U", x = edge.x - 1, min_y = edge.end_y, max_y = edge.start_y }
  else
    return { type = "vertical", origin_direction = "D", x = edge.x, min_y = edge.start_y, max_y = edge.end_y }
  end
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

local function get_clockwise_edges(nodes)
  local edges = {}
  for i, current_node in pairs(nodes) do
    local next_node = i == #nodes and nodes[i] or nodes[i + 1]
    table.insert(edges, Edge:new(current_node, next_node))
  end

  local cwCount = 0

  for i = 1, #edges do
    local current_edge = edges[i]
    local next_edge = i == #edges and edges[1] or edges[i + 1]
    local is_cw = (current_edge.direction == "R" and next_edge.direction == "D") or
        (current_edge.direction == "D" and next_edge.direction == "L") or
        (current_edge.direction == "L" and next_edge.direction == "U") or
        (current_edge.direction == "U" and next_edge.direction == "R")
    if is_cw then
      cwCount = cwCount + 1
    else
      cwCount = cwCount - 1
    end
  end

  if cwCount > 0 then
    return edges
  end
  local reversed_edges = {}
  for i = #edges, 1, -1 do
    table.insert(reversed_edges, edges[i])
  end
  return reversed_edges
end

local function get_sorted_splitters(edges)
  local horizontal_splitters = {}
  local vertical_splitters = {}

  for _, edge in pairs(edges) do
    local splitter = Splitter:from_clockwise_edge(edge)
    if splitter.type == "vertical" then
      table.insert(vertical_splitters, splitter)
    else
      table.insert(horizontal_splitters, splitter)
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
    max_x = math.max(min_x, node.x)
    min_y = math.min(min_y, node.y)
    max_y = math.max(min_y, node.y)
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
  local clockwise_edges = get_clockwise_edges(nodes)
  local horizontal_splitters, vertical_splitters = get_sorted_splitters(clockwise_edges)

  local node_bounds = get_node_bounds(nodes)
  local world_rect = Rect:from_bounds(node_bounds.min_x, node_bounds.max_x, node_bounds.min_y, node_bounds.max_y)
  local outside_parts = world_rect:find_outside_parts(horizontal_splitters, vertical_splitters)

  local sorted_rects = all_sorted_rects(nodes)
  for _, rect in pairs(sorted_rects) do
    if not rect:intersects_any(outside_parts) then
      return rect.area
    end
  end
end

assert(part1("./day9/example-input.txt") == 50)
assert(part1("./day9/input.txt") == 4781235324)
part2("./day9/example-input.txt")
