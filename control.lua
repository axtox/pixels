--- This mod adds light-emmiting diods to the game.
-- The Pixel concept consist of a Diod (originally the Lamp)
-- and the colored tile under it. By replacing the tile based
-- on lamp color the pixels can be seen on the map in real-time.
-- Updates happening every 4 ticks, but on 3rd tick the regular
-- check-up happening. During this procedure, mod searches for
-- those pixels that changed thair color since last check-up
-- and add those to the Redraw_Queue which will be interated
-- on 4th tick and redrawn.
-- @author axtox
----
require('scripts.global')
require('scripts.build')
require('scripts.remove')
require('scripts.render.draw')
require('scripts.render.checkup')
require('scripts.debug')

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

-- Regular check and redraw
script.on_event(defines.events.on_tick, on_checkup)
--script.on_nth_tick(3, on_checkup)

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