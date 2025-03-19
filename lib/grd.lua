local grd = {}
_state = include("lib/stt")
grd.pressed = {}
grd.holding = {}


grd.key = function(x, y, z)
--   g:all(0)
--   g:led(x, y, z * 15)
  grd.pressed.index = getKeynumber(x, y)
  grd.pressed.x = x
  grd.pressed.y = y
  print(grd.pressed)
  if _state.mode == "perform" then
    if z == 1 then --if the key is being held down add it to "holding" table
      table.insert(grd.holding, grd.pressed)
      -- tab.print(holding)
    elseif z == 0 then --if key is let go remove it from "holding" table
      idx = get_index(grd.holding, grd.pressed)
      table.remove(grd.holding, idx)
      -- tab.print(holding)
    end
  elseif mode == "edit" then
    selectedEditKey.id = keynumber
    selectedEditKey.x = x
    selectedEditKey.y = y
    g:led(x,y,15)
    edit()
  end
  grd.redraw()
end


-- update lights on grid
-- we need to do a reverse getKeynumber to get the x and y values
grd.redraw = function()
  g:all(0)
  for i = 1, #grd.holding do
    g:led(grd.holding[i].x, grd.holding[i].y, 15)
  end
  tab.print(grd.holding)
  g:led(grd.pressed.x, grd.pressed.y, 15)
  g:refresh()
end


-- local utility functions
function getKeynumber(x, y)
  local keynumber = 129-(((y-1)*16)+x)
  return keynumber
end

function get_index(tbl, value)
    for i, v in ipairs(tbl) do
      if v.index == value.index then
        return i -- Return the index if found
      end
    end
    return nil -- Return nil if not found
end

return grd
