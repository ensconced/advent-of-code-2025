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

function Range:disjoint(other)
  return other.upper < self.lower or other.lower > self.upper
end

function Range:merge(other)
  if self:disjoint(other) then
    error("tried to merge disjoint ranges")
  end
  return Range:new(math.min(self.lower, other.lower), math.max(self.upper, other.upper))
end

local function parse_input(input_path)
  local ranges = {}
  local ids = {}
  for line in io.lines(input_path) do
    local range_start, range_end = line:match("^(%d+)-(%d+)$")
    if range_start and range_end then
      table.insert(ranges, Range:new(tonumber(range_start), tonumber(range_end) + 1))
    elseif line:match("^%d+$") then
      table.insert(ids, tonumber(line))
    end
  end
  return { ranges = ranges, ids = ids }
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
  local merged = Range:new(0, 0)
  for _, range in pairs(parsed.ranges) do
    print(merged.lower, merged.upper, range.lower, range.upper, merged:merge(range).lower, merged:merge(range).upper)
    merged = merged:merge(range)
  end
  return merged:size()
end

assert(part1("./day5/example-input.txt") == 3)
assert(part1("./day5/input.txt") == 744)
assert(part2("./day5/example-input.txt") == 14)
