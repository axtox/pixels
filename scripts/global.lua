---Reference to the nauvis surface (only nauvis surface is available for now)
Surface = nil

---Array that stores all references to Pixels instances in the game
Pixels = nil

---List of pending pixels to update
Redraw_Queue = nil


--- Generate initial data
-- Creates global.all_pixels table for all surfaces
function initialize()
    global.all_pixels = {}
    for _,surface in pairs(game.surfaces) do
        global.all_pixels[surface.name] = {}
    end

    global.current_surface = game.surfaces[1]
    global.redraw_queue = { tiles = {} }

    setup_global_variables()
end

function setup_global_variables()
    --This is meant for 3 specific reasons and only 3:
        --re-register conditional event handlers
        --re-setup meta tables
        --create local references to tables stored in the global table
    Surface = global.current_surface
    Pixels = global.all_pixels[Surface.name]
    Redraw_Queue = global.redraw_queue
end