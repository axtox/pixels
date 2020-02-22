function on_loading() 
    game.print(serpent.block(game.players[1])) 
end

script.on_event(defines.events.on_built_entity, on_loading)