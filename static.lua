local spheres = {
  {
    vec3_center = vector.new(0, 1, 3),
    radius = 1,
    hue = 0.5,
    saturation = 0.6,
  },
  {
    vec3_center = vector.new(2, 0, 4),
    radius = 1,
    hue = 0.1,
    saturation = 0.4,
  },
  {
    vec3_center = vector.new(-3, 1, 4),
    radius = 1,
    hue = 0.7,
    saturation = 0.4,
  },
 {
   vec3_center = vector.new(0, 502, 10),
   radius = 500,
   hue = 0.4,
   saturation = 0.5
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
  {id = 1, r = 240, b = 240, g = 240},
  {id = 2, r = 242, b = 178, g = 51},
  {id = 4, r = 229, b = 127, g = 216},
  {id = 8, r = 153, b = 178, g = 242},
  {id = 16, r = 222, b = 222, g = 108},
  {id = 32, r = 127, b = 204, g = 25},
  {id = 64, r = 242, b = 178, g = 204},
  {id = 128, r = 76, b = 76, g = 76},
  {id = 256, r = 153, b = 153, g = 153},
  {id = 512, r = 76, b = 153, g = 178},
  {id = 1024, r = 178, b = 102, g = 229},
  {id = 2048, r = 51, b = 102, g = 204},
  {id = 4096, r = 127, b = 102, g = 76},
  {id = 8192, r = 87, b = 166, g = 78},
  {id = 16384, r = 204, b = 76, g = 76},
  {id = 32768, r = 17, b = 17, g = 17},
}

-- I looked at various ways to generate this
-- then I stole it from wikipedia
local bayer4x4 = {
  {0.0625, 0.5625, 0.1875, 0.6875},
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
