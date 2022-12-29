local spheres = {
  {
    vec3_center = vector.new(0, 1, 3),
    radius = 1,
    hue = 0.5,
    saturation = 0.6,
    specular = 1000,
  },
  {
    vec3_center = vector.new(2, 0, 4),
    radius = 1,
    hue = 0.1,
    saturation = 0.4,
    specular = 500,
  },
  {
    vec3_center = vector.new(-3, 1, 4),
    radius = 1,
    hue = 0.7,
    saturation = 0.4,
    specular = 10,
  },
 {
   vec3_center = vector.new(0, 502, 10),
   radius = 500,
   hue = 0.4,
   saturation = 1,
   specular = 0,
 }
}

local lights = {
  {
    light_type = "ambient",
    intensity = 0.2,
  },
  {
    light_type = "point",
    intensity = 0.3,
    vec3_position = vector.new(1, -1, -1)
  },
  {
    light_type = "directional",
    intensity = 0.5,
    vec3_direction = vector.new(10, -20, 15)
  }
}

local default_palette = {
  {id = 1, r = 240, g = 240, b = 240, h = 0, s = 0, v = 0.941},
  {id = 2, r = 242, g = 178, b = 51, h = 0.111, s = 0.789, v = 0.949},
  {id = 4, r = 229, g = 127, b = 216, h = 0.854, s = 0.445, v = 0.898},
  {id = 8, r = 153, g = 178, b = 242, h = 0.62, s = 0.368, v = 0.949},
  {id = 16, r = 222, g = 222, b = 108, h = 0.167, s = 0.514, v = 0.871},
  {id = 32, r = 127, g = 204, b = 25, h = 0.238, s = 0.877, v = 0.8},
  {id = 64, r = 242, g = 178, b = 204, h = 0.932, s = 0.264, v = 0.949},
  {id = 128, r = 76, g = 76, b = 76, h = 0, s = 0, v = 0.298},
  {id = 256, r = 153, g = 153, b = 153, h = 0, s = 0, v = 0.6},
  {id = 512, r = 76, g = 153, b = 178, h = 0.541, s = 0.573, v = 0.698},
  {id = 1024, r = 178, g = 102, b = 229, h = 0.766, s = 0.555, v = 0.898},
  {id = 2048, r = 51, g = 102, b = 204, h = 0.611, s = 0.75, v = 0.8},
  {id = 4096, r = 127, g = 102, b = 76, h = 0.085, s = 0.402, v = 0.498},
  {id = 8192, r = 87, g = 166, b = 78, h = 0.316, s = 0.53, v = 0.651},
  {id = 16384, r = 204, g = 76, b = 76, h = 0, s = 0.627, v = 0.8},
  {id = 32768, r = 17, g = 17, b = 17, h = 0, s = 0, v = 0.067},
}

-- I looked at various ways to generate this
-- then I stole it from wikipedia
local bayer4x4 = {
  {0.0625, 0.5625, 0.18;75, 0.6875},
  {0.8125, 0.3125, 0.9375, 0.4375},
  {0.25, 0.75, 0.125, 0.625},
  {1, 0.5, 0.875, 0.375}
}

local custom_palette = {}

return {spheres = spheres,
        lights = lights,
        default_palette = default_palette,
        custom_palette = custom_palette,
        bayer4x4 = bayer4x4}
