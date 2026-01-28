shots = {}
explosions = {}
weapon_type = {
    "normal_shot",
    "grenade_shot"
}
weapon_effects = {
    fire_effect_duration = 0,

    normal_shot = {
        fire_sound = "01",
        hit_sound = "03"
    },
    grenade_shot = {
        explosion_effect_duration = 0,
        explosion_sound = "04"
    }
}

-- Shooting
shooting_cooldown = 0

function check_is_boarder(x, y)
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local t = mget(tx, ty)

    -- Border-Sprites schützen
    if t == 4
            or t == 5
            or t == 20
            or t == 21 then
    return true
    end

    return false
end

function create_shot(type, x, y, direction)
    local shot = {
        type = type,
        x = x,
        y = y,
        direction = direction,
        active = true,
        time = 0,
        max_time = 30, -- Standard value: 30
        height = 3, -- Standard value: 3
        speed = 2 -- Standard value: 2
    }
    shot_start_coords = x
    add(shots, shot)
end

function update_shots()
    local active_shots = 0
    for shot in all(shots) do
        if shot.active then
            active_shots += 1
            if shot.type == "normal_shot" then
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

    if active_shots == 0 and player_mode == PLAYER_MODE.SHOOTING then
        player_mode = PLAYER_MODE.DRIVING
    end
    enable_driving_mode()
end

function update_parabolic_shot(shot)
    shot.time += 1
    shot.y += GRAVITY

    local vertex = 0.5 -- Scheitelpunkt der Parabel in der Mitte der Flugzeit
    local t = shot.time / shot.max_time
    local parabolic_strength = -4 -- Standard value: -4
    local parabolic_amplitude = parabolic_strength * shot.height * (t - vertex)^2 + shot.height


    shot.x = shot.x + shot.speed * shot.direction
    shot.y = shot.y - parabolic_amplitude

    if check_shot_collision(shot) then
        -- Nur Kreuz erzeugen, wenn kein Border
        if not check_is_boarder(shot.x, shot.y) then
            make_cross_hole(shot.x, shot.y)
            create_explosion(shot.x, shot.y)
        end

        -- Schuss in jedem Fall deaktivieren
        shot.active = false
    end
end

function update_normal_shot(shot)
    -- Schuss bewegen
    shot.x = shot.x + shot.speed * shot.direction

    -- Kollision prüfen
    if check_shot_collision(shot) then
        -- Nur zerstören, wenn kein Border
        if not check_is_boarder(shot.x, shot.y) then
            make_hole(shot.x, shot.y)
        end

        -- Schuss wird in jedem Fall deaktiviert
        shot.active = false
    end
end

function draw_shots()
    for shot in all(shots) do
        if shot.active then
            if shot.type == "normal_shot" then
                draw_normal_shot(shot)
            elseif shot.type == "grenade_shot" then
                draw_grenade_shot(shot)
            end
        end
    end
end

function draw_normal_shot(shot)
    if player.current_sprite == PLAYER_SPRITE_RIGHT then
        spr(NORMAL_SHOT_SPRITE_RIGHT, shot.x-2, shot.y)
    elseif player.current_sprite == PLAYER_SPRITE_LEFT then
        spr(NORMAL_SHOT_SPRITE_LEFT, shot.x-6, shot.y)
    end
end

function draw_grenade_shot(shot)
    spr(GRENADE_SHOT_SPRITE, shot.x-2, shot.y)
end

-- Explosion
function create_explosion(x, y)
    add(explosions, {
        x = x,
        y = y,
        timer = 10  -- Dauer der Explosion in Frames
    })
end

function update_explosions()
    for i = #explosions, 1, -1 do
        explosions[i].timer -= 1
    if explosions[i].timer <= 0 then
    del(explosions, explosions[i])
        end
    end
end

function draw_explosions()
    for explosion in all(explosions) do
        spr(EXPLOSION_EFFECT_SPRITE, explosion.x - 4, explosion.y - 4)
        sfx(00)
    end
end

function make_cross_hole(x, y)
    local tx = flr(x/8)
    local ty = flr(y/8)

    -- Kreuzmuster: Zentrum + 4 Richtungen
    local positions = {
        {0, 0},  -- Zentrum
        {1, 0},  -- rechts
        {-1, 0}, -- links
        {0, 1},  -- unten
        {0, -1}  -- oben
    }

    for pos in all(positions) do
        local nx = tx + pos[1]
        local ny = ty + pos[2]

        -- Nur zerstören, wenn kein Border
        local t = mget(nx, ny)
        if t ~= BORDER_SPRITE_LEFT
                and t ~= BORDER_SPRITE_RIGHT
                and t ~= 4
                and t ~= 5
                and t ~= 20
                and t ~= 21 then
            mset(nx, ny, 0)
        end
    end
end


function damage_tile_at(x, y)
    local tx = flr(x/8)
    local ty = flr(y/8)
    local t = mget(tx, ty)

    if t == 02 or t == 34 or t == 36 then
        mset(tx, ty, 14) -- leicht beschädigt
    elseif t == 14 then
        mset(tx, ty, 46) -- stark beschädigt
    elseif t == 46 then
        mset(tx, ty, 26)  -- weg
    end
end

function make_hole(x, y)
    local tx = flr(x/8)
    local ty = flr(y/8)
    local t = mget(tx, ty)

    if t ~= BORDER_SPRITE_LEFT
            and t ~= BORDER_SPRITE_RIGHT
            and t ~= 4
            and t ~= 5
            and t ~= 20
            and t ~= 21 then
        mset(tx, ty, 0)
    end
end


function draw_fire_effect()
    if weapon_effects.fire_effect_duration > 0 then
        if player.current_sprite == PLAYER_SPRITE_RIGHT then
            spr(FIRE_EFFECT_LEFT_RIGHT, player.x + 8, player.y)
        else
            spr(FIRE_EFFECT_LEFT_LEFT, player.x - 8, player.y)
        end
    end
end


--- Aufgabe Max ---
--- Aktuell können Schüsse Boarders-Tiles zerstören
--- Prüfen, ob der Schuss ein Border-Tile getroffen hat, wenn ja return
--- Boarder Sprite sind BORDER_SPRITE_LEFT = 6 & BORDER_SPRITE_RIGHT = 7
--- Falls Boarder entfernt werden, kann diese Funktion gelöscht werden
---
