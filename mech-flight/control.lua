local UPDATE_INTERVAL = 30

local function get_base_flying_speed(character)
  local proto = character.prototype
  if proto and proto.flying_speed then
    return proto.flying_speed
  end
  return nil
end

local function update_character_flying_speed(character)
  if not (character and character.valid) then
    return
  end

  local running_speed = character.running_speed
  if not running_speed then
    return
  end

  local base_flying_speed = get_base_flying_speed(character)
  if not base_flying_speed or base_flying_speed <= 0 then
    return
  end

  local desired_modifier = (running_speed / base_flying_speed) - 1

  if character.character_flying_speed_modifier ~= nil then
    character.character_flying_speed_modifier = desired_modifier
  elseif character.flying_speed_modifier ~= nil then
    character.flying_speed_modifier = desired_modifier
  end
end

local function update_player(player)
  if player and player.valid then
    update_character_flying_speed(player.character)
  end
end

script.on_event(defines.events.on_player_created, function(event)
  update_player(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_player_respawned, function(event)
  update_player(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
  update_player(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick % UPDATE_INTERVAL ~= 0 then
    return
  end

  for _, player in pairs(game.connected_players) do
    update_player(player)
  end
end)
