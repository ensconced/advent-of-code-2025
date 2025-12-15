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
      table.insert(button.list, num)
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

local function take(list, n)
  local chunk = {}
  for _ = 1, math.min(#list, n) do
    table.insert(chunk, table.remove(list, 1))
  end
  return chunk
end

local function min_presses_to_joltage(machine)
  local function find_max_joltage_per_press()
    local max = 0
    for _, button in pairs(machine.buttons) do
      max = math.max(#button.list, max)
    end
    return max
  end
  local max_joltage_per_press = find_max_joltage_per_press()

  local function branch_lower_bound(remaining_joltages, current_press_count)
    -- TODO - what we *should* be doing here is taking the approach as if we didn't
    -- care about exceeding the joltage. Here, for each joltage, you would simply
    -- choose the BIGGEST button that included that joltage, and press that as many
    -- times as necessary to get that joltage to zero, decreasing the other joltages
    -- affected by that button as a happy side effect.
    local copy = copy_list(remaining_joltages)
    table.sort(copy, function(a, b) return a > b end)
    print(serialise_num_list(copy))
    local lower_bound = 0
    while #copy > 0 do
      local chunk = take(copy, max_joltage_per_press)
      if #chunk > 0 then
        lower_bound = lower_bound + chunk[1]
      end
    end
    print(max_joltage_per_press, lower_bound)
    return lower_bound + current_press_count
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
    -- print(string.format("%scurrent_press_count: %d", indent, current_press_count))
    -- print(string.format("%smin_presses_to_target: %d", indent, min_presses_to_target))
    -- print(string.format("%sremaining_joltages: %s", indent, serialise_num_list(remaining_joltages)))
    local reached_target_joltages, exceeded_target_joltages = check_joltage_status(remaining_joltages)

    if reached_target_joltages then
      -- print(string.format("%sreached target", indent))
      return math.min(current_press_count, min_presses_to_target)
    end

    if exceeded_target_joltages then
      -- print(string.format("%sexceeded joltage targets", indent))
      return min_presses_to_target
    end

    if branch_lower_bound(remaining_joltages, current_press_count) >= min_presses_to_target then
      -- print(string.format("%spruning by lower bound", indent))
      return min_presses_to_target
    end


    for _, button in pairs(machine.buttons) do
      local next_press_count = current_press_count + 1
      local next_joltages = copy_list(remaining_joltages)
      for _, joltage_idx in pairs(button.list) do
        next_joltages[joltage_idx + 1] = next_joltages[joltage_idx + 1] - 1
      end
      -- print(string.format("%snext_joltages: %s", indent, serialise_num_list(next_joltages)))
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
    -- print(min_presses)
    total = total + min_presses
  end
  return total
end

assert(part1("./day10/example-input.txt") == 7)
assert(part1("./day10/input.txt") == 547)
print(part2("./day10/example-input.txt"))
print(part2("./day10/input.txt"))
