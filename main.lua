local static = require("static")
local ray = require("ray")

-- GLOBALS
inf = 1/0 -- this works don't worry

local function main()
  -- display on monitor if one is connected
  local display = peripheral.find("monitor")
  if not display then display = term.current() end
  term.redirect(display)

  local max_x, max_y = display.getSize()
  local min_x, min_y = 1, 1; -- TODO support craftos graphics mode
  local vec3_origin = vector.new(0, 0, 0)
  --periphemu.create("left", "debugger")

  for x = min_x, max_x, 1 do
    for y = min_y, max_y, 1 do
      local vec3_viewport_point = ray.displayToViewport(x, y, max_x, max_y)
      local color = ray.traceRay(vec3_origin, vec3_viewport_point, 1, inf, static.spheres, static.lights)
      paintutils.drawPixel(x, y, color)
    end
  end
end

main()
