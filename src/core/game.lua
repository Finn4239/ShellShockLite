--constants
GRAVITY = 0.3
MAX_FALL_SPEED = 3
JUMP_HEIGHT = 4
-- Sprite indices
PLAYER_SPRITE_LEFT = 0
PLAYER_SPRITE_RIGHT = 1
BORDER_SPRITE = 6
SHOT_SPRITE = 16
-- Screen dimensions
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128
-- Start-coordinates
-- Velocity
velocity_y = 0
-- Camera
camera_x = 0
camera_y = 0
camera_threshold_x = 32  -- Wie nah der Spieler am Bildschirmrand sein muss, bevor die Kamera scrollt
camera_threshold_y = 24
-- Shooting
shots = {}  -- Tabelle für alle Schüsse
shot_x = 0
shot_y = 6
shot_speed = 3
can_shoot = true
cooldown = 15 -- Cooldown in Frames (z. B. 15 Frames ≈ 0.25 Sekunden)
cooldown_counter = 0 -- Zählt die Frames während des Cooldowns

-- Game State
game_state = "title" -- Possible states: "title", "playing", "game_over"
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
    dx = 0, -- Player velocity X component
    dy = 0  -- Player velocity Y component
}

function applyVerticalMovement()
    local y_direction = getVerticalDirection(velocity_y)
    local amount_of_pixels = flr(absoluteValue(velocity_y))

    for i = 1, amount_of_pixels do
        local left_edge = player.x
        local right_edge = player.x + 7 -- 7 because 8 sprite width (-1)

        if isObjectInAir(left_edge, y_direction) and isObjectInAir(right_edge, y_direction) then
            player.y = player.y + y_direction
        else
            velocity_y = 0
            break
        end
    end
end

function applyHorizontalMovement()
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
        movePlayerHorizontally(x_direction)
    end
end

function movePlayerHorizontally(x_direction)
    if x_direction > 0 then -- right
        if not collisionAtPosition(player.x + x_direction * 8, player.y + 4) then
            player.x = player.x + x_direction
        end
    else --left
        if not collisionAtPosition(player.x + x_direction, player.y + 4) then
            player.x = player.x + x_direction
        end
    end
end

-- Help-Functions
function getVerticalDirection(a)
    if a < 0 then
        return -1 -- move up
    elseif a > 0 then
        return 1 -- move down
    else
        return 0 -- no movement
    end
end

function absoluteValue(a) -- makes integer-/double-value positive
    if a < 0 then return -a end

    return a
end

function collisionAtPosition(player_x, player_y)
    local tank_x = flr(player_x / 8)
    local tank_y = flr(player_y / 8)

    return fget(mget(tank_x, tank_y), 0)
end

function calculateVerticalVelocity()
    velocity_y = velocity_y + GRAVITY
    if velocity_y > MAX_FALL_SPEED then
        velocity_y = MAX_FALL_SPEED
    end
end

function isObjectInAir(edge, y_direction)
    return not collisionAtPosition(edge, player.y + 8 * y_direction)
end

function isPlayerOnGround()
    local left_edge = player.x
    local right_edge = player.x + 7

    return not isObjectInAir(left_edge, 1) or not isObjectInAir(right_edge, 1)
end

-- Camera-Functions
function updateCamera()
    -- Horizontales Scrolling
    if player.x - camera_x > SCREEN_WIDTH/2 + camera_threshold_x then
        camera_x = player.x - (SCREEN_WIDTH/2 + camera_threshold_x)
    elseif player.x - camera_x < SCREEN_WIDTH/2 - camera_threshold_x then
        camera_x = player.x - (SCREEN_WIDTH/2 - camera_threshold_x)
    end

    -- Vertikales Scrolling (optional, falls du es brauchst)
    if player.y - camera_y > SCREEN_HEIGHT/2 + camera_threshold_y then
        camera_y = player.y - (SCREEN_HEIGHT/2 + camera_threshold_y)
    elseif player.y - camera_y < SCREEN_HEIGHT/2 - camera_threshold_y then
        camera_y = player.y - (SCREEN_HEIGHT/2 - camera_threshold_y)
    end

    -- Kamera-Grenzen (damit die Kamera nicht außerhalb der Map scrollt)
    camera_x = mid(0, camera_x, SCREEN_WIDTH * 8 - SCREEN_WIDTH)  -- Annahme: Map ist 128x64 Tiles groß
    camera_y = mid(0, camera_y, SCREEN_HEIGHT * 8 - SCREEN_WIDTH)   -- Annahme: Map ist 128x64 Tiles groß
end

function createShot(x, y, direction)
    if not can_shoot then
        return  -- Schießen nicht erlaubt, wenn Cooldown aktiv ist
    end

    local shot = {
        x = x,
        y = y,
        direction = direction,
        active = true
    }
    add(shots, shot)
    can_shoot = false  -- Schießen deaktivieren
    cooldown_counter = cooldown  -- Cooldown starten
end

function check_shot_collision(shot)
    -- Prüfe, ob der Schuss auf ein Hindernis trifft
    local tile_x = flr(shot.x / 8)
    local tile_y = flr(shot.y / 8)
    return fget(mget(tile_x, tile_y), 0)  -- Prüft, ob das Tile ein Hindernis ist
end

function update_shots()
    for shot in all(shots) do
        if shot.active then
            shot.x = shot.x + shot_speed * shot.direction  -- Bewege den Schuss

            -- Prüfe auf Kollisionserkennung
            if check_shot_collision(shot) then
                shot.active = false  -- Schuss deaktivieren, wenn er auf ein Hindernis trifft
                can_shoot = true  -- Schießen wieder erlauben
            end

            -- Schuss deaktivieren, wenn er den Bildschirm verlässt
            if shot.x < 0 or shot.x > 380 then
                shot.active = false
            end
        end
    end

    -- Inaktive Schüsse entfernen
    for i = #shots, 1, -1 do
        if not shots[i].active then
            del(shots, shots[i])
        end
    end
end

-- Pico-8 Standard Functions
function _update()
    if game_state == "title" then
        -- Slide the title down
        if title_y < 40 then
            title_y = title_y + title_speed
        end

        -- Start the game when any button is pressed
        if btnp(4) or btnp(5) or btnp(0) or btnp(1) or btnp(2) or btnp(3) then
            game_state = "playing"
        end
    end
    calculateVerticalVelocity(MAX_FALL_SPEED)

    if btnp(2) and isPlayerOnGround()then
        velocity_y = -JUMP_HEIGHT
    end

    applyVerticalMovement()
    applyHorizontalMovement()
    updateCamera()

    -- Cooldown aktualisieren
    if not can_shoot and cooldown_counter > 0 then
        cooldown_counter = cooldown_counter - 1
        if cooldown_counter == 0 then  -- Klammer hinzugefügt
            can_shoot = true
        end
    end

    -- Schuss abfeuern
    if btnp(5) and can_shoot then  -- X-Taste
        createShot(player.x + 8, player.y + 1, 1)  -- Schuss nach rechts
    end

    update_shots()
end

function _draw()
    cls()

    if game_state == "title" then
        -- Draw the title
        draw_long_sprite(SCREEN_WIDTH/4, title_y)
        --print("ShellShockLite", 46, title_y, 7)

        -- Draw the prompt to start
        if title_y >= 40 then
            print("Press c to begin", (SCREEN_WIDTH/4)-2, 80, 7)
        end
    elseif game_state == "playing" then
        draw_game()
    end

end

function draw_long_sprite(x, y)
    local sprite = 64
    for i = 0, 6 do
        spr(sprite + i, x + (i*8), y)
    end

end

function draw_game()
    cls(1)
    camera(camera_x, camera_y)
    map()
    spr(BORDER_SPRITE, 8, 40)
    spr(BORDER_SPRITE, 8, 32)
    spr(BORDER_SPRITE, 8, 26)
    spr(player.current_sprite, player.x, player.y)

    -- Kamera zurücksetzen, um UI-Elemente fest zu zeichnen
    camera(0, 0)

    -- Zeichne Schüsse
    for shot in all(shots) do
        if shot.active then
            spr(16, shot.x-3, shot.y-1)
        end
    end

    camera(0,0)
    print("x="..player.x.." y="..player.y, 0, 0, 7)
end