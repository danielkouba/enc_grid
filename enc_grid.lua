--encoder grid
-- turns your grid into a 128 encoder midi controller
_grid = include("lib/grd")
_state = include("lib/stt")

g = grid.connect()



g.key = function(x, y, z)
    _grid.key(x, y, z)
end


function init()
    _state.init()
    g:all(0)
    g:refresh()
end