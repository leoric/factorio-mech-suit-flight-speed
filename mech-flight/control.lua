local UPDATE_INTERVAL = 30

-- Fixes the character's running speed modifier so that mech-suit flight speed matches ground
-- speed on fast/slow tiles (e.g. concrete, oil oceans).
--
-- Note: earlier versions of this mod tried to write to `character.character_flying_speed_modifier`
-- / `character.flying_speed_modifier`. Neither of those fields has ever existed in the Factorio
-- API (confirmed against the current LuaControl documentation) - the only writable speed field is
-- `character_running_speed_modifier`. Per FFF-433, flying and walking share the same underlying
-- speed value; vanilla just skips the tile-speed term while airborne (confirmed as intentional by
-- the developers). This reimplements the mod's intent using that field instead, driven off
-- `character.is_flying`.
local function update_character_flying_speed(player)
  if not (player and player.valid) then
    return
  end

  local character = player.character
  if not (character and character.valid) then
    return
  end

  if not character.is_flying then
    -- Grounded: vanilla already applies the tile's speed modifier natively, so don't add our own
    -- on top of it.
    character.character_running_speed_modifier = 0
    return
  end

  local tile_modifier = nil
  if character.surface then
    local tile = character.surface.get_tile(character.position)
    if tile and tile.prototype then
      tile_modifier = tile.prototype.walking_speed_modifier
    end
  end

  if not tile_modifier or tile_modifier == 1 then
    character.character_running_speed_modifier = 0
    return
  end

  -- While flying, vanilla ignores tile speed entirely. Assign flying speed the value that walking
  -- speed would have on this tile - bonus or penalty alike, symmetrically. Since (while flying)
  -- character_running_speed already reflects base speed with no tile term, setting the modifier
  -- to (tile_modifier - 1) scales it to base_speed * tile_modifier, i.e. the hypothetical walking
  -- speed on this tile.
  character.character_running_speed_modifier = tile_modifier - 1
end

local function update_player(player)
  if player and player.valid then
    update_character_flying_speed(player)
  end
end

script.on_event(defines.events.on_player_created, function(event)
  update_player(game.players[event.player_index])
end)

script.on_event(defines.events.on_player_respawned, function(event)
  update_player(game.players[event.player_index])
end)

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
  update_player(game.players[event.player_index])
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick % UPDATE_INTERVAL ~= 0 then
    return
  end

  for _, player in pairs(game.connected_players) do
    update_player(player)
  end
end)
