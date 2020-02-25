Surface = nil
Pixels = nil

--- Event handler
-- Starts update 
-- @param event Event handlers table
function on_pixel_built(event) 
    --make pixel reference
    local pixel = {
        tile = {
            name = "pixel-default"
        },
        diode = event.created_entity
    }

    Surface.set_tiles({{position = pixel.diode.position, name = pixel.tile.name}}, true)

    Pixels[pixel.diode.unit_number] = pixel
end

function on_pixel_removed(event)

    local original_tile_name = Surface.get_hidden_tile(event.entity.position)

    Surface.set_tiles({{position = event.entity.position, name = original_tile_name}}, true)

    Surface.set_hidden_tile(event.entity.position, nil)

    Pixels[event.entity.unit_number] = nil
end

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


--- Generate initial data
-- Creates global.all_pixels table for all surfaces
function initialize()
    global.all_pixels = {}
    for _,surface in pairs(game.surfaces) do
        global.all_pixels[surface.name] = {}
    end

    global.current_surface = game.surfaces[1]


    Surface = global.current_surface
    Pixels = global.all_pixels
end

function setup_global_variables() 
    --This is meant for 3 specific reasons and only 3:
        --re-register conditional event handlers
        --re-setup meta tables
        --create local references to tables stored in the global table
    Surface = global.current_surface
    Pixels = global.all_pixels
end


-- Filter event raising for mod's entities
local pixel_event_filters={{filter = "name", name = "pixel"}}

script.set_event_filter(defines.events.on_built_entity, pixel_event_filters)
script.set_event_filter(defines.events.on_robot_built_entity, pixel_event_filters)

script.set_event_filter(defines.events.on_pre_player_mined_item, pixel_event_filters)
script.set_event_filter(defines.events.on_robot_pre_mined, pixel_event_filters)
script.set_event_filter(defines.events.on_entity_died, pixel_event_filters)

script.set_event_filter(defines.events.on_marked_for_deconstruction, pixel_event_filters)
script.set_event_filter(defines.events.on_cancelled_deconstruction, pixel_event_filters)

-- Game event handlers
script.on_event(defines.events.on_built_entity, on_pixel_built)

script.on_event(defines.events.on_pre_player_mined_item, on_pixel_removed)

script.on_event(defines.events.on_tick, on_regular_check)

script.on_init(initialize)
script.on_load(setup_global_variables)

--[[ TODO
on_surface_cleared	Called just after a surface is cleared (all entities removed and all chunks deleted).
on_surface_created	Called when a surface is created.
on_surface_deleted	Called after a surface is deleted.
on_surface_imported	Called after a surface is imported.
on_surface_renamed
on_pre_surface_cleared	Called just before a surface is cleared (all entities removed and all chunks deleted).
on_pre_surface_deleted
on_player_changed_surface
]]

--[[ OLD
script.on_init(on_initialize)
script.on_load(on_loading)  This is meant for 3 specific reasons and only 3:

    re-register conditional event handlers
    re-setup meta tables
    create local references to tables stored in the global table

script.on_event(defines.events.on_built_entity, on_build_lamp)
script.on_event(defines.events.on_robot_built_entity, on_build_lamp)
script.on_event(defines.events.on_preplayer_mined_item, on_mined_lamp)
script.on_event(defines.events.on_robot_pre_mined, on_mined_lamp)
script.on_event(defines.events.on_entity_died, on_mined_lamp)
script.on_event(defines.events.on_tick, on_regular_checking)
script.on_event(defines.events.on_player_built_tile, on_another_tile_build)
script.on_event(defines.events.on_robot_built_tile, on_another_tile_build)
on_marked_for_deconstruction

type LuaEntityDiedEventFilters
type LuaEntityMarkedForDeconstructionEventFilters
type LuaPreRobotMinedEntityEventFilters
type LuaRobotMinedEntityEventFilters
type LuaPrePlayerMinedEntityEventFilters
type LuaRobotBuiltEntityEventFilters
type LuaEntityDeconstructionCancelledEventFilters
type LuaPlayerBuiltEntityEventFilters
type LuaPlayerMinedEntityEventFilters
]]--


---
--[[function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end]]