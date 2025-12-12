local function parse_input(input_path)
  local nodes = {}
  for line in io.lines(input_path) do
    local x, y = line:match("^(%d+),(%d+)$")
    table.insert(nodes, { x = x, y = y })
  end
  return nodes
end

local function part1(input_path)
  local nodes = parse_input(input_path)

  local max = 0
  for i = 1, #nodes do
    local node_a = nodes[i]
    for j = i, #nodes do
      local node_b = nodes[j]
      max = math.max(max, (math.abs(node_a.x - node_b.x) + 1) * (math.abs(node_a.y - node_b.y) + 1))
    end
  end
  return max
end


assert(part1("./day9/example-input.txt") == 50)
assert(part1("./day9/input.txt") == 4781235324)
