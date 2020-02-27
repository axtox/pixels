--Colors enum
local colors = {
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

--required general properties for pixel tile
local base_tile = {
	collision_mask = {
		"ground-tile", "layer-14"
	},
	can_be_part_of_blueprint = false,
	decorative_removal_probability = 0.0,
	layer = 61,
	needs_correction = false,
	vehicle_friction_modifier = 1.6,
	walking_speed_modifier = 1.0,
}

--try to use user-defined tile for pixel
local user_tile_name = settings.startup["pixels-base-tile"].value
local origin_tile = data.raw.tile[user_tile_name]
if origin_tile == nil then
	origin_tile = data.raw.tile.concrete
end

--protect pixel tile from possible replacement by other placeble tiles (like concrete or hazard_concrete)
--find all placable items and force them to avoid layer-14 which pixel-tile uses
for _,item in pairs(data.raw.item) do
	if item.place_as_tile ~= nil and item.place_as_tile.condition ~= nil then
		table.insert(item.place_as_tile.condition, "layer-14")
	end
end

for color_name, color in pairs(colors) do
	--combine required tile properties with user-selected tile
	local tile = util.merge{origin_tile, base_tile}
	--prevent possibility to mine tile under pixel diode
	tile.minable = {mining_time = math.huge, count = 0}
	tile.name = "pixel-" .. color_name
	tile.map_color = color.map_color

	data:extend{tile}
end