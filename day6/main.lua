local function parse_input(input_path)
  local lines = {}
  for line in io.lines(input_path) do
    table.insert(lines, line)
  end

  local result = {}
  for line_idx, line in pairs(lines) do
    if line_idx == #lines then
      local operator_idx = 1
      for operator in line:gmatch("[*+]") do
        result[operator_idx].operator = operator
        operator_idx = operator_idx + 1
      end
    else
      local row_numbers = {}
      for match in line:gmatch("%d+") do
        table.insert(row_numbers, tonumber(match))
      end
      if line_idx == 1 then
        for _ = 1, #row_numbers do
          table.insert(result, { operands = {} })
        end
      end
      for i, num in pairs(row_numbers) do
        table.insert(result[i].operands, num)
      end
    end
  end
  return result
end

local function part1(input_path)
  local parsed = parse_input(input_path)

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


assert(part1("./day6/example-input.txt") == 4277556)
assert(part1("./day6/input.txt") == 4076006202939)
