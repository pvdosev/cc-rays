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

local function intersectRaySphere(vec3_origin, vec3_direction, sphere)
  local radius = sphere.radius
  local vec3_co = vec3_origin:sub(sphere.vec3_center)

  -- construct a quadratic equation to find intersections
  local a = vec3_direction:dot(vec3_direction) -- the length of the vector
  local b = 2 * vec3_direction:dot(vec3_co)
  local c = vec3_co:dot(vec3_co) - radius * radius
  local discriminant = (b * b) - (4 * a * c)
  if discriminant < 0 then
    return inf, inf
  end
  local dist1 = (-b + math.sqrt(discriminant)) / (2 * a)
  local dist2 = (-b - math.sqrt(discriminant)) / (2 * a)
  return dist1, dist2
end

local function calcLighting(vec3_point, vec3_normal, lights)
  local intensity = 0
  local vec3_light = nil -- needed for local scope
  for index, light in ipairs(lights) do
    if light.lightType == "ambient" then
      intensity = light.intensity + intensity
    else
      if light.lightType == "point" then
        vec3_light = light.vec3_position:sub(vec3_point)
      else -- light is directional
        vec3_light = light.vec3_direction
      end
      local n_dot_l = vec3_light:dot(vec3_normal)
      if n_dot_l > 0 then
        intensity = intensity + light.intensity * n_dot_l / (vec3_light:length() * vec3_normal:length())
      end
    end
  end
  return intensity
end

local function traceRay(vec3_origin, vec3_viewport_point, near, far, intersectors, lights)
  local closest_dist = inf
  local closest_obj = nil
  for index, obj in ipairs(intersectors) do
    local dist1, dist2 = intersectRaySphere(vec3_origin, vec3_viewport_point, obj)
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

  local vec3_intersect = vec3_origin:add(vec3_viewport_point:mul(closest_dist))
  local vec3_normal = vec3_intersect:sub(closest_obj.vec3_center)
  vec3_normal:normalize()
  light_intensity = calcLighting(vec3_intersect, vec3_normal, lights)
  if light_intensity > 0.5 then
    return closest_obj.color
  else
    return colors.black
  end
end

-- OBJECTS
spheres = {
  {
    vec3_center = vector.new(0, -1, 3),
    radius = 1,
    color = colors.red
  },
  {
    vec3_center = vector.new(2, 0, 4),
    radius = 1,
    color = colors.blue
  },
  {
    vec3_center = vector.new(-2, 0, 4),
    radius = 1,
    color = colors.green
  }
}

lights = {
  {
    lightType = "ambient",
    intensity = 0.15
  },
  {
    lightType = "point",
    intensity = 0.65,
    vec3_position = vector.new(2, 1, 0)
  },
  {
    lightType = "directional",
    intensity = 0.2,
    vec3_direction = vector.new(1, 4, 4)
  }
}

customColors = {
  lightRed = 0;
  light
}

local function main()
  local display = peripheral.find("monitor")
  if not display then display = term.current() end
  term.redirect(display)

  local max_x, max_y = display.getSize()
  local min_x, min_y = 1, 1; -- TODO support craftos graphics mode
  local vec3_origin = vector.new(0, 0, 0)
  periphemu.create("left", "debugger")

  for x = min_x, max_x, 1 do
    for y = min_y, max_y, 1 do
      local vec3_viewport_point = canvasToDisplay(x, y, max_x, max_y)
      local color = traceRay(vec3_origin, vec3_viewport_point, 1, inf, spheres, lights)
      paintutils.drawPixel(x, y, color)
    end
  end
end

main()
