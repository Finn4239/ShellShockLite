weapons = {
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
shots = {}  -- Tabelle für alle Schüsse
shooting_cooldown = 0
shot_start_coords = 0 --only for debug info

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

    if active_shots == 0 and player_mode == PLAYER_MODE.SHOOTING then
        player_mode = PLAYER_MODE.DRIVING
    end
    enable_driving_mode()
end

function update_parabolic_shot(shot)
    shot.time = shot.time + 1

    local t = shot.time / shot.max_time
    local y_offset = -4 * shot.height * (t - 0.5)^2 + shot.height

    shot.x = shot.x + shot.speed * shot.direction
    shot.y = shot.y - y_offset

    if check_shot_collision(shot) then
        make_cross_hole(shot.x, shot.y) -- <-- Kreuz anstatt einzelnes Loch
        shot.active = false
        create_explosion(shot.x, shot.y)
    end
end

function update_normal_shot(shot)

    shot.x = shot.x + shot.speed * shot.direction

    if check_shot_collision(shot) then
        make_hole(shot.x, shot.y)
        shot.active = false
    end
end

function draw_shots()
    for shot in all(shots) do
        if shot.active then
            if weapons == "normal_shot" then
                draw_normal_shot(shot)
            elseif weapons == "grenade_shot" then
                draw_grenade_shot(shot)
            end
        end
    end
end

function draw_normal_shot(shot)
    if player.current_sprite == PLAYER_SPRITE_RIGHT then
        spr(NORMAL_SHOT_SPRITE_RIGHT, shot.x-2, shot.y)
    elseif player.current_sprite == PLAYER_SPRITE_LEFT then
        spr(NORMAL_SHOT_SPRITE_LEFT, shot.x-6, shot.y+1)
    end
end

function draw_grenade_shot(shot)
    spr(GRENADE_SHOT_SPRITE, shot.x-2, shot.y)
end

-- Explosion
explosions = {}
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
    end
end

-- Weapon Helpers
function make_cross_hole(x, y)
    -- x und y = Pixel-Koordinaten des Treffpunkts
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
        mset(nx, ny, 0) -- 0 = Luft
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

function make_hole(x,y)
    local tx = flr(x/8)
    local ty = flr(y/8)
    mset(tx,ty,0) -- 0 = Luft
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




