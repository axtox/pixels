function on_regular_check(event)
    if event.tick % 60 == 0 then
        game.print(serpent.line(Pixels))
        --for _,pixel in pairs(Pixels) do
            --game.print(Surface.get_hidden_tile(pixel.position))
        --end
        --game.print(Surface.get_hidden_tile(Pixels[1].tile.old_tile.position))

    --global.current_surface.set_tiles({{position = global.all_pixels[global.current_surface.name][1].diode.position, name = "pixel-blue"}}, true)
    end
end
