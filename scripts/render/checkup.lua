require('scripts.global')
require('scripts.render.color')

local function find_changed_pixels()
  -- if color changed add to queue
  for _,pixel in pairs(Pixels) do
      local behavior = pixel.diode.get_control_behavior()
      if behavior ~= nil then
          --make sure we are using colors in Pixel
          behavior.use_colors = true
          
          local map_color_name = get_tile_name(pixel.diode.energy == 0
                                                  and Colors.black
                                                  or behavior.color)
          --game.print('energy ' .. pixel.diode.energy)
          if map_color_name ~= pixel.tile.name then

              --game.print(serpent.line(behavior.color))
              pixel.tile.name = map_color_name
              table.insert(Redraw_Queue.tiles, pixel.tile)
          end
      end
  end
end

function on_color_change_checkup(event)
  find_changed_pixels()
end