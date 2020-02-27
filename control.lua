require('scripts.global')
require('scripts.build')
require('scripts.remove')
require('scripts.render')

--- Filter rules for Pixels
local pixel_event_filters=
{
    {
        filter = "name",
        name = "pixel"
    }
}

--[[- Filter event invocation for mod's entities
-- Creating pixels
script.set_event_filter(defines.events.on_built_entity, pixel_event_filters)
script.set_event_filter(defines.events.on_robot_built_entity, pixel_event_filters)
-- Removing pixels
script.set_event_filter(defines.events.on_pre_player_mined_item, pixel_event_filters)
script.set_event_filter(defines.events.on_robot_pre_mined, pixel_event_filters)
script.set_event_filter(defines.events.on_entity_died, pixel_event_filters)
-- Deconstructing pixels
script.set_event_filter(defines.events.on_marked_for_deconstruction, pixel_event_filters)
script.set_event_filter(defines.events.on_cancelled_deconstruction, pixel_event_filters)]]


--- Registering game event handlers
-- Creating pixels
script.on_event(defines.events.on_built_entity, on_pixel_built, pixel_event_filters)
-- Removing pixels
script.on_event(defines.events.on_pre_player_mined_item, on_pixel_removed, pixel_event_filters)
-- Regular check
script.on_event(defines.events.on_tick, on_regular_check)
-- Initialization
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

]]--


---
--[[function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end]]