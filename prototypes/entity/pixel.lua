--create Pixel entity from small-lamp
local pixel = util.copy(data.raw.lamp['small-lamp'])
pixel.name = 'pixel'
pixel.minable = { mining_time = 0.1, result = 'pixel' }
pixel.flags = { 'placeable-neutral', 'player-creation', 'not-on-map' }

--create Pixel Item
local item = util.copy(data.raw.item['small-lamp'])
item.name = 'pixel'
item.place_result = 'pixel'

--create recipe for Pixel
local recipe = util.copy(data.raw.recipe['small-lamp'])
recipe.name = 'pixel'
recipe.result = 'pixel'

--add Pixel to Optics technology
local technology = data.raw.technology.optics
table.insert(technology.effects, {type = 'unlock-recipe', recipe = 'pixel'} )

data:extend{pixel, item, recipe}