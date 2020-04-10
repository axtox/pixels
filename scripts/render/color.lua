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

local function is_same_color(color1, color2)
	return color1.r == color2.r and
	color1.g == color2.g and
	color1.b == color2.b
end

function get_color_name(color)
  --if color is nil then use default color
  color = color or Colors.default

  for color_name,constant_color in pairs(Colors) do
      if is_same_color(color, constant_color) then
          return color_name
      end
  end

  return "default"
end