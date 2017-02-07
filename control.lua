require "config"

--properties
 --ColoredLampEntity dictionary (copy of global.lamp_dictionary) sorted by suface names e.g global_lamps_dictionary["surface_name"][lamp_coordinates_integer]
global_lamps_dictionary = {}
 --ColoredLampEntity that need to be redrawn on map
global_pending_changes = {}

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

--debug
function print(text)
	for _, player in pairs(game.players) do
		--player.print(text)
	end
end

--debug
function print_table(object)
	for key,value in pairs(object) do
		print("found member " .. key .. " with " .. tostring(value))
	end
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
		for colored_lamp_entity_index, colored_lamp_entity in next,global_lamps_dictionary[surface_name], start_index do
			if count > lamps_per_iteration then break end
			end_index = colored_lamp_entity_index
			if colored_lamp_entity.entity.valid then
				update_lamp_in_dictionary(colored_lamp_entity.entity, colored_lamp_entity.tile.original_tile_name)
			end
			count = count + 1
		end
		if count <= lamps_per_iteration then 
			end_index = nil
		end
		--print("count - " .. count .. "; " .. "last - " .. tostring(end_index))
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

save_coroutine = coroutine.create(function(colored_lamp_entity_index, colored_lamp_entity)
	local is_coroutine_active = true
	while is_coroutine_active do
		local start_index = nil
		global.lamps_dictionary = nil --make GC know that we don't need old table anymore
		global.lamps_dictionary = {}
		for surface_name,lamps_on_surface in next,global_lamps_dictionary, nil do
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
		print("saved")
	end
end)

--enumerations
 --Wire types enum
circuit_wires_types = {
	defines.wire_type.red, 
	defines.wire_type.green 
}
 --Virtual signals enum
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

 --helpers functions
function table_length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function table_length_1(T)
	local count, is_same = 0, false
	for _,__t in pairs(T) do 
		for ___ in pairs(__t) do
			count = count + 1
		end
	end
	return count
end

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

function generate_lamp_tile_name(color_name)
	return "lamp-" .. base_tile .. "-map-" .. color_name
end

--special encoding for digit representation of positon coordinates (string is longer to iterate)
function encode_lamp_coordinates_index(x,y)
	return string.gsub(x, "%.5", "") .. "." .. string.gsub(y, "%.5", "")
end

function decode_lamp_coordinates_index(index)
    local string_number = tostring(index)
	local split_start_index, split_end_index = string.find(string_number, '%.')
	local x,y = tonumber(string.sub(string_number, 1, split_start_index - 1) .. ".5"), tonumber(string.sub(string_number, split_start_index + 1) .. ".5")
	return {["x"]=x,["y"]=y}
end

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

function save_to_global() 
	local start_index = nil
	global.lamps_dictionary = nil --make GC know that we don't need old table anymore
	global.lamps_dictionary = {}
	for surface_name,lamps_on_surface in next,global_lamps_dictionary, nil do
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
	print("saved")
end

function load_from_global()
	global_lamps_dictionary = nil --make GC know that we don't need old table anymore 
	global_lamps_dictionary = {}
	for surface_name, serialized_lamps in next, global.lamps_dictionary, nil do
		global_lamps_dictionary[surface_name] = {}
		for _,chunk_of_data in pairs(serialized_lamps) do
			for _,serialized_colored_lamp_entity in pairs(chunk_of_data) do
				global_lamps_dictionary[surface_name][serialized_colored_lamp_entity[1]] = serialized_colored_lamp_entity[2]
			end
		end
	end
end

on_entity_changed = script.generate_event_name()

-- end GLOBAL

script.on_configuration_changed(function(ConfigurationChangedData)
	for index,surface in ipairs(game.surfaces) do
		local lamp_entities = surface.find_entities_filtered({name = "small-lamp", type = "lamp"})
		--global_lamps_dictionary = lamp_entities
		
	end
end)

script.on_load(function()
	--game.players[1].print(#global_lamps_dictionary .. " items")
	--game.raise_event(on_entity_changed, t)
end)

function on_build_lamp(event_args)
	local created_entity = event_args.created_entity
	if created_entity.name == "small-lamp" then
		local lamp_dictionary_index = encode_lamp_coordinates_index(created_entity.position.x, created_entity.position.y)
		local lamp_surface_name = created_entity.surface.name
		local old_tile_name = ""
		if global_lamps_dictionary[lamp_surface_name] == nil then
			global_lamps_dictionary[lamp_surface_name] = {}
		end
		if global_lamps_dictionary[lamp_surface_name][lamp_dictionary_index] ~= nil then
			old_tile_name = global_lamps_dictionary[lamp_surface_name][lamp_dictionary_index].tile.original_tile_name
			global_lamps_dictionary[lamp_surface_name][lamp_dictionary_index] = nil
		else
			old_tile_name = created_entity.surface.get_tile(created_entity.position.x, created_entity.position.y).prototype.name
			if string.find(old_tile_name, "lamp") ~= nil then
				local start_of_sequence, end_of_secuence = string.find(old_tile_name, "-map-")
				old_tile_name =  string.sub(old_tile_name, 6, start_of_sequence - 1)
				print("ha, strange")
			end
		end
		update_lamp_in_dictionary(created_entity, old_tile_name)
	end
end

function on_mined_lamp(event_args)
	local mined_entity = event_args.entity
	if mined_entity.name == "small-lamp" then
		local lamp_dictionary_index = encode_lamp_coordinates_index(mined_entity.position.x, mined_entity.position.y)
		print(lamp_dictionary_index)
		local lamp_surface_name = mined_entity.surface.name
		if global_lamps_dictionary[lamp_surface_name] == nil then
			error("Something wrong! There is no such lamp in surface " .. lamp_surface_name)
			return
		end
		if global_lamps_dictionary[lamp_surface_name][lamp_dictionary_index] ~= nil then
			local mined_ColoredLampEntity = global_lamps_dictionary[lamp_surface_name][lamp_dictionary_index]
			mined_entity.surface.set_tiles({{ name=mined_ColoredLampEntity.tile.original_tile_name, position=decode_lamp_coordinates_index(lamp_dictionary_index)}}, true)
			global_lamps_dictionary[lamp_surface_name] = table.removeKey(global_lamps_dictionary[lamp_surface_name], lamp_dictionary_index)
			--global_lamps_dictionary[lamp_surface_name][lamp_dictionary_index] = nil
		end
		if global_pending_changes ~= nil and global_pending_changes[lamp_surface_name] ~= nil and global_pending_changes[lamp_surface_name][lamp_dictionary_index] ~= nil then
			--global_lamps_dictionary[lamp_surface_name] = table.removeKey(global_lamps_dictionary[lamp_surface_name], lamp_dictionary_index)
			global_pending_changes[lamp_surface_name][lamp_dictionary_index] = nil
		end
	end
end

function on_another_tile_build(event_args)
	local surface = event_args.player_index == nil and event_args.robot.surface or game.players[event_args.player_index].surface
	for _, position in pairs(event_args.positions) do
		local lamp_index = encode_lamp_coordinates_index(position.x+.5, position.y+.5)
		if global_lamps_dictionary[surface.name][lamp_index] ~= nil then
			add_lamp_in_pending_queue(lamp_index, global_lamps_dictionary[surface.name][lamp_index])
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

function add_lamp_in_pending_queue(coordinates_index, coloredLampEntity)
	local lamp_surface_name = coloredLampEntity.entity.surface.name
	if global_pending_changes == nil then
		global_pending_changes = {}
		global_pending_changes[lamp_surface_name] = {}
	elseif global_pending_changes[lamp_surface_name] == nil then
		global_pending_changes[lamp_surface_name] = {}
	end
	--print(lamp_surface_name)
	--print(coloredLampEntity == nil)
	--print(type(coordinates_index))
	--print(global_pending_changes[lamp_surface_name] == nil)
	global_pending_changes[lamp_surface_name][coordinates_index] = coloredLampEntity
end

function update_lamp_in_dictionary(entity, old_tile_name)
	local lamp_behavior = entity.get_control_behavior()
	local final_color, coordinates, lamp_surface_name = {}, encode_lamp_coordinates_index(entity.position.x, entity.position.y), entity.surface.name
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
	
	if global_lamps_dictionary[lamp_surface_name] == nil then
		global_lamps_dictionary[lamp_surface_name] = {}
	end
	--game.players[1].print(final_color .. " COLOR")
	if global_lamps_dictionary[lamp_surface_name][coordinates] ~= nil then
		if global_lamps_dictionary[lamp_surface_name][coordinates].tile.color ~= final_color then
			global_lamps_dictionary[lamp_surface_name][coordinates].tile.new_tile_name = generate_lamp_tile_name(final_color)
			global_lamps_dictionary[lamp_surface_name][coordinates].tile.color = final_color
			--print("changing " .. final_color)
			add_lamp_in_pending_queue(coordinates, global_lamps_dictionary[lamp_surface_name][coordinates])
		end
	else
		global_lamps_dictionary[lamp_surface_name][coordinates] = ColoredLampEntity(entity, LampTile(entity.position, final_color, old_tile_name))
		add_lamp_in_pending_queue(coordinates, global_lamps_dictionary[lamp_surface_name][coordinates])
		
	end
end

function draw_tiles(surface)
	local lua_tile_array = {}
	for index,color in pairs(global_lamps_dictionary[surface.name]) do
		--if color.entity.valid then
			if color.entity.energy > 0 then
				table.insert(lua_tile_array, { name = color.tile.new_tile_name, position = decode_lamp_coordinates_index(index) })
			else
				table.insert(lua_tile_array, { name = generate_lamp_tile_name("default"), position = decode_lamp_coordinates_index(index) })
			end
		--end
	end
	surface.set_tiles(lua_tile_array, false)
	for player_index, player in pairs(game.players) do
		for index,color in pairs(global_lamps_dictionary[surface.name]) do
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
		for colored_lamp_entity_index, colored_lamp_entity in next,global_lamps_dictionary[surface_name], start_index do
			if count > lamps_per_iteration then break end
			end_index = colored_lamp_entity_index
			if colored_lamp_entity.entity.valid then
				update_lamp_in_dictionary(colored_lamp_entity.entity, colored_lamp_entity.tile.original_tile_name)
			end
			count = count + 1
		end
		if count <= lamps_per_iteration then 
			end_index = nil
		end
		return end_index
end

function on_regular_checking(event_args)
	local status = false
	if event_args.tick % iteration_frequency == 0 then
		for _, surface_name in next, get_surfaces_to_update(), nil do
			status, last_coroutine_index[surface_name] = coroutine.resume(main_coroutine, last_coroutine_index[surface_name], surface_name)
		end
	elseif event_args.tick % (iteration_frequency + 1) == 0 then
		for _, surface_name in next, get_surfaces_to_update(), nil do
			if global_pending_changes[surface_name] ~= nil then
				--print(table_length(global_pending_changes[surface_name]) .. " WAS")
				status, global_pending_changes[surface_name] = coroutine.resume(draw_coroutine, global_pending_changes[surface_name], surface_name)
				
				--print(tostring(global_pending_changes[surface_name] == nil) .. " WAS")
				--status, global_pending_changes[surface_name] = coroutine.resume(draw_coroutine, global_pending_changes[surface_name], surface_name)
			end
		end
		--test_draw()
		--draw_tiles(player.surface)
		--game.players[1].print("" .. " draw")
	elseif event_args.tick % 2001 == 0 then
		save_to_global()
	end
	--print(table_length(global_lamps_dictionary["nauvis"]) .. " " .. iteration_frequency .. " " .. lamps_per_iteration)
end

function update_all_lamps() 
	for index,surface in pairs(game.surfaces) do
		if global_lamps_dictionary[surface.name] == nil then
			global_lamps_dictionary[surface.name] = {}
		end
		local lamp_entities = surface.find_entities_filtered({name = "small-lamp", type = "lamp"})
		for entity_index,entity in pairs(lamp_entities) do
			local lamp_dictionary_index = encode_lamp_coordinates_index(entity.position.x, entity.position.y)
			if global_lamps_dictionary[surface.name][lamp_dictionary_index] ~= nil then
				update_lamp_in_dictionary(entity, global_lamps_dictionary[surface.name][lamp_dictionary_index].tile.original_tile_name)
			else
				local old_tile_name = entity.surface.get_tile(entity.position.x, entity.position.y).prototype.name
				if string.find(old_tile_name, "lamp") ~= nil then
					local start_of_sequence, end_of_secuence = string.find(old_tile_name, "-map-")
					old_tile_name =  string.sub(old_tile_name, 6, start_of_sequence - 1)
				end
				update_lamp_in_dictionary(entity, old_tile_name)
			end
		end
		draw_tiles(surface)
	end
end

function on_initialize()
	base_tile = defined_base_tile
	iteration_frequency = defined_iteration_frequency
	lamps_per_iteration = defined_lamps_per_iteration

	if global.lamps_dictionary ~= nil then
		local all_lamps_quantity, quantity_of_lamps_in_dictionary = 0, table_length_2(global.lamps_dictionary)
		for index,surface in pairs(game.surfaces) do
			all_lamps_quantity = all_lamps_quantity + surface.count_entities_filtered({name = "small-lamp", type = "lamp"})
		end
		if quantity_of_lamps_in_dictionary ~= all_lamps_quantity then
			update_all_lamps()
		else
			load_from_global()
		end
		print("initialized " .. all_lamps_quantity .. " lamps found " .. quantity_of_lamps_in_dictionary .. " was " .. tostring(all_lamps_quantity == quantity_of_lamps_in_dictionary))
	else
		global.lamps_dictionary = {}
		update_all_lamps()
		print("initialized not used before")
	end
	
	script.on_event(defines.events.on_tick, nil)
	script.on_event(defines.events.on_tick, on_regular_checking)
end

function on_player_joined(event_args)
	print("JOINED " .. game.players[event_args.player_index].name)
	on_initialize()
end

script.on_event(defines.events.on_built_entity, on_build_lamp)
script.on_event(defines.events.on_robot_built_entity, on_build_lamp)
script.on_event(defines.events.on_preplayer_mined_item, on_mined_lamp)
script.on_event(defines.events.on_robot_pre_mined, on_mined_lamp)
script.on_event(defines.events.on_tick, on_initialize)
script.on_event(defines.events.on_entity_died, on_mined_lamp)
script.on_event(defines.events.on_player_built_tile, on_another_tile_build)
script.on_event(defines.events.on_robot_built_tile, on_another_tile_build)
script.on_event(defines.events.on_player_joined_game, on_player_joined)

script.on_event(on_entity_changed, function(entity)
	print("event shot!!!" .. tostring(entity))
end)