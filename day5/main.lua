local Range = {}

function Range:new(lower, upper)
  local range = { lower = lower, upper = upper }
  self.__index = self
  setmetatable(range, self)
  return range
end

function Range:includes(value)
  return value >= self.lower and value < self.upper
end

function Range:size()
  return self.upper - self.lower
end

function Range:is_mergeable_with(other)
  return self:includes(other.lower) or self:includes(other.upper) or other:includes(self.lower) or
      other:includes(self.upper)
end

function Range:merge(other)
  return Range:new(math.min(self.lower, other.lower), math.max(self.upper, other.upper))
end

local function parse_input(input_path)
  local ranges = {}
  local ids = {}
  for line in io.lines(input_path) do
    local range_start, range_end = line:match("^(%d+)-(%d+)$")
    if range_start and range_end then
      local range = Range:new(tonumber(range_start), tonumber(range_end) + 1)
      table.insert(ranges, range)
    elseif line:match("^%d+$") then
      table.insert(ids, tonumber(line))
    end
  end
  return { ranges = ranges, ids = ids }
end

local function merge_ranges(ranges)
  local i = 1
  while i <= #ranges do
    local range = ranges[i]
    local j = i + 1
    while j <= #ranges do
      local merge_candidate = ranges[j]
      if range:is_mergeable_with(merge_candidate) then
        ranges[j] = ranges[i]:merge(ranges[j])
        table.remove(ranges, i)
        return true
      end
      j = j + 1
    end
    i = i + 1
  end
  return false
end

local function part1(input_path)
  local parsed = parse_input(input_path)
  local count = 0
  for _, id in pairs(parsed.ids) do
    for _, range in pairs(parsed.ranges) do
      if range:includes(id) then
        count = count + 1
        break
      end
    end
  end
  return count
end

local function part2(input_path)
  local parsed = parse_input(input_path)

  -- merge ranges until all the remaining ones are disjoint
  while merge_ranges(parsed.ranges) do end

  local sum = 0
  for _, range in pairs(parsed.ranges) do
    sum = sum + range:size()
  end
  return sum
end

assert(part1("./day5/example-input.txt") == 3)
assert(part1("./day5/input.txt") == 744)
assert(part2("./day5/example-input.txt") == 14)
assert(part2("./day5/input.txt") == 347468726696961)
