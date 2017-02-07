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

data.raw["lamp"]["small-lamp"].flags = { "placeable-neutral", "player-creation", "not-on-map" }

for color_index, color in pairs(colors) do
	local tile = util.table.deepcopy(data.raw["tile"][defined_base_tile])
	tile.name = "lamp-" .. defined_base_tile .. "-map-" .. color_index
	tile.map_color = color.map_color
	data:extend({tile})
end