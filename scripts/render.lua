function on_regular_check(event)
    if event.tick % 3 == 0 then
        get_changed_pixels()
    end

    if event.tick % 4 == 0 then
        redraw()
    end
end

local changed = {}

function redraw()
    -- do a redraw
    Surface.set_tiles(changed, true)

    changed = {}
end

function get_changed_pixels()
    -- if color changed add to queue
    for _,pixel in pairs(Pixels) do
        local behavior = pixel.diode.get_control_behavior()
        if behavior ~= nil then
            --make sure we are using colors in Pixel
            behavior.use_colors = true
            
            local map_color_name = get_tile_name(pixel.diode.energy == 0
                                                    and Colors.black
                                                    or behavior.color)
            --game.print('energy ' .. pixel.diode.energy)
            if map_color_name ~= pixel.tile.name then

                --game.print(serpent.line(behavior.color))
                pixel.tile.name = map_color_name
                table.insert(changed, pixel.tile)
            end
        end
    end
end

function get_tile_name(color)
    return "pixel-" .. get_color_name(color)
end

function get_color_name(color)
    --if color is nil then use default color
    color = color or Colors.default

    for color_name,constant_color in pairs(Colors) do
        if color.r == constant_color.r and
        color.g == constant_color.g and
        color.b == constant_color.b then
            return color_name
        end
    end
    game.print(serpent.line(color))
    return "default"
end