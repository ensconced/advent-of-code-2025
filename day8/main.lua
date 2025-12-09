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
    for j = 1, #nodes do
      if i ~= j then
        local entry = { i, j, distance_squared(nodes[i], nodes[j]) }
        table.insert(node_pairs, entry)
      end
    end
  end

  table.sort(node_pairs, function(a, b) return a[3] < b[3] end)

  return node_pairs
end

local function add_edge(circuits)
  -- TODO
end

local function part1(input_path)
  local nodes = parse_input(input_path)
  local node_pairs = node_pairs_sorted_by_distance(nodes)
  local circuits = {}
  for _, node_pair in pairs(node_pairs) do
    add_edge(circuits)
  end
  local result = 1
  for _, circuit in pairs(circuits) do
    result = result * #circuit
  end
  return result
end


print(part1("./day8/example-input.txt"))
-- print(part1("./day8/input.txt"))
