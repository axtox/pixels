require('scripts.global')
require('scripts.render.color')

function get_tile_name(color)
    return "pixel-" .. get_color_name(color)
end

function draw(pixel)
    global.current_surface.set_tiles({ pixel.tile }, true)
end

function erase(pixel)
    local original_tile_name = global.current_surface.get_hidden_tile(pixel.tile.position)

    global.current_surface.set_tiles({{position = pixel.tile.position, name = original_tile_name}}, true)

    global.current_surface.set_hidden_tile(pixel.tile.position, nil)
end

function on_redraw(event)
    -- do a redraw
    global.current_surface.set_tiles(global.redraw_queue.tiles, true)

    global.redraw_queue.tiles = {}
end