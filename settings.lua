--tile prototype name that will be placed under lamp. WARNING - if you change this value you need to reload game.
--defined_base_tile = "concrete"

--number of lamps to update each iteration. Tested and default is 70 
--defined_lamps_per_iteration = 70

--refresh iteration frequency in ticks. Default is each 4th tick. Must be more than 2 because draw iteration starts on next tick. For example - if you update lamps in every 4th tick, then draw on map happens on every 5th tick and so on. You don't want to draw and update in same tick, otherwise there'll be lags.
--defined_iteration_frequency = 4

data:extend({
    {
        type = "string-setting",
        name = "pixels-base-tile",
        setting_type = "startup",
        default_value = "concrete",
        allowed_values = {"concrete", "grass-1"}
    }
})