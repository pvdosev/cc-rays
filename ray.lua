-- we're using the built-in computercraft vector type
-- GLOBALS
inf = 1/0 -- this works don't worry

-- FUNCTIONS
local function canvasToDisplay(x, y, max_x, max_y)
  -- scales x by the ratio between the height and width of the screen
  -- the y is divided by 1.4 because the characters in computercraft are rectangular
  -- TODO figure out the exact ratio of the width and height of characters
  return vector.new(x / max_x * (max_x / max_y) - (max_x / max_y / 2), (y / max_y * 2 - 1) / 1.4, 1)
end

local function intersectRaySphere(origin, direction, sphere)
  radius = sphere.radius
  v_co = origin:sub(sphere.center)

  -- construct a quadratic equation to find intersections
  a = direction:dot(direction) -- the length of the vector
  b = 2 * direction:dot(v_co)
  c = v_co:dot(v_co) - radius * radius
  discriminant = (b * b) - (4 * a * c)
  if discriminant < 0 then
    return inf, inf
  end
  dist1 = (-b + math.sqrt(discriminant)) / (2 * a)
  dist2 = (-b - math.sqrt(discriminant)) / (2 * a)
  return dist1, dist2
end

local function traceRay(origin, viewport_point, near, far, intersectors)
  closest_dist = inf
  closest_obj = nil
  for index, obj in ipairs(intersectors) do
    dist1, dist2 = intersectRaySphere(origin, viewport_point, obj)
    if dist1 > near and dist1 < far and dist1 < closest_dist then
      closest_dist = dist1
      closest_obj = obj
    end
    if dist2 > near and dist2 < far and dist2 < closest_dist then
      closest_dist = dist2
      closest_obj = obj
    end
  end
  if not closest_obj then
    return colors.black
  end
  return closest_obj.color
end

-- OBJECTS
spheres = {
  {
    center = vector.new(0, -1, 3),
    radius = 1,
    color = colors.red
  },
  {
    center = vector.new(2, 0, 4),
    radius = 1,
    color = colors.blue
  },
  {
    center = vector.new(-2, 0, 4),
    radius = 1,
    color = colors.green
  }
}

local function main()
  local display = peripheral.find("monitor")
  if not display then display = term.current() end
  term.redirect(display)

  local max_x, max_y = display.getSize()
  local min_x, min_y = 1, 1; -- TODO support craftos graphics mode
  local origin = vector.new(0, 0, 0)

  for x = min_x, max_x, 1 do
    for y = min_y, max_y, 1 do
      local viewport_point = canvasToDisplay(x, y, max_x, max_y)
      local color = traceRay(origin, viewport_point, 1, inf, spheres)
      paintutils.drawPixel(x, y, color)
    end
  end
end

main()
