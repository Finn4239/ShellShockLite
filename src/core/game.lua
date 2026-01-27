--constants
GRAVITY = 0.3
MAX_FALL_SPEED = 3
JUMP_HEIGHT = 4
-- Sprite indices
PLAYER_SPRITE_LEFT = 0
PLAYER_SPRITE_RIGHT = 1
BORDER_SPRITE = 6
NORMAL_SHOT_SPRITE = 16
GRENADE_SHOT_SPRITE = 32
FIRE_EFFECT_LEFT_RIGHT = 10
FIRE_EFFECT_LEFT_LEFT = 11
EXPLOSION_EFFECT_SPRITE = 12
-- Map dimensions
MAP_WIDTH = 128*8
MAP_HEIGHT = 30*8
-- Screen dimensions
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128
-- Velocity
velocity_y = 0
-- Camera
camera_x = 0
camera_y = 0
camera_threshold_x = 1  -- Wie nah der Spieler am Bildschirmrand sein muss, bevor die Kamera scrollt
camera_threshold_y = 25
-- Shooting
shots = {}  -- Tabelle für alle Schüsse
can_shoot = true
shot_start_coords = 0 --only for debug info
weapons = {
    "normal_shot",
    "grenade_shot"
}
-- Game State
game_state = "title" -- Possible states: "title", "playing", "game_over"
-- Player Mode
player_mode = "driving" -- Possible modes: "driving", "shooting"
-- Title Screen Variables
title_y = -20 -- Initial Y position of the title
title_speed = 1 -- Speed of the title sliding down

player = {
    x = 24,
    y = 40,
    current_sprite = PLAYER_SPRITE_RIGHT;
    w = 8,
    h = 8,
    health = 200,
    dx = 0, -- Player velocity X
    dy = 0  -- Player velocity Y
}

fire_effect_timer = 0
explosion_effect_timer = 0

-- Movement-Functions
function apply_vertical_movement()
    local y_direction = get_vertical_direction(velocity_y)
    local amount_of_pixels = flr(absolute_value(velocity_y))

    for i = 1, amount_of_pixels do
        local left_edge = player.x
        local right_edge = player.x + 7 -- 7 because 8 sprite width (-1)

        if is_object_in_air(left_edge, y_direction) and is_object_in_air(right_edge, y_direction) then
            player.y = player.y + y_direction
        else
            velocity_y = 0
            break
        end
    end
end

function apply_horizontal_movement()
    local x_direction = 0
    local left = 0
    local right = 0

    if btn(0) then left = 1
        player.current_sprite = PLAYER_SPRITE_LEFT
    else left = 0 end

    if btn(1) then right = 1
        player.current_sprite = PLAYER_SPRITE_RIGHT
    else right = 0 end

    x_direction = right - left

    if x_direction ~= 0 then
        move_player_horizontally(x_direction)
    end
end

function move_player_horizontally(x_direction)
    if x_direction > 0 then -- right
        if not collision_at_position(player.x + x_direction * 8, player.y + 4) then
            player.x += x_direction
        end
    else --left
        if not collision_at_position(player.x + x_direction, player.y + 4) then
            player.x += x_direction
        end
    end
end

-- Camera-Functions
function update_camera()
    -- Horizontales Scrolling
    if player.x - camera_x > SCREEN_WIDTH/2 + camera_threshold_x then
        camera_x = player.x - (SCREEN_WIDTH/2 + camera_threshold_x)
    elseif player.x - camera_x < SCREEN_WIDTH/2 - camera_threshold_x then
        camera_x = player.x - (SCREEN_WIDTH/2 - camera_threshold_x)
    end

    -- Vertikales Scrolling
    if player.y - camera_y > SCREEN_HEIGHT/2 + camera_threshold_y then
        camera_y = player.y - (SCREEN_HEIGHT/2 + camera_threshold_y)
    elseif player.y - camera_y < SCREEN_HEIGHT/2 - camera_threshold_y then
        camera_y = player.y - (SCREEN_HEIGHT/2 - camera_threshold_y)
    end

    -- Kamera-Grenzen (damit die Kamera nicht außerhalb der Map scrollt)
    camera_x = mid(0, camera_x, SCREEN_WIDTH * 8 - SCREEN_WIDTH)
    camera_y = mid(0, camera_y, SCREEN_HEIGHT * 8 - SCREEN_WIDTH)
end

-- Shooting-Functions
function create_shot(x, y, direction)
    local shot = {
        x = x,
        y = y,
        direction = direction,
        active = true,
        time = 0,
        max_time = 40,
        height = 3,
        speed = 1
    }
    shot_start_coords = x
    add(shots, shot)
end

function update_shots()
    local active_shots = 0
    for shot in all(shots) do
        if shot.active then
            active_shots += 1
            if weapons == "normal_shot" then
                update_normal_shot(shot)
            else
                update_parabolic_shot(shot)
            end

        end
    end

    -- Inaktive Schüsse entfernen
    for i = #shots, 1, -1 do
        if not shots[i].active then
            del(shots, shots[i])
        end
    end

    if active_shots == 0 and player_mode == "shooting" then
        player_mode = "driving"
    end
    enable_driving_mode()
end

-- Pico-8 Standard Functions
function _update()
    if game_state == "title" then
        -- Slide the title down
        if title_y < 40 then
            title_y = title_y + title_speed
        end

        -- Start the game when any button is pressed
        if btnp(4) then
            game_state = "playing"
        end
    end
    -- Reduziere den Timer für den Feuereffekt
    if fire_effect_timer > 0 then
        fire_effect_timer -= 1
    end

    calculate_vertical_velocity(MAX_FALL_SPEED)

    enable_driving_mode()

    if btnp(5) then
        shooting()
    end

    if btnp(4) then
        if weapons == "normal_shot" then
            weapons = "grenade_shot"
        else
            weapons = "normal_shot"
        end
    end

    update_shots()

    update_camera()
end

function shooting()
    if can_shoot and is_player_on_ground() then
        --player_mode = "shooting"
        if player.current_sprite == PLAYER_SPRITE_RIGHT then
            create_shot(player.x + 8, player.y, 1)  -- Richtung 1 = rechts
        else
            create_shot(player.x, player.y, -1)  -- Richtung -1 = links
        end
        fire_effect_timer = 3
        sfx(01)
    end
end

function _draw()
    cls()

    if game_state == "title" then
        draw_title_screen()
    elseif game_state == "playing" then
        draw_game()
    end
end

-- Help-Functions
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
    if player_mode == "driving" then
        apply_vertical_movement()
        apply_horizontal_movement()
        jump()
    end
end

function check_shot_collision(shot)
    -- Prüfe, ob der Schuss auf ein Hindernis trifft
    local tile_x = flr(shot.x / 8)
    local tile_y = flr(shot.y / 8)
    return fget(mget(tile_x, tile_y), 0)  -- Prüft, ob das Tile ein Hindernis ist
end

function update_parabolic_shot(shot)
    shot.time = shot.time + 1

    local t = shot.time / shot.max_time
    local y_offset = -4 * shot.height * (t - 0.5)^2 + shot.height

    shot.x = shot.x + shot.speed * shot.direction
    shot.y = shot.y - y_offset

    if check_shot_collision(shot) then
        shot.active = false
        spr(EXPLOSION_EFFECT_SPRITE, shot.x-4, shot.y-4)
    end
end

function update_normal_shot()
    for shot in all(shots) do
        if shot.active then
            shot.x = (shot.x + shot.speed) * shot.direction  -- Bewege den Schuss
        end
        if check_shot_collision(shot) then
            shot.active = false
        end
    end
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

function draw_fire_effect()
    if fire_effect_timer > 0 then
        if player.current_sprite == PLAYER_SPRITE_RIGHT then
            spr(FIRE_EFFECT_LEFT_RIGHT, player.x + 8, player.y)
        else
            spr(FIRE_EFFECT_LEFT_LEFT, player.x - 8, player.y)
        end
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

    -- Zeichne Schüsse
    for shot in all(shots) do
        if shot.active then
            if weapons == "normal_shot" then
                spr(16, shot.x-2, shot.y)
                
            elseif weapons == "grenade_shot" then
                spr(32, shot.x-2, shot.y)
            end
        end
    end

    -- Kamera zurücksetzen, um UI-Elemente fest zu zeichnen
    camera(0, 0)
    print("x=" .. player.x .. " y=" .. player.y, 0, 0, 7)
    print("Shoot_x startpoint: " .. shot_start_coords, 0, 7, 7)
    print("Player Mode: " .. player_mode, 0, 14, 7)
end
