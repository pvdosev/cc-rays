-- a little utility to visualize
-- computercraft's character set

local display = peripheral.find("monitor")
if not display then display = term.current() end
term.redirect(display)
local max_x, max_y = display.getSize()

for y = 1, max_y, 1 do
  for x = 1, max_x, 1 do
    io.write(string.format('%s', x - 1 + ((y - 1) * max_x)))
  end
  io.write("\n")
  io.flush()
end
