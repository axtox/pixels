require('scripts.global')

function redraw_changed()
    -- do a redraw
    Surface.set_tiles(Redraw_Queue.tiles, true)

    Redraw_Queue.tiles = {}
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
    redraw_changed()
end