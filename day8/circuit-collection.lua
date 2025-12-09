local Circuit = require("./day8/circuit")

local CircuitCollection = {}
function CircuitCollection:new()
  local circuit_collection = {}
  self.__index = self
  setmetatable(circuit_collection, CircuitCollection)
  return circuit_collection
end

function CircuitCollection:find_circuit_containing(node_idx)
  for i, circuit in pairs(self) do
    if circuit:contains(node_idx) then
      return i, circuit
    end
  end
  return nil
end

function CircuitCollection:add_edge(node_idx_a, node_idx_b)
  local circuit_a_idx, circuit_a = self:find_circuit_containing(node_idx_a)
  local circuit_b_index, circuit_b = self:find_circuit_containing(node_idx_b)
  if circuit_a and circuit_b then
    if circuit_a ~= circuit_b then
      for _, node_idx in pairs(circuit_a.node_idxs) do
        circuit_b:add_node(node_idx)
      end
      table.remove(self, circuit_a_idx)
    end
  elseif circuit_a then
    circuit_a:add_node(node_idx_b)
  elseif circuit_b then
    circuit_b:add_node(node_idx_a)
  else
    local new_circuit = Circuit:new()
    new_circuit:add_node(node_idx_a)
    new_circuit:add_node(node_idx_b)
    table.insert(self, new_circuit)
  end
end

function CircuitCollection:sort_by_size()
  table.sort(self, function(a, b) return a.size > b.size end)
end

function CircuitCollection:total_size()
  local total = 0
  for _, circuit in pairs(self) do
    total = total + circuit.size
  end
  return total
end

return CircuitCollection
