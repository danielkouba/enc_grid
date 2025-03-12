-- encoder grid
--
-- ┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
-- │  1 │  2 │  3 │  4 │  5 │  6 │  7 │  8 │  9 │ 10 │ 11 │ 12 │ 13 │ 14 │ 15 │ 16 │
-- ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤
-- │ 17 │ 18 │ 19 │ 20 │ 21 │ 22 │ 23 │ 24 │ 25 │ 26 │ 27 │ 28 │ 29 │ 30 │ 31 │ 32 │
-- ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤
-- │ 33 │ 34 │ 35 │ 36 │ 37 │ 38 │ 39 │ 40 │ 41 │ 42 │ 43 │ 44 │ 45 │ 46 │ 47 │ 48 │
-- ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤
-- │ 49 │ 50 │ 51 │ 52 │ 53 │ 54 │ 55 │ 56 │ 57 │ 58 │ 59 │ 60 │ 61 │ 62 │ 63 │ 64 │
-- ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤
-- │ 65 │ 66 │ 67 │ 68 │ 69 │ 70 │ 71 │ 72 │ 73 │ 74 │ 75 │ 76 │ 77 │ 78 │ 79 │ 80 │
-- ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤
-- │ 81 │ 82 │ 83 │ 84 │ 85 │ 86 │ 87 │ 88 │ 89 │ 90 │ 91 │ 92 │ 93 │ 94 │ 95 │ 96 │
-- ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤
-- │ 97 │ 98 │ 99 │100 │101 │102 │103 │104 │105 │106 │107 │108 │109 │110 │111 │112 │
-- ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤
-- │113 │114 │115 │116 │117 │118 │119 │120 │121 │122 │123 │124 │125 │126 │127 │128 │
-- └────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘


-- goals
-- turn a grid into 128 encoders by holding down a key on the grid and turning encoder 3
-- press a key on the grid and use encoder 3 to control the cc value
-- encoder 2 will control cc msg
-- encoder 1 will control channel
-- be able to name each key
-- save presets
-- assign light to assigned keys
m = midi.connect()
g = grid.connect()

mode = "perform"
midi_cc_map = {}
holding = {}
selectedEditKey = {id = 1}
selectedEditParameter = 0;

function init()
  --load settings
  midi_cc_map = tab.load(_path.data.."enc_grid/enc_grid.txt")
  -- if there are no settings, create them
  if midi_cc_map==nil then
    -- create table of keys
    for i = 1, 128 do
      midi_cc_map[i] = {
        id = i,
        name = "default",
        type = "CC",
        channel = 1,
        cc = i,       -- Default to CC matching index
        value = 0,     -- Current value
        lit = 0
      }
    end
    -- create a saved file
    tab.save(midi_cc_map, _path.data.."enc_grid/enc_grid.txt")
  end
end

--capture GRID keypresses
g.key = function(x,y,z)
  g:all(0)
  g:led(x,y,z*15)
  keynumber = 129-(((y-1)*16)+x) -- find the number of the key on the grid 1 top left, 128 bottom right
  --print(keynumber)
  print("CC:", midi_cc_map[keynumber].cc, "Value:", midi_cc_map[keynumber].value)
  if mode == "perform" then
    if z == 1 then --if the key is being held down add it to "holding" table
      table.insert(holding, keynumber)
      -- tab.print(holding)
    elseif z == 0 then --if key is let go remove it from "holding" table
      idx = get_index(holding, keynumber)
      table.remove(holding, idx)
      -- tab.print(holding)
    end
  elseif mode == "edit" then
    selectedEditKey.id = keynumber
    selectedEditKey.x = x
    selectedEditKey.y = y
    g:led(x,y,15)
    edit()
  end
  g:refresh()
  redraw_screen()
end

-- Capture Encoder turns
function enc(n,d)
  print("encoder ".. n .." == "..d)
  if n == 1 then
    --do something
    selectedEditParameter = selectedEditParameter + d
  elseif n == 2 then
    --midi_cc_map[1].cc = midi_cc_map[1].cc + d --edit channel
  elseif n == 3 then
    if mode == "perform" then
      perform(d)
    end
  end
  redraw_screen()
end

-- a simple get index of table function
function get_index(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then
      return i -- Return the index if found
    end
  end
  return nil -- Return nil if not found
end

-- Capture Key presses
function key(n,z)
  print(n)
  if n == 2 and z == 0 then
    mode = "edit"
  elseif n == 3 and z == 0 then
    mode = "perform"
  end
  redraw_screen()
end

--draw on the screen
function redraw_screen()
  screen.level(15)
  screen.move(90,60)
  screen.text(mode)
  screen.update()
end

-- While in edit mode
-- edit one grid key
-- view key's channel, cc, default value and lit status
function edit()
  screen.clear()
  screen.level(15)
  screen.move(90,60)
  screen.text(mode)
  options = {"key","channel", "cc", "value", "led"}
  screen.move(10,10*(selectedEditParameter+1))
  screen.text("Key ".. midi_cc_map[selectedEditKey.id].id)
  screen.move(10,10*(selectedEditParameter+2))
  screen.text("Channel ".. midi_cc_map[selectedEditKey.id].channel)
  screen.move(10,10*(selectedEditParameter+3))
  screen.text("CC ".. midi_cc_map[selectedEditKey.id].cc)
  screen.move(10,10*(selectedEditParameter+4))
  screen.text("Value ".. midi_cc_map[selectedEditKey.id].value)
  tab.save(midi_cc_map, _path.data.."enc_grid/enc_grid.txt")
  redraw_screen()
end

-- While in perform mode
-- send midi CCs
-- edit value
function perform(inc)
  screen.clear()
  screen.level(15)
  screen.move(90,60)
  screen.text(mode)
  if #holding > 0 then
    for i,v in ipairs(holding) do
      midi_cc_map[v].value = midi_cc_map[v].value + inc
      m:cc(midi_cc_map[v].cc, midi_cc_map[v].value, midi_cc_map[v].channel)
      print("CC:", midi_cc_map[v].cc, "Value:", midi_cc_map[v].value)
      screen.move(0,10*i)
      screen.text("Key ".. midi_cc_map[v].id .." : CH ".. midi_cc_map[v].channel .." : CC ".. midi_cc_map[v].cc .." : VAL "..midi_cc_map[v].value .."")
    end
  end
  redraw_screen()
end