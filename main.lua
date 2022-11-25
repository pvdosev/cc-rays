local static = require("static")
local ray = require("ray")

-- GLOBALS
inf = 1/0 -- this works don't worry

local function main()
  --periphemu.create("left", "debugger")
  -- display on monitor if one is connected
  local display = peripheral.find("monitor")
  if not display then display = term.current() end
  term.redirect(display)

  local max_x, max_y = display.getSize()
  local min_x, min_y = 1, 1; -- TODO support craftos graphics mode
  local vec3_origin = vector.new(0, 0, 0)

  for x = min_x, max_x, 1 do
    for y = min_y, max_y, 1 do
      local vec3_viewport_point = ray.displayToViewport(x, y, max_x, max_y)
      local h, s, v = ray.traceRay(vec3_origin, vec3_viewport_point, 1, inf, static.spheres, static.lights)
      v = v + (static.bayer4x4[((x - 1) % 3) + 1][((y - 1) % 3) + 1] * .5 - 0.2)
      local r, g, b = ray.HSVtoRGB(h, s, v)
      local closest_id = 0
      local closest_dist = math.huge
      local curr_dist = 0
      for index, color in ipairs(static.default_palette) do
        curr_dist = ray.euclideanDistance(color.r, color.g, color.b, r, g, b)
        if curr_dist < closest_dist then
          closest_dist = curr_dist
          closest_id = color.id
        end
      end
      paintutils.drawPixel(x, y, closest_id)
    end
  end
end

main()
