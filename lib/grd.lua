local grd = {}
g = grid.connect()
g.pressed = 1
g.holding = {}

function grd.init()
  g:all(0)
  g:refresh()
end

g.key = function(x, y, z)
  g:all(0)
  g:led(x, y, z * 15)
  g.pressed = getKeynumber(x, y)
  print(g.pressed)
  g:refresh()
end


-- local utility functions
function getKeynumber(x, y)
  return (x - 1) * 16 + y
end

return grd
