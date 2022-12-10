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
  local min = 0
  -- craftos high resolution graphics mode starts at 0, 0 instead of 1, 1
  if (display.getGraphicsMode() > 0) then min = 0 else min = 1 end
  local vec3_origin = vector.new(0, 0, 0)

  -- Atkinson Dither
  -- this is how many rows of dither data we're keeping,
  -- equal to the y range of the dither matrix
  -- local diffusion_row_num = 3
  -- local diffusion_matrix = {
  --   { x = 1, y = 0, fraction = 1/8 },
  --   { x = 2, y = 0, fraction = 1/8 },
  --   { x = -1, y = 1, fraction = 1/8 },
  --   { x = 0, y = 1, fraction = 1/8 },
  --   { x = 1, y = 1, fraction = 1/8 },
  --   { x = 1, y = 2, fraction = 1/8 }
  -- }

  -- Floyd Steinberg Dither
  -- I'm removing 1 from the (1, 0) fraction
  -- spreading the full error causes artifacts?
  -- local diffusion_row_num = 2
  -- local diffusion_matrix = {
  --   { x = 1, y = 0, fraction = 6/16 },
  --   { x = -1, y = 1, fraction = 3/16 },
  --   { x = 0, y = 1, fraction = 5/16 },
  --   { x = 1, y = 1, fraction = 1/16 }
  -- }

  -- Jarvis-Judice-Ninke Dither
  -- quite modified cause of artifacts
  local diffusion_row_num = 3
  local diffusion_matrix = {
    { x = 1, y = 0, fraction = 6/48 },
    { x = 2, y = 0, fraction = 4/48 },
    { x = -2, y = 1, fraction = 2/48 },
    { x = -1, y = 1, fraction = 4/48 },
    { x = 0, y = 1, fraction = 6/48 },
    { x = 1, y = 1, fraction = 4/48 },
    { x = 2, y = 1, fraction = 2/48 },
    { x = -2, y = 2, fraction = 1/48 },
    { x = -1, y = 2, fraction = 2/48 },
    { x = 0, y = 2, fraction = 4/48 },
    { x = 1, y = 2, fraction = 2/48 },
    { x = 2, y = 2, fraction = 1/48 },
  }

  -- -- Sierra Simplified Dither
  -- local diffusion_row_num = 2
  -- local diffusion_matrix = {
  --   { x = 1, y = 0, fraction = 1/2 },
  --   { x = -1, y = 1, fraction = 1/4 },
  --   { x = 0, y = 1, fraction = 1/4 }
  -- }

  local curr_row = 0
  local diffusion_rows = {}
  -- initialize diffusion buffers
  for i = 1, diffusion_row_num, 1 do
    diffusion_rows[i] = {}
    for j = 1, max_x, 1 do
      diffusion_rows[i][j] = {}
      diffusion_rows[i][j].r = 0
      diffusion_rows[i][j].g = 0
      diffusion_rows[i][j].b = 0
    end
  end
  local r_diff = 0
  local g_diff = 0
  local b_diff = 0

  local closest_dist = math.huge
  local closest_index = 0
  local closest_id = 0
  local curr_dist = 0
  for y = 1, max_y, 1 do
    curr_row = y % diffusion_row_num
    if curr_row == 0 then curr_row = diffusion_row_num end
    for x = 1, max_x, 1 do
      local vec3_viewport_point = ray.displayToViewport(x, y, max_x, max_y, pixel_ratio)
      local h, s, v = ray.traceRay(vec3_origin, vec3_viewport_point, 1, inf, static.spheres, static.lights)
      local r, g, b = ray.HSVtoRGB(h, s, v)
      r = r + diffusion_rows[curr_row][x].r
      g = g + diffusion_rows[curr_row][x].g
      b = b + diffusion_rows[curr_row][x].b
      closest_dist = math.huge
      for index, color in ipairs(static.default_palette) do
        curr_dist = ray.euclideanDistance(r, g, b, color.r, color.g, color.b)
        if curr_dist < closest_dist then
          closest_dist = curr_dist
          closest_index = index
          closest_id = color.id
        end
      end
      r_diff = r - static.default_palette[closest_index].r
      g_diff = g - static.default_palette[closest_index].g
      b_diff = b - static.default_palette[closest_index].b
      --debug.debug()
      for index, cell in ipairs(diffusion_matrix) do
        local x_cell = x + cell.x
        local y_cell = (curr_row + cell.y) % diffusion_row_num
        if y_cell == 0 then y_cell = diffusion_row_num end
        if diffusion_rows[y_cell][x_cell] then
          diffusion_rows[y_cell][x_cell].r = diffusion_rows[y_cell][x_cell].r + (r_diff * cell.fraction)
          diffusion_rows[y_cell][x_cell].g = diffusion_rows[y_cell][x_cell].g + (g_diff * cell.fraction)
          diffusion_rows[y_cell][x_cell].b = diffusion_rows[y_cell][x_cell].b + (b_diff * cell.fraction)
        end
      end
      -- x - 1 + min offsets the image so we don't have an empty row and column in gfx mode
      paintutils.drawPixel(x - 1 + min, y - 1 + min, closest_id)
    end

    -- clear current diffusion buffer
    for i = 1, max_x, 1 do
      diffusion_rows[curr_row][i].r = 0
      diffusion_rows[curr_row][i].g = 0
      diffusion_rows[curr_row][i].b = 0
    end
  end

  -- waits for a key event to exit. Needed for craftos graphics mode, which immediately clears
  os.pullEvent("key")
end

main()
