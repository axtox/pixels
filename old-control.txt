require "config"

--properties
 --ColoredLampEntity that need to be redrawn on map
global_pending_changes = {} -- to global candidate

--debug
_pairs = pairs
function pairs (value)
	if type(value) == "userdata" then
		local t1 = {}
		local g = getmetatable(value)
		if g == nil then
			setmetatable(value, t1)
			g = getmetatable(value)
		end
		return g.__pairs(value)
	else
		return _pairs(value) -- original
	end
end

--helpers functions
-- table lengh - to be adjusted/deleted
function table_length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
-- table lengh - for debug only to be deleted
function table_length_1(T)
	local count, is_same = 0, false
	for _,__t in pairs(T) do 
		for ___ in pairs(__t) do
			count = count + 1
		end
	end
	return count
end
-- table lengh - for debug only to be deleted
function table_length_2(T)
	local count, is_same = 0, false
	for _,__t in pairs(T) do 
		for ___, ___t in pairs(__t) do
			for ____ in pairs(___t) do
				count = count + 1
			end
		end
	end
	return count
end
-- debug
function print_table(object)
	for key,value in pairs(object) do
		print("found member " .. key .. " with " .. tostring(value))
	end
end

--- Prints text to global game chat
-- @param text String which will be displayed to all players
function print(text)
	game.print(text)
end

function table.removeKey(t, k)
	local i = 0
	local keys, values = {},{}
	for k,v in pairs(t) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end

	while i>0 do
		if keys[i] == k then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end

	local a = {}
	for i = 1,#keys do
		a[keys[i]] = values[i]
	end

	return a
end

-- GLOBAL

--coroutines
main_coroutine = coroutine.create(function(start_index, surface_name)
	local is_coroutine_active = true
	while is_coroutine_active do
		local count, end_index = 1, {}
		for colored_lamp_entity_index, colored_lamp_entity in next,global.lamps_dictionary[surface_name], start_index do
			if count > defined_lamps_per_iteration then break end
			end_index = colored_lamp_entity_index
			if colored_lamp_entity.entity.valid then
				update_lamp_in_dictionary(colored_lamp_entity.entity, colored_lamp_entity.tile.original_tile_name)
			end
			count = count + 1
		end
		if count <= defined_lamps_per_iteration then 
			end_index = nil
		end
		start_index, surface_name = coroutine.yield(end_index)
	end
end)
last_coroutine_index = {}

draw_coroutine = coroutine.create(function(lamps_for_update, surface_name)
	local is_coroutine_active = true
	while is_coroutine_active do
		if lamps_for_update ~= nil then
			local lua_tile_array = {}
			for _, colored_lamp in pairs(lamps_for_update) do
				if colored_lamp.entity.valid then
					table.insert(lua_tile_array, { name = colored_lamp.tile.new_tile_name, position = colored_lamp.tile.position })
				end
			end
			game.surfaces[surface_name].set_tiles(lua_tile_array, true)
			for _, force_name in next, get_forces_to_update(), nil do
				for __, tile_item in next, lua_tile_array, nil do
					if not game.forces[force_name].is_chunk_charted(game.surfaces[surface_name], tile_item.position) then
						game.forces[force_name].chart(game.surfaces[surface_name], {tile_item.position,tile_item.position})
					end
				end
			end
		end
		lamps_for_update, surface_name = coroutine.yield(nil)
	end
end)

--[[save_coroutine = coroutine.create(function(colored_lamp_entity_index, colored_lamp_entity)
	local is_coroutine_active = true
	while is_coroutine_active do
		local start_index = nil
		global.lamps_dictionary = nil --make GC know that we don't need old table anymore
		global.lamps_dictionary = {}
		for surface_name,lamps_on_surface in next,global.lamps_dictionary, nil do
			global.lamps_dictionary[surface_name] = {}
			local number_of_iterations = math.ceil(table_length(lamps_on_surface) / 200) --200 objects in array is maximum for factorio serialization mechanism
			for index=1,number_of_iterations do
				local count = 1
				global.lamps_dictionary[surface_name][index] = {}
				for colored_lamp_entity_index, colored_lamp_entity in next,lamps_on_surface, start_index do
					if count > 200 then 
						break 
					elseif count == 200 then
						start_index = colored_lamp_entity_index
					end
					global.lamps_dictionary[surface_name][index][count] = 
					{
						colored_lamp_entity_index, 
						colored_lamp_entity 
					}
					count = count + 1
				end
				--start_index = start_index + counttable_length_1(global.lamps_dictionary)
			end
		end
		print("Lamps On Map has been saved")
	end
end)]]

--enumerations
 --Wire types enum
circuit_wires_types = {
	defines.wire_type.red, 
	defines.wire_type.green 
}

 --Virtual signals enum
 --TODO: made it generic (more colors can be added by factorio team or mod community)
virtual_signals = {
	["red"] = {
		name = "signal-red",
		type = "virtual-signal",
		priority = 1,
		color = "red"
	},
	["green"] = {
		name = "signal-green",
		type = "virtual-signal",
		priority = 2,
		color = "green"
	},
	["blue"] = {
		name = "signal-blue",
		type = "virtual-signal",
		priority = 3,
		color = "blue"
	},
	["yellow"] = {
		name = "signal-yellow",
		type = "virtual-signal",
		priority = 4,
		color = "yellow"
	},
	["pink"] = {
		name = "signal-pink",
		type = "virtual-signal",
		priority = 5,
		color = "pink"
	},
	["cyan"] = {
		name = "signal-cyan",
		type = "virtual-signal",
		priority = 6,
		color = "cyan"
	},
	["white"] = {
		name = "signal-white",
		type = "virtual-signal",
		priority = 7,
		color = "white"
	},
	["grey"] = {
		name = "signal-grey",
		type = "virtual-signal",
		priority = 8,
		color = "grey"
	},
	["black"] = {
		name = "signal-black",
		type = "virtual-signal",
		priority = 9,
		color = "black"
	}
}

 --LampTile class for item in lamp dictionary
LampTile = {}
LampTile.__index = LampTile
setmetatable(LampTile, {
	__call = function (cls, position, color, original_tile_name)
		local self = setmetatable({}, cls)
		self:_init(position, color, original_tile_name)
		return self
	end,
})
 --LampTile constructor
function LampTile:_init(position, color, original_tile_name)
	self.position = position
	self.color = color
	self.original_tile_name = original_tile_name
	self.new_tile_name = generate_lamp_tile_name(color)
end

 --ColoredLampEntity class for item in lamp dictionary
ColoredLampEntity = {}
ColoredLampEntity.__index = ColoredLampEntity
setmetatable(ColoredLampEntity, {
	__call = function (cls, entity, LampTile)
		local self = setmetatable({}, cls)
		self:_init(entity, LampTile)
		return self
	end,
})
  --ColoredLampEntity constructor
function ColoredLampEntity:_init(entity, LampTile)
	self.entity = entity
	self.tile = LampTile
end

--- Generates special tile prototype name for given color
-- All lamps can be seen on map only by adding tile under them - this method
-- helps us retrieve name of current color tile prototype.
-- @param color_name Name of the color which tile need to be retrieved
-- @return String with given pattern 'lamp-[base_tile_from_settings]-map-[color_name]'.
-- Example: Given color is 'grey' and base tile is 'grass', generated tile prototype 
-- name will be lamp-grass-map-grey
function generate_lamp_tile_name(color_name)
	return "lamp-" .. defined_base_tile .. "-map-" .. color_name
end

--special encoding for digit representation of positon coordinates (string is longer to iterate)
-- function encode_lamp_coordinates_index(x,y)
-- 	return string.gsub(x, "%.5", "") .. "." .. string.gsub(y, "%.5", "")
-- end

--[[function decode_lamp_coordinates_index(index)
    local string_number = tostring(index)
	local split_start_index, split_end_index = string.find(string_number, '%.')
	local x,y = tonumber(string.sub(string_number, 1, split_start_index - 1) .. ".5"), tonumber(string.sub(string_number, split_start_index + 1) .. ".5")
	return {["x"]=x,["y"]=y}
end]]

function get_surfaces_to_update()
	local only_unique_surfaces = {}
	local result_array = {}
	for player_index, player in pairs(game.players) do
		only_unique_surfaces[player.surface.name] = true
	end
	for surface_name in next, only_unique_surfaces, nil do
		table.insert(result_array, surface_name)
	end
	return result_array
end

function get_forces_to_update()
	local only_unique_forces = {}
	local result_array = {}
	for player_index, player in pairs(game.players) do
		only_unique_forces[player.force.name] = true
	end
	for force_name in next, only_unique_forces, nil do
		table.insert(result_array, force_name)
	end
	return result_array
end

--[[function save_to_global() 
	local start_index = nil
	global.lamps_dictionary = nil --make GC know that we don't need old table anymore
	global.lamps_dictionary = {}
	for surface_name,lamps_on_surface in next,global.lamps_dictionary, nil do
		global.lamps_dictionary[surface_name] = {}
		local number_of_iterations = math.ceil(table_length(lamps_on_surface) / 200) --200 objects in array is maximum for factorio serialization mechanism
		for index=1,number_of_iterations do
			local count = 1
			global.lamps_dictionary[surface_name][index] = {}
			for colored_lamp_entity_index, colored_lamp_entity in next,lamps_on_surface, start_index do
				if count > 200 then 
					break 
				elseif count == 200 then
					start_index = colored_lamp_entity_index
				end
				global.lamps_dictionary[surface_name][index][count] = 
				{
					colored_lamp_entity_index, 
					colored_lamp_entity 
				}
				count = count + 1
			end
			--start_index = start_index + counttable_length_1(global.lamps_dictionary)
		end
	end
		print("Lamps On Map has been saved")
end
]]
-- function load_from_global()
-- 	global.lamps_dictionary = nil --make GC know that we don't need old table anymore 
-- 	global.lamps_dictionary = {}
-- 	for surface_name, serialized_lamps in next, global.lamps_dictionary, nil do
-- 		global.lamps_dictionary[surface_name] = {}
-- 		for _,chunk_of_data in pairs(serialized_lamps) do
-- 			for _,serialized_colored_lamp_entity in pairs(chunk_of_data) do
-- 				global.lamps_dictionary[surface_name][serialized_colored_lamp_entity[1]] = serialized_colored_lamp_entity[2]
-- 			end
-- 		end
-- 	end
-- end]]

--on_entity_changed = script.generate_event_name()

-- end GLOBAL

script.on_configuration_changed(function(ConfigurationChangedData)
	for index,surface in ipairs(game.surfaces) do
		local lamp_entities = surface.find_entities_filtered({name = "small-lamp", type = "lamp"})
		--global.lamps_dictionary = lamp_entities
		
	end
end)

function on_build_lamp(event_args)
	local created_entity = event_args.created_entity
	print(created_entity.unit_number)
	if created_entity.name == "small-lamp" then
		local lamp_dictionary_index = created_entity.unit_number
		local lamp_surface_name = created_entity.surface.name
		local old_tile_name = ""

		if global.lamps_dictionary[lamp_surface_name] == nil then
			global.lamps_dictionary[lamp_surface_name] = {}
		end

		if global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index] ~= nil then
			old_tile_name = global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index].tile.original_tile_name
			global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index] = nil
		else
			old_tile_name = created_entity.surface.get_tile(created_entity.position.x, created_entity.position.y).prototype.name
			if string.find(old_tile_name, "lamp") ~= nil then
				local start_of_sequence, end_of_secuence = string.find(old_tile_name, "-map-")
				old_tile_name =  string.sub(old_tile_name, 6, start_of_sequence - 1)
				--print("ha, strange")
			end
		end
		update_lamp_in_dictionary(created_entity, old_tile_name)
	end
end

function on_mined_lamp(event_args)
	local mined_entity = event_args.entity
	if mined_entity.name == "small-lamp" then
		local lamp_dictionary_index = mined_entity.unit_number
		local lamp_surface_name = mined_entity.surface.name
		if global.lamps_dictionary[lamp_surface_name] == nil then
			error("Something wrong! There is no such lamp in surface " .. lamp_surface_name)
			return
		end
		if global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index] ~= nil then
			local mined_ColoredLampEntity = global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index]
			mined_entity.surface.set_tiles({{ name=mined_ColoredLampEntity.tile.original_tile_name, position=mined_ColoredLampEntity.tile.position}}, true)
			global.lamps_dictionary[lamp_surface_name] = table.removeKey(global.lamps_dictionary[lamp_surface_name], lamp_dictionary_index)
			--global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index] = nil
		end
		if global_pending_changes ~= nil and global_pending_changes[lamp_surface_name] ~= nil and global_pending_changes[lamp_surface_name][lamp_dictionary_index] ~= nil then
			--global.lamps_dictionary[lamp_surface_name] = table.removeKey(global.lamps_dictionary[lamp_surface_name], lamp_dictionary_index)
			global_pending_changes[lamp_surface_name][lamp_dictionary_index] = nil
		end
	end
end

function on_another_tile_build(event_args)
	local surface = event_args.player_index == nil and event_args.robot.surface or game.players[event_args.player_index].surface
	for _, position in pairs(event_args.positions) do
		if global.positions[position.x] ~= nil and global.positions[position.x][position.y] ~= nil then

			local lamp_dictionary_index = lobal.positions[position.x][position.y]

			if global.lamps_dictionary[surface.name] ~= nil  and global.lamps_dictionary[surface.name][lamp_dictionary_index] ~= nil then
				add_lamp_in_pending_queue(lamp_dictionary_index, global.lamps_dictionary[surface.name][lamp_dictionary_index])
			end
		end
	end
end

--reads from lamp behavior signals information and returns ir in array for each wire type
function get_virtual_signal(lamp_behavior)
	local result_for_each_wire = {}
	for wire_index,wire in pairs(circuit_wires_types) do
		local circuit_network = lamp_behavior.get_circuit_network(wire)
		if circuit_network ~= nil and #circuit_network.signals > 0 then
			local recieved_color_signal = nil
			for virtual_signal_color_name,virtual_signal_color in pairs(virtual_signals) do
				local get_next_signal_result = circuit_network.get_signal({type="virtual",name=virtual_signal_color.name})
				if get_next_signal_result > 0 then
					recieved_color_signal = virtual_signal_color
					break
				end
			end
			if recieved_color_signal ~= nil then
				result_for_each_wire[wire] = recieved_color_signal
			end
			
			--[[for signal_index,signal in pairs(circuit_network.signals) do
				local is_color = false
				if signal.signal.type ~= "virtual" then break end
				for virtual_signal_color_name,virtual_signal_color in pairs(virtual_signals) do
					is_color = string.find(signal.signal.name, virtual_signal_color_name)
					if is_color then 
						table.insert(recieved_color_signals, virtual_signal_color.priority, virtual_signal_color)
						break 
					end
				end
			end
			if table_length(recieved_color_signals) > 0 then 
				local _ = 1
				_, result_for_each_wire[wire] = next(recieved_color_signals, nil) 
				--print("FINAL color " .. result_for_each_wire[wire].color)
			end]]--
		end
	end
	return result_for_each_wire
end

function add_lamp_in_pending_queue(lamp_dictionary_index, coloredLampEntity)
	local lamp_surface_name = coloredLampEntity.entity.surface.name
	if global_pending_changes == nil then
		global_pending_changes = {}
		global_pending_changes[lamp_surface_name] = {}
	elseif global_pending_changes[lamp_surface_name] == nil then
		global_pending_changes[lamp_surface_name] = {}
	end
	global_pending_changes[lamp_surface_name][lamp_dictionary_index] = coloredLampEntity
end

function update_lamp_in_dictionary(entity, old_tile_name)
	local lamp_behavior = entity.get_control_behavior()
	local final_color, lamp_dictionary_index, lamp_surface_name = {}, entity.unit_number, entity.surface.name

	if lamp_behavior ~= nil and lamp_behavior.use_colors and lamp_behavior.circuit_condition.fulfilled and entity.energy > 0 then
		local circuit_signal_on_wire = get_virtual_signal(lamp_behavior)
		local number_of_founded_networks_with_valid_signal = table_length(circuit_signal_on_wire)

		if number_of_founded_networks_with_valid_signal > 1 then
			--pick color between two network signals
			local signal_on_red_wire, signal_on_green_wire = circuit_signal_on_wire[circuit_wires_types[1]], circuit_signal_on_wire[circuit_wires_types[2]]

			if(signal_on_red_wire.priority < signal_on_green_wire.priority) then
				final_color = signal_on_red_wire.color
			else
				final_color = signal_on_green_wire.color
			end
		elseif number_of_founded_networks_with_valid_signal == 1 then
			local _, correct_virtual_signal = next(circuit_signal_on_wire, nil)
			final_color = correct_virtual_signal.color
		else 
			final_color = "white"
		end
	else
		final_color = "default"
	end

	if global.lamps_dictionary[lamp_surface_name] == nil then
		global.lamps_dictionary[lamp_surface_name] = {}
	end

	if global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index] ~= nil then
		if global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index].tile.color ~= final_color then
			global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index].tile.new_tile_name = generate_lamp_tile_name(final_color)
			global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index].tile.color = final_color
			add_lamp_in_pending_queue(lamp_dictionary_index, global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index])
		end
	else
		global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index] = ColoredLampEntity(entity, LampTile(entity.position, final_color, old_tile_name))
		add_lamp_in_pending_queue(lamp_dictionary_index, global.lamps_dictionary[lamp_surface_name][lamp_dictionary_index])
	end
end

--[[function draw_tiles(surface)
	local lua_tile_array = {}
	for index,color in pairs(global.lamps_dictionary[surface.name]) do
		--if color.entity.valid then
			if color.entity.energy > 0 then
				table.insert(lua_tile_array, { name = color.tile.new_tile_name, position = color.tile.position })
			else
				table.insert(lua_tile_array, { name = generate_lamp_tile_name("default"), position = color.tile.position })
			end
		--end
	end
	surface.set_tiles(lua_tile_array, false)
	for player_index, player in pairs(game.players) do
		for index,color in pairs(global.lamps_dictionary[surface.name]) do
			--player.force.chart(surface, {index, index})
		end
	end
end

function test_draw(lamps_for_update, surface_name)
		if lamps_for_update ~= nil then
			local lua_tile_array = {}
			for _, colored_lamp in pairs(lamps_for_update) do
				if colored_lamp.entity.valid then
					table.insert(lua_tile_array, { name = colored_lamp.tile.new_tile_name, position = colored_lamp.tile.position })
				end
			end
			game.surfaces[surface_name].set_tiles(lua_tile_array, true)
			for _, force_name in next, get_forces_to_update(), nil do
				for __, tile_item in next, lua_tile_array, nil do
					if not game.forces[force_name].is_chunk_charted(game.surfaces[surface_name], tile_item.position) then
						game.forces[force_name].chart(game.surfaces[surface_name], {tile_item.position,tile_item.position})
					end
				end
			end
		end
		return nil
		
	--
end

function test_update(start_index, surface_name)
		local count, end_index = 1, {}
		for colored_lamp_entity_index, colored_lamp_entity in next,global.lamps_dictionary[surface_name], start_index do
			if count > defined_lamps_per_iteration then break end
			end_index = colored_lamp_entity_index
			if colored_lamp_entity.entity.valid then
				update_lamp_in_dictionary(colored_lamp_entity.entity, colored_lamp_entity.tile.original_tile_name)
			end
			count = count + 1
		end
		if count <= defined_lamps_per_iteration then 
			end_index = nil
		end
		return end_index
end]]

function on_regular_checking(event_args)
	local status = false
	if event_args.tick % defined_iteration_frequency == 0 then
		for _, surface_name in next, get_surfaces_to_update(), nil do
			status, last_coroutine_index[surface_name] = coroutine.resume(main_coroutine, last_coroutine_index[surface_name], surface_name)
		end
	elseif event_args.tick % (defined_iteration_frequency + 1) == 0 then
		for _, surface_name in next, get_surfaces_to_update(), nil do
			if global_pending_changes[surface_name] ~= nil then
				status, global_pending_changes[surface_name] = coroutine.resume(draw_coroutine, global_pending_changes[surface_name], surface_name)
			end
		end
	end
end


--- Find and register all lamp entities in all surfaces.
-- This function gathers all entities in every surface 
-- and stores it using ColoredLampEntity metatable in global table
function register_all_existing_lamps() 
	for _,surface in pairs(game.surfaces) do
		local lamp_entities = surface.find_entities_filtered({name = "small-lamp", type = "lamp"}) -- it can take a while, even freeze the game for few seconds. TODO: make it iterational (coroutines?)
		for __,lamp in pairs(lamp_entities) do
			local lamp_dictionary_index, lamp_surface_name = lamp.unit_number, lamp.surface.name

			if global.lamps_dictionary[lamp_surface_name] == nil then
				global.lamps_dictionary[lamp_surface_name] = {}
			end

			local old_tile_name = lamp.surface.get_tile(lamp.position.x, lamp.position.y).prototype.name

			if string.find(old_tile_name, "lamp") ~= nil then
				local start_of_sequence, end_of_secuence = string.find(old_tile_name, "-map-")
				old_tile_name =  string.sub(old_tile_name, 6, start_of_sequence - 1) -- potenrially a bug. It actually says that if there was Lamps On Map tile prototype, then take defined_tile_name from config and place it when lamp will be destroyed. It can spawn a tile that can be collected after lamp is mined (for example - concrete). Possible fix: place concrete and delete it right after (concrete has ability to restore original tile once it mined)
			end

			update_lamp_in_dictionary(lamp, old_tile_name)
		end
	end
end


--- Launches initialization process.
-- Creates global variables, dictionaries and launches @see 'register_all_existing_lamps()' function 
-- that iterates over all lamps in all surfaces and wraps them
-- with @see 'ColoredLampEntity' metatable which then stored in global
function on_initialize()
	global.lamps_dictionary = {}
	global.positions = {}

	register_all_existing_lamps()	
end


-- Starts loading sequence.
function on_loading() 
	--change global.settings?
end

script.on_init(on_initialize)
script.on_load(on_loading)
script.on_event(defines.events.on_built_entity, on_build_lamp)
script.on_event(defines.events.on_robot_built_entity, on_build_lamp)
script.on_event(defines.events.on_preplayer_mined_item, on_mined_lamp)
script.on_event(defines.events.on_robot_pre_mined, on_mined_lamp)
script.on_event(defines.events.on_entity_died, on_mined_lamp)
script.on_event(defines.events.on_tick, on_regular_checking)
script.on_event(defines.events.on_player_built_tile, on_another_tile_build)
script.on_event(defines.events.on_robot_built_tile, on_another_tile_build)