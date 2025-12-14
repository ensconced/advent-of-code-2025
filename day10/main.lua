local function parse_indicators(indicator_str)
  local indicators = 0
  for i = #indicator_str, 1, -1 do
    indicators = (indicators << 1) | (indicator_str:sub(i, i) == "#" and 1 or 0)
  end
  return indicators
end

local function parse_buttons(buttons_str)
  local buttons = {}
  for button_str in buttons_str:gmatch("%([%d,]+%)") do
    local button = 0
    for num_str in button_str:gmatch("%d+") do
      button = button | 1 << tonumber(num_str)
    end
    table.insert(buttons, button)
  end
  return buttons
end

local function parse_input(input_path)
  local machines = {}
  for line in io.lines(input_path) do
    local machine = { buttons = {} }
    local indicator_str, buttons_str = line:match("^%[([.#]+)%] ([%(%)%d, ]+)")
    machine.indicators = parse_indicators(indicator_str)
    machine.buttons = parse_buttons(buttons_str)
    table.insert(machines, machine)
  end
  return machines
end

local function after(list, idx)
  local result = {}
  for i = idx + 1, #list do
    table.insert(result, list[i])
  end
  return result
end

local function choose(k, list)
  if k > #list then return {} end
  if k == 0 then return { {} } end
  local combinations = {}
  for i = 1, #list do
    for _, comb_of_rest in pairs(choose(k - 1, after(list, i))) do
      table.insert(comb_of_rest, list[i])
      table.insert(combinations, comb_of_rest)
    end
  end
  return combinations
end

local function is_valid_button_combination(machine, button_combination)
  local indicators = 0
  for _, button in pairs(button_combination) do
    indicators = indicators ~ button
  end
  return indicators == machine.indicators
end

local function find_valid_button_combination(machine)
  for i = 0, #machine.buttons do
    local combinations = choose(i, machine.buttons)
    for _, button_combination in pairs(combinations) do
      if is_valid_button_combination(machine, button_combination) then
        return button_combination
      end
    end
  end
  error("failed to find valid button combination")
end

local function part1(input_path)
  local machines = parse_input(input_path)
  local total = 0
  for _, machine in pairs(machines) do
    local button_combination = find_valid_button_combination(machine)
    total = total + #button_combination
  end
  return total
end

assert(part1("./day10/example-input.txt") == 7)
assert(part1("./day10/input.txt") == 547)
