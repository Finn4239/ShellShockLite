-- Shooting-Functions
function shooting()
    if shooting_cooldown <= 0 and is_player_on_ground() then
        --player_mode = PLAYER_MODE.SHOOTING
        if player.current_sprite == PLAYER_SPRITE_RIGHT then
            create_shot(player.x + 8, player.y, 1)  -- Richtung 1 = rechts
        else
            create_shot(player.x, player.y, -1)  -- Richtung -1 = links
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
    reduce_timers()
    calculate_vertical_velocity(MAX_FALL_SPEED)
    enable_driving_mode()

    -- Waffenwechsel
    if btnp(4) then
        if weapons == "normal_shot" then
            weapons = "grenade_shot"
        else
            weapons = "normal_shot"
        end
    end
    -- Schießen
    if btnp(5) then
        shooting()
    end


    update_explosions()
    update_shots()
    update_camera()
end

function _draw()
    cls()

    if game_state == GAME_STATE.TITLE then
        draw_title_screen()
    elseif game_state == GAME_STATE.PLAYING then
        draw_game()
    end
end

-- Help-Functions
function update_title_screen()
    if game_state == GAME_STATE.TITLE then
        -- Slide the title down
        if title_y < 40 then
            title_y = title_y + title_speed
        end

        -- Start the game when any button is pressed
        if btnp(4) then
            game_state = GAME_STATE.PLAYING
        end
    end
end

function get_vertical_direction(a)
    if a < 0 then
        return -1 -- move up
    elseif a > 0 then
        return 1 -- move down
    else
        return 0 -- no movement
    end
end

function absolute_value(a) -- makes integer-/double-value positive
    if a < 0 then return -a end

    return a
end

function collision_at_position(player_x, player_y)
    local tank_x = flr(player_x / 8)
    local tank_y = flr(player_y / 8)

    return fget(mget(tank_x, tank_y), 0)
end

function calculate_vertical_velocity()
    velocity_y += GRAVITY
    if velocity_y > MAX_FALL_SPEED then
    velocity_y = MAX_FALL_SPEED
    end
end

function is_object_in_air(edge, y_direction)
    return not collision_at_position(edge, player.y + 8 * y_direction)
end

function is_player_on_ground()
    local left_edge = player.x
    local right_edge = player.x + 7

    return not is_object_in_air(left_edge, 1) or not is_object_in_air(right_edge, 1)
end

function jump()
    if btnp(2) and is_player_on_ground() then
        velocity_y = -JUMP_HEIGHT
        sfx(02)
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
    -- Reduziere den Timer für den Feuereffekt
    if weapon_effects.fire_effect_duration > 0 then
        weapon_effects.fire_effect_duration -= 1
    end
    if shooting_cooldown > 0 then
        shooting_cooldown -= 1
    end
end

function check_shot_collision(shot)
    local tx = flr((shot.x + 4) / 8)
    local ty = flr((shot.y + 4) / 8)
    return fget(mget(tx, ty), 0)
end

function draw_title_screen()
    -- Draw the title
    draw_long_sprite(SCREEN_WIDTH/4, title_y)
    --print("ShellShockLite", 46, title_y, 7)

    -- Draw the prompt to start
    if title_y >= 40 then
        print("Press c to begin", (SCREEN_WIDTH/4)-2, 80, 7)
    end
end

function draw_long_sprite(x, y)
    local sprite = 64
    for i = 0, 6 do
        spr(sprite + i, x + (i*8), y)
    end
end

function draw_game()
    cls(12)
    camera(camera_x, camera_y)
    map()
    spr(BORDER_SPRITE, 8, 40)
    spr(BORDER_SPRITE, 8, 32)
    spr(BORDER_SPRITE, 8, 26)
    spr(player.current_sprite, player.x, player.y)

    draw_fire_effect()
    draw_shots()
    draw_explosions()

    -- Kamera zurücksetzen, um UI-Elemente fest zu zeichnen
    camera(0, 0)

    print("x=" .. player.x .. " y=" .. player.y, 0, 0, 7)
end
