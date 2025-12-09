local Circuit = {}
function Circuit:new()
  local circuit = { size = 0, node_idxs = {} }
  self.__index = self
  setmetatable(circuit, Circuit)
  return circuit
end

function Circuit:contains(node_idx)
  for _, contained_node_idx in pairs(self.node_idxs) do
    if contained_node_idx == node_idx then
      return true
    end
  end
  return false
end

function Circuit:add_node(node_idx)
  table.insert(self.node_idxs, node_idx)
  self.size = self.size + 1
end

return Circuit
