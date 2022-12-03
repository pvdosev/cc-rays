local static = require("static")
local ray = require("ray")

-- GLOBALS
inf = math.huge

local function setup()
  local pixel_ratio = 0

  -- display on monitor if one is connected
  local display = peripheral.find("monitor")
  if not display then display = term.current() end
  term.redirect(display)
  if periphemu then
    -- we're in craftos!
    display.setGraphicsMode(1)
    -- why does 2 make things look correct? ¯\_(ツ)_/¯
    pixel_ratio = 2
  else
    -- we're in minecraft!
    -- this is set to 1.5 to compensate
    -- for the rectangular pixels
    pixel_ratio = 1.5
  end
  local max_x, max_y = display.getSize(display.getGraphicsMode() or 1)
  return display, pixel_ratio, max_x, max_y
end

local function main()
  --periphemu.create("left", "debugger")
  local display, pixel_ratio, max_x, max_y = setup();
  local min_x, min_y = 0, 0;
  -- craftos high resolution graphics mode starts at 0, 0 instead of 1, 1
  if (display.getGraphicsMode() > 0) then
    min_x, min_y = 0, 0;
  else
    min_x, min_y = 1, 1;
  end
  local vec3_origin = vector.new(0, 0, 0)

  for y = min_y, max_y, 1 do
    for x = min_x, max_x, 1 do
      local vec3_viewport_point = ray.displayToViewport(x, y, max_x, max_y, pixel_ratio)
      local h, s, v = ray.traceRay(vec3_origin, vec3_viewport_point, 1, inf, static.spheres, static.lights)
      if h ~= 0 then
        v = v + (static.bayer4x4[((x - 1) % 3) + 1][((y - 1) % 3) + 1] *.25 - 0.125)
        s = s + (static.bayer4x4[((-x + 1) % 3) + 1][((-y + 1) % 3) + 1] *.25 - 0.125)
        --h = h + (static.bayer4x4[((x - 1) % 3) + 1][((-y + 1) % 3) + 1] *.125 - 0.0625)
        v = v + (math.random() * 0.2 - 0.125)
      end
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

  -- waits for a key event to exit. Needed for craftos graphics mode, which immediately clears
  os.pullEvent("key")
end

main()
