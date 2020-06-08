require('scripts.global')

local surface = global.current_surface.name
local pixels = global.all_pixels[surface]

-- fill out the new 'id' property
for _,pixel in pairs(pixels) do
    pixel.id = pixel.diode.unit_number
end