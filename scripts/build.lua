require('scripts.global')
require('scripts.render.color')

--- Event handler
-- Starts update 
-- @param event Event handlers table
function on_pixel_built(event)
    --make pixel reference
    local pixel = {
        id = event.created_entity.unit_number,
        tile = {
            name = get_tile_name(Colors.default),
            position = event.created_entity.position
        },
        diode = event.created_entity
    }

    draw(pixel)

    global.all_pixels[global.current_surface.name][pixel.id] = pixel
end