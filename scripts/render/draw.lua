require('scripts.global')
require('scripts.render.color')

function get_tile_name(color)
    return "pixel-" .. get_color_name(color)
end

function draw(pixel)
    Surface.set_tiles({ pixel.tile }, true)
end

function erase(pixel)
    local original_tile_name = Surface.get_hidden_tile(pixel.tile.position)

    Surface.set_tiles({{position = pixel.tile.position, name = original_tile_name}}, true)

    Surface.set_hidden_tile(pixel.tile.position, nil)
end

function on_redraw(event)
    -- do a redraw
    Surface.set_tiles(Redraw_Queue.tiles, true)

    Redraw_Queue.tiles = {}
end