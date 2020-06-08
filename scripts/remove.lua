require('scripts.global')
require('scripts.render.draw')

function remove(pixel)
    erase(pixel)

    Pixels[pixel.id] = nil
    Redraw_Queue.tiles[pixel.id] = nil
end

function on_pixel_removed(event)
    local pixel_id = event.entity.unit_number

    remove(Pixels[pixel_id])
end