-- Map dimensions
MAP_WIDTH = 128 * 8
MAP_HEIGHT = 30 * 8

-- Title Screen Variables
title_y = -20 -- Initial Y position of the title
title_speed = 1 -- Speed of the title sliding down
-- tiles
BACKGROUND_OBJECTS = 2
-- Game State
GAME_STATE = {
    TITLE = "title",
    PLAYING = "playing",
    GAME_OVER = "game_over"
}
-- Player Mode
PLAYER_MODE = {
    DRIVING = "driving",
    SHOOTING = "shooting"
}

-- Shooting-Functions
function shooting(type)
    if shooting_cooldown <= 0 and is_player_on_ground() then
        --player_mode = PLAYER_MODE.SHOOTING auskommentiert bis es genutzt wird
        if player.current_sprite == PLAYER_SPRITE_RIGHT then
            create_shot(type, player.x + 8, player.y, 1)  -- Richtung 1 = rechts
        else
            create_shot(type, player.x, player.y, -1)  -- Richtung -1 = links

        end
        weapon_effects.fire_effect_duration = 3
        sfx(weapon_effects.normal_shot.fire_sound)
        shooting_cooldown = 25
    end
end

function explode(x, y, radius)
    -- erstes Tile ermitteln
    local tx = flr(x / 8)
    local ty = flr(y / 8)

    -- dann Explosion relativ zum Tile-Zentrum
    for dx = -radius, radius do
        for dy = -radius, radius do
            damage_tile_at((tx + dx) * 8, (ty + dy) * 8)
        end
    end
end

-- Pico-8 Standard Functions
function _update()
    update_title_screen()
    enable_driving_mode()
    calculate_vertical_velocity(MAX_FALL_SPEED)
    update_shots()
    update_explosions()
    reduce_timers()
    update_camera()

    change_weapon_type()

    if btnp(5) then
        shooting(weapon_type)
    end
    is_player_dead()
    if game_state == GAME_STATE.GAME_OVER then
        if btn(4) then
            resetGame()
            game_state = GAME_STATE.TITLE
            draw_title_screen()
        end
    end
end

function _draw()
    cls()

    if game_state == GAME_STATE.TITLE then
        draw_title_screen()
    elseif game_state == GAME_STATE.PLAYING then
        draw_game()
    elseif game_state == GAME_STATE.GAME_OVER then
        draw_game_over_screen()
    end
end


-- Help-Functions
function update_title_screen()
    if game_state == GAME_STATE.TITLE then
        -- Slide the title down
        if title_y < 40 then
            title_y = title_y + title_speed
        end

        if btnp(4) then
            game_state = GAME_STATE.PLAYING
        end
    end

end

function collision_at_position(player_x, player_y)
    local tank_x = flr(player_x / 8)
    local tank_y = flr(player_y / 8)

    return fget(mget(tank_x, tank_y), 0)
end

function is_object_in_air(edge, y_direction)
    return not collision_at_position(edge, player.y + 8 * y_direction)
end

function is_player_on_ground()
    local left_edge = player.x
    local right_edge = player.x + 7

    return not is_object_in_air(left_edge, 1) or not is_object_in_air(right_edge, 1)
end

function is_player_dead()
    if player.hp <= 0 then
        game_state = GAME_STATE.GAME_OVER
    end
end

function enable_driving_mode()
    if player_mode == PLAYER_MODE.DRIVING then
        apply_vertical_movement()
        apply_horizontal_movement()
        jump()
    end
end

function reduce_timers()
    if weapon_effects.fire_effect_duration > 0 then
        weapon_effects.fire_effect_duration -= 1
    end
    if shooting_cooldown > 0 then
        shooting_cooldown -= 1
    end
end

function draw_title_screen()
    draw_long_sprite(64, SCREEN_WIDTH / 4, title_y, 6)

    if title_y >= 40 then
        print("Press c to begin", (SCREEN_WIDTH / 4) - 2, 80, 7)
    end
end

function draw_long_sprite(sprite, x, y, length)
    for i = 0, length do
        spr(sprite + i, x + (i * 8), y)
    end
end

function draw_game_over_screen()
    draw_long_sprite(80, SCREEN_WIDTH / 4, -20, 4)
    print("Press c to replay", (SCREEN_WIDTH / 4) - 2, 80, 7)
end

function draw_game()
    cls(12)
    camera(camera_x, camera_y)
    map()
    spr(player.current_sprite, player.x, player.y)
    draw_fire_effect()
    draw_shots()
    draw_explosions()

    -- Kamera zurücksetzen, um UI-Elemente fest zu zeichnen
    camera(0, 0)

    local current_sprite = 0
    -- Benötigt für die Anzeige der aktuellen Waffe
    if weapon_type == "normal_shot" then
        current_sprite = NORMAL_SHOT_SPRITE_RIGHT
    elseif weapon_type == "grenade_shot" then
        current_sprite = GRENADE_SHOT_SPRITE
    end

    --print("x=" .. player.x .. " y=" .. player.y, 0, 0, 7)
    print("weapon-type: ", 1, 12, 7)
    print("\t" .. player.hp, 1, 4, 7)
    print("press c to change weapon-type", 1, 120, 6)
    spr(current_sprite, 48, 10)
    draw_health_bar(player.hp, player.max_hp, 1, 2, 40, 6)
end

function change_weapon_type()
    if btnp(4) then
        if weapon_type == "normal_shot" then
            weapon_type = "grenade_shot"
        else
            weapon_type = "normal_shot"
        end
    end
end