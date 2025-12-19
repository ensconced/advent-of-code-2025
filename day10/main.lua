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
    local button = { list = {}, mask = 0 }
    for num_str in button_str:gmatch("%d+") do
      local num = tonumber(num_str)
      table.insert(button.list, num + 1)
      button.mask = button.mask | 1 << num
    end
    table.insert(buttons, button)
  end
  return buttons
end

local function parse_joltages(joltages_str)
  local joltages = {}
  for joltage in joltages_str:gmatch("%d+") do
    table.insert(joltages, tonumber(joltage))
  end
  return joltages
end

local function parse_input(input_path)
  local machines = {}
  for line in io.lines(input_path) do
    local indicator_str, buttons_str, joltages_str = line:match("^%[([.#]+)%] ([%(%)%d, ]+) {([%d,]+)}")
    table.insert(machines,
      {
        indicators = parse_indicators(indicator_str),
        buttons = parse_buttons(buttons_str),
        joltages = parse_joltages(joltages_str)
      })
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
    indicators = indicators ~ button.mask
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

local function serialise_num_list(list)
  local str_arr = {}
  for _, num in pairs(list) do
    table.insert(str_arr, tostring(num))
  end
  return string.format("[ %s ]", table.concat(str_arr, ", "))
end

local function copy_list(list)
  local copy = {}
  for _, val in pairs(list) do
    table.insert(copy, val)
  end
  return copy
end

local function includes(list, x)
  for _, y in pairs(list) do
    if x == y then
      return true
    end
  end
  return false
end

local function min_presses_to_joltage(machine)
  local function find_biggest_button_per_joltage()
    local biggest_buttons = {}
    for joltage_idx = 1, #machine.joltages do
      local biggest_button = nil
      for _, button in pairs(machine.buttons) do
        if includes(button.list, joltage_idx) then
          if biggest_button == nil or #button.list > #biggest_button.list then
            biggest_button = button
          end
        end
      end
      table.insert(biggest_buttons, biggest_button)
    end
    return biggest_buttons
  end

  local biggest_button_per_joltage = find_biggest_button_per_joltage()
  for i, button in pairs(biggest_button_per_joltage) do
    print(string.format("joltage_idx: %d, button: %s", i, serialise_num_list(button.list)))
  end

  local function branch_lower_bound(remaining_joltages, current_press_count)
    local indent = ("  "):rep(current_press_count)
    local remaining_joltages_copy = copy_list(remaining_joltages)
    local remaining_presses_lower_bound = 0
    while true do
      print(string.format("%s remaining_joltages_copy:", indent))
      print(string.format("%s %s", indent, serialise_num_list(remaining_joltages_copy)))
      local max_remaining_joltage, max_remaining_joltage_idx = nil, nil
      for joltage_idx = 1, #remaining_joltages_copy do
        local remaining_joltage = remaining_joltages_copy[joltage_idx]
        if remaining_joltage > 0 then
          if max_remaining_joltage == nil or remaining_joltage > max_remaining_joltage then
            max_remaining_joltage = remaining_joltage
            max_remaining_joltage_idx = joltage_idx
          end
        end
      end

      if max_remaining_joltage == nil then
        return remaining_presses_lower_bound + current_press_count
      end

      local biggest_button_affecting_most_remaining_joltage = biggest_button_per_joltage[max_remaining_joltage_idx]
      -- print("biggest_button_affecting_most_remaining_joltage:")
      -- print(serialise_num_list(biggest_button_affecting_most_remaining_joltage.list))
      remaining_presses_lower_bound = remaining_presses_lower_bound + max_remaining_joltage
      for _, joltage_idx in pairs(biggest_button_affecting_most_remaining_joltage.list) do
        remaining_joltages_copy[joltage_idx] = remaining_joltages_copy[joltage_idx] - max_remaining_joltage
      end
    end
  end

  local function check_joltage_status(remaining_joltages)
    local done = true
    for _, joltage in pairs(remaining_joltages) do
      if joltage < 0 then
        return false, true
      elseif joltage > 0 then
        done = false
      end
    end
    return done, false
  end

  local function find_min_for_branch(current_press_count, remaining_joltages, min_presses_to_target)
    local indent = ("  "):rep(current_press_count)
    local reached_target_joltages, exceeded_target_joltages = check_joltage_status(remaining_joltages)

    if reached_target_joltages then
      print(string.format("%s reached target joltages", indent))
      return math.min(current_press_count, min_presses_to_target)
    end

    if exceeded_target_joltages then
      print(string.format("%s exceeded target joltages", indent))
      return min_presses_to_target
    end

    if branch_lower_bound(remaining_joltages, current_press_count) >= min_presses_to_target then
      print(string.format("%s never gonna work, abandoning branch", indent))
      return min_presses_to_target
    end

    for _, button in pairs(machine.buttons) do
      local next_press_count = current_press_count + 1
      local next_joltages = copy_list(remaining_joltages)
      for _, joltage_idx in pairs(button.list) do
        next_joltages[joltage_idx] = next_joltages[joltage_idx] - 1
      end
      min_presses_to_target = math.min(min_presses_to_target,
        find_min_for_branch(next_press_count, next_joltages, min_presses_to_target))
    end

    return min_presses_to_target
  end

  return find_min_for_branch(0, machine.joltages, math.maxinteger)
end

local function part2(input_path)
  local machines = parse_input(input_path)
  local total = 0
  for _, machine in pairs(machines) do
    local min_presses = min_presses_to_joltage(machine)
    total = total + min_presses
  end
  return total
end

assert(part1("./day10/example-input.txt") == 7)
assert(part1("./day10/input.txt") == 547)
print(part2("./day10/example-input.txt"))
-- print(part2("./day10/input.txt"))
