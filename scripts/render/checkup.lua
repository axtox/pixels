require('scripts.global')
require('scripts.render.draw')

--- Obtain the map color name to paint the pixel on map
-- Generates the tile name for the given color if the color
-- is correct and the requirement is met (electricity is not 0)
-- @param pixel Pixel that we need to display on the map
-- @param color Color that Pixel is supposed to be displayed
-- @return Returns tile name for the given color that should be placed under Pixel
local function get_map_color(pixel, color)
  -- if there's no electricity in diode then set color to Colors.black
  local color = pixel.diode.energy == 0 and Colors.black or color

  return get_tile_name(color)
end

--- Adds pixel to Redraw_Queue which will be used during the redraw procedure
-- @param pixel Pixel that needs to be redrawn on the map
-- @param color New color that Pixel is supposed to be displayed with
-- @see Redraw_Queue
local function add_to_redraw_queue(pixel, color)
  local map_color_name = get_map_color(pixel, color)

  -- add pixel to redraw queue only if color has been changed
  if map_color_name ~= pixel.tile.name then
      pixel.tile.name = map_color_name
      Redraw_Queue.tiles[pixel.diode.unit_number] = pixel.tile
  end
end

function scan_changed_pixels()

  local id, pixel
  for i = 1, 350, 1 do
    -- get next pixel
    id, pixel = next(Pixels, Redraw_Queue.last_updated_pixel_id)
    if pixel == nil then
      id, pixel = next(Pixels, nil)
    end

    local behavior = pixel.diode.get_control_behavior()
    if behavior ~= nil then

      --make sure we are using colors in Pixel
      behavior.use_colors = true

      add_to_redraw_queue(pixel, behavior.color)
    else
      add_to_redraw_queue(pixel, Colors.white)
    end

    Redraw_Queue.last_updated_pixel_id = id
  end
end