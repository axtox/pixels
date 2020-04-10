require('scripts.global')
require('scripts.render.draw')

function on_pixel_removed(event)
    local pixel_id = event.entity.unit_number

    erase(Pixels[pixel_id])

    Pixels[pixel_id] = nil
    Redraw_Queue.tiles[pixel_id] = nil
end