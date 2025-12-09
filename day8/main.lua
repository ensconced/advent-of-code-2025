local CircuitCollection = require("./day8/circuit-collection")

local function parse_input(input_path)
  local nodes = {}
  for line in io.lines(input_path) do
    local node = {}
    for val in line:gmatch("%d+") do
      table.insert(node, tonumber(val))
    end
    table.insert(nodes, node)
  end
  return nodes
end

local function distance_squared(node_a, node_b)
  local result = 0
  for i = 1, 3 do
    local delta = node_a[i] - node_b[i]
    result = result + delta * delta
  end
  return result
end

local function node_pairs_sorted_by_distance(nodes)
  local node_pairs = {}
  for i = 1, #nodes do
    for j = i + 1, #nodes do
      local entry = { i, j, distance_squared(nodes[i], nodes[j]) }
      table.insert(node_pairs, entry)
    end
  end

  table.sort(node_pairs, function(a, b) return a[3] < b[3] end)

  return node_pairs
end


local function part1(input_path, connections)
  local nodes = parse_input(input_path)
  local node_pairs = node_pairs_sorted_by_distance(nodes)
  local circuit_collection = CircuitCollection:new()
  for i = 1, connections do
    local node_pair = node_pairs[i]
    circuit_collection:add_edge(node_pair[1], node_pair[2])
  end
  circuit_collection:sort_by_size()
  local result = 1
  for i = 1, 3 do
    result = result * circuit_collection[i].size
  end
  return result
end

local function part2(input_path)
  local nodes = parse_input(input_path)
  local node_pairs = node_pairs_sorted_by_distance(nodes)
  local circuit_collection = CircuitCollection:new()
  for i = 1, #node_pairs do
    local node_pair = node_pairs[i]
    circuit_collection:add_edge(node_pair[1], node_pair[2])
    if circuit_collection:total_size() == #nodes then
      return nodes[node_pair[1]][1] * nodes[node_pair[2]][1]
    end
  end
  return nil
end

assert(part1("./day8/example-input.txt", 10) == 40)
assert(part1("./day8/input.txt", 1000) == 112230)
assert(part2("./day8/example-input.txt") == 25272)
assert(part2("./day8/input.txt") == 2573952864)
