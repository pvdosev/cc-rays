local spheres = {
  {
    vec3_center = vector.new(0, -1, 3),
    radius = 1,
    hue = 0.5,
    saturation = 0.7,
  },
  {
    vec3_center = vector.new(2, 0, 4),
    radius = 1,
    hue = 0.1,
    saturation = 1,
  },
  {
    vec3_center = vector.new(-2, 0, 4),
    radius = 1,
    hue = 0.9,
    saturation = 0.3,
  }
}

local lights = {
  {
    light_type = "ambient",
    intensity = 0.1
  },
  {
    light_type = "point",
    intensity = 0.4,
    vec3_position = vector.new(2, 1, 3)
  },
  {
    light_type = "directional",
    intensity = 0.5,
    vec3_direction = vector.new(4, -5, -1)
  }
}

local default_colors = {

}

local custom_colors = {
  {

  }
}

local static = {spheres = spheres, lights = lights, default_colors = default_colors, custom_colors = custom_colors}

return static
