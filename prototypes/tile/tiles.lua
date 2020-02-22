--Colors enum
colors = {
	["red"] = {
		map_color = {r = .9, g = .0, b = .0}
	},
	["green"] = {
		map_color = {r = .0, g = .9, b = .0}
	},
	["blue"] = {
		map_color = {r = .0, g = .0, b = .9}
	},
	["yellow"] = {
		map_color = {r = .9, g = .9, b = .0}
	},
	["pink"] = {
		map_color = {r = .9, g = 0, b = .6}
	},
	["cyan"] = {
		map_color = {r = 0, g = .9, b = .9}
	},
	["white"] = {
		map_color = {r = .9, g = .9, b = .9}
	},
	["grey"] = {
		map_color = {r = .5, g = .5, b = .5}
	},
	["black"] = {
		map_color = {r = .0, g = .0, b = .0}
	},
	["default"] = {
		map_color = {r = .2, g = .2, b = .5}
	}
}

base_tile = {
	collision_mask = {
		"ground-tile"
	},
	can_be_part_of_blueprint = false,
	decorative_removal_probability = 0.0,
	layer = 61,
	needs_correction = false,
	vehicle_friction_modifier = 1.6,
	walking_speed_modifier = 1.0
}

user_tile = settings.startup["pixels-base-tile"].value

-- checks if tile collision_mask has ground-tile option or not
function has_ground_collision(collision_mask)
	for _, mask in pairs(collision_mask) do
		if mask == "ground-tile" then
			return true
		end
	end
	return false
end

for color_index, color in pairs(colors) do

	local origin_tile = data.raw.tile[user_tile]
	if not has_ground_collision(origin_tile.collision_mask) then
		origin_tile = data.raw.tile.concrete
	end

	local tile = util.merge{origin_tile, base_tile}
	tile.name = "lamp-" .. user_tile .. "-map-" .. color_index
	tile.map_color = color.map_color

	data:extend({tile})
end