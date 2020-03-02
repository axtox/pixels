require('scripts.global')
require('scripts.build')
require('scripts.remove')
require('scripts.render.draw')
require('scripts.render.checkup')

--- Filter rules for Pixels
local pixel_event_filters=
{
    {
        filter = "name",
        name = "pixel"
    }
}

--- Registering game event handlers with filters

-- Creating pixels
script.on_event(defines.events.on_built_entity, on_pixel_built, pixel_event_filters)
script.on_event(defines.events.on_robot_built_entity, on_pixel_built, pixel_event_filters)

-- Removing pixels
script.on_event(defines.events.on_pre_player_mined_item, on_pixel_removed, pixel_event_filters)
script.on_event(defines.events.on_robot_pre_mined, on_pixel_removed, pixel_event_filters)
script.on_event(defines.events.on_entity_died, on_pixel_removed, pixel_event_filters)

-- Regular check
script.on_nth_tick(3, on_color_change_checkup)
script.on_nth_tick(4, on_redraw)

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