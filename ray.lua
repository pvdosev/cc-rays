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
  -- this could be a 2d vector transformation but the vector library doesn't support 2d vectors
  return vector.new(x / max_x * (max_x / max_y) - (max_x / max_y / 2), (y / max_y * 2 - 1) / pixel_ratio, 1)
end


-- returns the intersections between a sphere and a ray
-- inf if it doesn't intersect
local function intersectRaySphere(vec3_origin, vec3_direction, sphere)
  local radius = sphere.radius
  local vec3_co = vec3_origin - sphere.vec3_center

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

-- return closest intersection between a ray and a list of spheres
local function findClosestIntersection(vec3_origin, vec3_direction, near, far, intersectors)
  local closest_dist = inf
  local closest_obj = nil
  for index, obj in ipairs(intersectors) do
    local dist1, dist2 = intersectRaySphere(vec3_origin, vec3_direction, obj)
    if dist1 > near and dist1 < far and dist1 < closest_dist then
      closest_dist = dist1
      closest_obj = obj
    end
    if dist2 > near and dist2 < far and dist2 < closest_dist then
      closest_dist = dist2
      closest_obj = obj
    end
  end
  return closest_dist, closest_obj
end

-- gathers lighting information for a point in the world
-- using a list of lights
local function calcLighting(vec3_point, vec3_normal, vec3_view_dir, specular, intersectors, lights)
  local intensity = 0
  local vec3_light_dir = nil -- needed for local scope
  for index, light in ipairs(lights) do
    if light.light_type == "ambient" then
      intensity = light.intensity + intensity
    else
      if light.light_type == "point" then
        vec3_light_dir = light.vec3_position - vec3_point
      else -- light is directional
        vec3_light_dir = light.vec3_direction
      end

      -- check for shadows
      shadow_dist, shadow_obj =
        findClosestIntersection(vec3_point, vec3_light_dir, 0.001, math.huge, intersectors)
      if not shadow_obj then

        -- diffuse calculation
        local n_dot_l = vec3_light_dir:dot(vec3_normal)
        if n_dot_l > 0 then
          intensity = intensity + light.intensity * n_dot_l / (vec3_light_dir:length() * vec3_normal:length())
        end

        if specular ~= 0 then
          -- a vector symmetric to the light direction through the normal
          local vec3_reflection = vec3_normal * vec3_normal:dot(vec3_light_dir) * 2 - vec3_light_dir
          -- how closely aligned the view direction is with the reflection
          local r_dot_v = vec3_reflection:dot(vec3_view_dir)
          if r_dot_v > 0 then
            -- add the cosine of the reflection and view angles to the intensity.
            -- the closer the two vectors are the higher it is. it is scaled by the specular,
            -- causing a sharper falloff
            intensity = intensity +
              light.intensity * (r_dot_v / (vec3_reflection:length() * vec3_view_dir:length())) ^ specular
          end
        end
      end
    end
  end
  return intensity
end

-- using the scene and camera information, traces a ray and returns a color index
local function traceRay(vec3_origin, vec3_viewport_point, near, far, intersectors, lights)
  local closest_dist, closest_obj =
    findClosestIntersection(vec3_origin, vec3_viewport_point, near, far, intersectors)
  if not closest_obj then
    return 0, 0, 0
  end

  local vec3_intersect = vec3_origin + vec3_viewport_point * closest_dist
  local vec3_normal = vec3_intersect - closest_obj.vec3_center
  -- TODO we should really be passing the whole color into this
  local light_intensity =
    calcLighting(
      vec3_intersect,
      vec3_normal:normalize(),
      -vec3_intersect,
      closest_obj.specular,
      intersectors,
      lights
    )

  return closest_obj.hue, closest_obj.saturation, light_intensity
end

return {displayToViewport = displayToViewport,
        traceRay = traceRay,
        euclideanDistance = euclideanDistance,
        HSVtoRGB = HSVtoRGB}
