require('scripts.global')
require('scripts.render.draw')

function remove(pixel)
    erase(pixel)

    global.all_pixels[global.current_surface.name][pixel.id] = nil
    global.redraw_queue.tiles[pixel.id] = nil
end

function on_pixel_removed(event)
    local pixel_id = event.entity.unit_number

    remove(global.all_pixels[global.current_surface.name][pixel_id])
end