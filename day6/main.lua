local function parse_input_for_part1(lines)
  local problems = {}
  for line_idx, line in pairs(lines) do
    if line_idx == #lines then
      local operator_idx = 1
      for operator in line:gmatch("[*+]") do
        problems[operator_idx].operator = operator
        operator_idx = operator_idx + 1
      end
    else
      local row_numbers = {}
      for match in line:gmatch("%d+") do
        table.insert(row_numbers, tonumber(match))
      end
      if line_idx == 1 then
        for _ = 1, #row_numbers do
          table.insert(problems, { operands = {} })
        end
      end
      for i, num in pairs(row_numbers) do
        table.insert(problems[i].operands, num)
      end
    end
  end
  return problems
end

local function parse_input_for_part2(lines)
  local problems = {}

  local width = #lines[1]
  local problem = { operands = {} }
  for i = width, 1, -1 do
    local chars = {}
    for j = 1, #lines do
      table.insert(chars, lines[j]:sub(i, i))
    end
    local str = table.concat(chars)
    local num = tonumber(str:match("%d+"))
    table.insert(problem.operands, num)
    local operator = str:match("[*+]")
    if operator then
      problem.operator = operator
      table.insert(problems, problem)
      problem = { operands = {} }
    end
  end

  return problems
end

local function main(input_path, parser)
  local lines = {}
  for line in io.lines(input_path) do
    table.insert(lines, line)
  end
  local parsed = parser(lines)

  local grand_total = 0
  for _, problem in pairs(parsed) do
    local acc = problem.operator == "+" and 0 or 1
    for _, operand in pairs(problem.operands) do
      if problem.operator == "+" then
        acc = acc + operand
      else
        acc = acc * operand
      end
    end
    grand_total = grand_total + acc
  end
  return grand_total
end

local function part1(input_path)
  return main(input_path, parse_input_for_part1)
end

local function part2(input_path)
  return main(input_path, parse_input_for_part2)
end

assert(part1("./day6/example-input.txt") == 4277556)
assert(part1("./day6/input.txt") == 4076006202939)
assert(part2("./day6/example-input.txt") == 3263827)
assert(part2("./day6/input.txt") == 7903168391557)
