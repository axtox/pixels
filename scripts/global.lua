
---Reference to the nauvis surface (only nauvis surface is available for now)
Surface = nil

---Array that stores all references to Pixels instances in the game
Pixels = nil

---Table consists of all supported colors for Pixels
Colors = {
	["red"] = {
		r = 1.0, g = .0, b = .0
	},
	["green"] = {
		r = .0, g = 1.0, b = .0
	},
	["blue"] = {
		r = .0, g = .0, b = 1.0
	},
	["yellow"] = {
		r = 1.0, g = 1.0, b = .0
	},
	["pink"] = {
		r = 1.0, g = 0, b = 1.0
	},
	["cyan"] = {
		r = 0, g = 1.0, b = 1.0
	},
	["white"] = {
		r = 1.0, g = 1.0, b = 1.0
	},
	["grey"] = {
		r = .5, g = .5, b = .5
	},
	["black"] = {
		r = .0, g = .0, b = .0
	},
	["default"] = {
	    r = 1, g = 1, b = 1
	}
}


--- Generate initial data
-- Creates global.all_pixels table for all surfaces
function initialize()
    global.all_pixels = {}
    for _,surface in pairs(game.surfaces) do
        global.all_pixels[surface.name] = {}
    end

    global.current_surface = game.surfaces[1]


    Surface = global.current_surface
    Pixels = global.all_pixels[Surface.name]
end

function setup_global_variables()
    --This is meant for 3 specific reasons and only 3:
        --re-register conditional event handlers
        --re-setup meta tables
        --create local references to tables stored in the global table
    Surface = global.current_surface
    Pixels = global.all_pixels[Surface.name]
end