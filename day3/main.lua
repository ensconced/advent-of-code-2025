local function digit_string_to_number_table(digit_string)
  local result = {}
  for i = 1, #digit_string do
    table.insert(result, tonumber(digit_string:sub(i, i)))
  end
  return result
end

local function biggest_following_digits(digit_table)
  local result = {}
  local biggest_follower = nil
  for i = #digit_table, 2, -1 do
    biggest_follower = math.max(biggest_follower or 0, digit_table[i])
    result[i - 1] = biggest_follower
  end
  return result
end

local function part1(input_path)
  local sum = 0
  for line in io.lines(input_path) do
    local digits = digit_string_to_number_table(line)
    local biggest_first_digit = nil
    local biggest_first_digit_index = nil

    for i = 1, #digits - 1 do
      if digits[i] > (biggest_first_digit or 0) then
        biggest_first_digit = digits[i]
        biggest_first_digit_index = i
      end
    end

    local biggest_first_digit_indices = {}
    for i = 1, #digits - 1 do
      if digits[i] == biggest_first_digit then
        table.insert(biggest_first_digit_indices, i)
      end
    end

    local biggest_following = biggest_following_digits(digits)
    local biggest_two_digit_num = 0
    local two_digit_num = biggest_first_digit * 10 + biggest_following[biggest_first_digit_index]
    biggest_two_digit_num = math.max(biggest_two_digit_num, two_digit_num)
    sum = sum + biggest_two_digit_num
  end
  return sum
end

assert(part1("./day3/example-input.txt") == 357)
assert(part1("./day3/input.txt") == 17179)
