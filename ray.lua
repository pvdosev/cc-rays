-- cc has a vector type already
-- might need a new one if we port to love
-- local Vector3 = require("Vector3")

inf = 1/0 -- this works don't worry

local function canvasToDisplay(x, y, maxX, max_y)
  return vector:new(x / maxX * 2 - 1, y / max_y * 2 - 1, 1)
end

local function traceRay(origin, viewport_point, near, far, intersectors)
  closest_dist = inf
  closest_obj = nil

end

local display = peripheral.find("monitor")
if not display then display = term.current() end

spheres = {
  {
    center = vector:new(0, -1, 3),
    radius = 1,
    color = colors.red
  },
  {
    center = vector:new(2, 0, 4),
    radius = 1,
    color = colors.blue
  },
  {
    center = vector:new(-2, 0, 4),
    radius = 1,
    color = colors.green
  }
}

local max_x, max_y = display.getSize()
local min_x, min_y = 1, 1; -- TODO support craftos graphics mode
local origin = vector:new(0, 0, 0)
print(max_x, max_y)

for x = min_x, max_x, 1 do
  for y = min_y, max_y, 1 do
    local viewport_point = canvasToDisplay(x, y, max_x, max_y)
    local color = traceRay(origin, viewport_point, 1, inf)
  end
end
