--- Event handler
-- Starts update 
-- @param event Event handlers table
function on_pixel_built(event)
    --make pixel reference
    local pixel = {
        tile = {
            name = "pixel-default",
            position = event.created_entity.position
        },
        diode = event.created_entity
    }

    Surface.set_tiles({{position = pixel.diode.position, name = pixel.tile.name}}, true)

    Pixels[pixel.diode.unit_number] = pixel
end