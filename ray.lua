-- we're using the built-in computercraft vector type
-- COLORS

-- stolen from http://www.easyrgb.com/en/math.php
local function HSVtoRGB(h, s, v)
  local r = 0
  local g = 0
  local b = 0
  if s == 0 then
    r = v * 255
    g = v * 255
    b = v * 255
  else
    hue = h * 6
    if (hue == 6) then hue = 0 end
    i = math.floor(hue)
    v1 = v * (1 - s)
    v2 = v * (1 - s * (hue - 1))
    v3 = v * (1 - s * (1 - (hue - 1)))

    if (i == 0) then
      r = v
      g = v3
      b = v1
    elseif (i == 1) then
      r = v2
      g = v
      b = v1
    elseif (i == 2) then
      r = v1
      g = v
      b = v3
    elseif (i == 3) then
      r = v1
      g = v2
      b = v
    elseif (i == 4) then
      r = v3
      g = v1
      b = v
    else
      r = v
      g = v1
      b = v2
    end
  end
  return r * 255, g * 255, b * 255
end

-- you should've learned this in 7th grade geometry
local function euclideanDistance(x1, y1, z1, x2, y2, z2)
  return math.sqrt((x1 - x2)^2 + (y1 - y2)^2 + (z1 - z2)^2)
end

-- RAYTRACING
-- tranforms the display coordinates to the world coordinates of the viewport
local function displayToViewport(x, y, max_x, max_y, pixel_ratio)
  -- scales x by the ratio between the height and width of the screen
  -- divided by the ratio between pixel height and width
  return vector.new(x / max_x * (max_x / max_y) - (max_x / max_y / 2), (y / max_y * 2 - 1) / pixel_ratio, 1)
end


-- returns the intersections between a sphere and a ray
-- inf if it doesn't intersect
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


-- gathers lighting information for a point in the world
-- using a list of lights
local function calcLighting(vec3_point, vec3_normal, lights)
  local intensity = 0
  local vec3_light = nil -- needed for local scope
  for index, light in ipairs(lights) do
    if light.light_type == "ambient" then
      intensity = light.intensity + intensity
    else
      if light.light_type == "point" then
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


-- using the scene and camera information, traces a ray and returns a color index
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
    return 0, 0, 0
  end

  local vec3_intersect = vec3_origin:add(vec3_viewport_point:mul(closest_dist))
  local vec3_normal = vec3_intersect:sub(closest_obj.vec3_center)
  vec3_normal:normalize()
  local light_intensity = calcLighting(vec3_intersect, vec3_normal, lights)

  return closest_obj.hue, closest_obj.saturation, light_intensity
end

return {displayToViewport = displayToViewport,
        traceRay = traceRay,
        euclideanDistance = euclideanDistance,
        HSVtoRGB = HSVtoRGB}
