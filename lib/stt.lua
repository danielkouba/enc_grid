local stt = {}

stt.mode = "perform"
stt.holding = {}
stt.selectedEditKey = {}
stt.selectedEditParameter = 1
stt.midi_cc_map = {}

stt.init = function()
    stt.midi_cc_map = tab.load(_path.data.."enc_grid/enc_grid.txt")
    -- if there are no settings, create them
    if stt.midi_cc_map==nil then
      -- create table of keys
      for i = 1, 128 do
        stt.midi_cc_map[i] = {
          id = i,
        --   x = getXCoord(i),
        --   y = getYCoord(i),
          name = "default",
          type = "CC",
          channel = 1,
          cc = i,       -- Default to CC matching index
          value = 0,     -- Current value
          lit = 0
        }
      end
      -- create a saved file
      tab.save(stt.midi_cc_map, _path.data.."enc_grid/enc_grid.txt")
    end
end

function getXCoord(index)
    local x = ((index - 1) % 16) + 1
    return x
end

function getYCoord(index)
    local y = math.floor((index - 1) / 16) + 1
    return y
end


return stt