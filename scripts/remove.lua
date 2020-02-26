function on_pixel_removed(event)

    local original_tile_name = Surface.get_hidden_tile(event.entity.position)

    Surface.set_tiles({{position = event.entity.position, name = original_tile_name}}, true)

    Surface.set_hidden_tile(event.entity.position, nil)

    Pixels[event.entity.unit_number] = nil
end