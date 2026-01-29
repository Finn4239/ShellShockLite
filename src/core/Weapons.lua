shots = {}
explosions = {}
weapon_types = {
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
        explosion_sound = "00"
    }
}

-- Shooting
shooting_cooldown = 0

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

    remove_inactive_shots()

    -- Only necessary if player_mode is used elsewhere
    if active_shots == 0 and player_mode == PLAYER_MODE.SHOOTING then
        player_mode = PLAYER_MODE.DRIVING
    end

    enable_driving_mode()
end

function update_parabolic_shot(shot)
    shot.time += 1

    local vertex = 0.5 -- Scheitelpunkt der Parabel in der Mitte der Flugzeit
    local t_normalized = shot.time / shot.max_time
    local parabolic_strength = -4 -- Standard value: -4
    local amplitude = parabolic_strength * shot.height * (t_normalized - vertex)^2 + shot.height

    shot.x = shot.x + shot.speed * shot.direction -- Schuss horizontal bewegen
    shot.y = shot.y - amplitude + GRAVITY -- Schuss vertikal bewegen (GRAVITY hinzufügen, um den Fall zu simulieren)

    handle_grenade_collision(shot)
end

function update_normal_shot(shot)
    -- Schuss bewegen
    shot.x = shot.x + shot.speed * shot.direction

    handle_normal_shot_collision(shot)
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
        spr(NORMAL_SHOT_SPRITE_RIGHT, shot.x-2, shot.y-2)
    elseif player.current_sprite == PLAYER_SPRITE_LEFT then
        spr(NORMAL_SHOT_SPRITE_LEFT, shot.x-6, shot.y-2)
    end
end

function draw_grenade_shot(shot)
    spr(GRENADE_SHOT_SPRITE, shot.x-2, shot.y)
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
        spr(EXPLOSION_EFFECT_SPRITE, explosion.x - 8, explosion.y - 8,2,2)
    end
end

-- Help functions
function make_cross_hole(x, y)
    local tx = flr(x/8)
    local ty = flr(y/8)

    local positions = { -- Kreuzmuster: Zentrum + 4 Richtungen
        {0, 0},  -- Zentrum
        {1, 0},  -- rechts
        {-1, 0}, -- links
        {0, 1},  -- unten
        {0, -1}  -- oben
    }

    for pos in all(positions) do
        local nx = tx + pos[1]
        local ny = ty + pos[2]
        local t = mget(nx, ny)

        if t ~= 4 and t ~= 5 and t ~= 10 and t ~= 26 and t ~= 20 and t ~= 21
                and not fget(t, BACKGROUND_OBJECTS) then -- normales Tile zerstören
            mset(nx, ny, 0)
            sfx(weapon_effects.grenade_shot.explosion_sound)
        end
    end
end

function make_hole(x, y)
    local tx = flr(x/8)
    local ty = flr(y/8)
    local t = mget(tx, ty)

    if t ~= 4 and t ~= 5
            and t ~= 10 and t ~= 26
            and t ~= 20 and t ~= 21
           then -- normales Tile zerstören
        mset(tx, ty, 0)
        sfx(weapon_effects.normal_shot.hit_sound)
        sfx(06)
    end
end

function check_is_boarder(x, y)
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local tile = mget(tx, ty)

    -- Border-Sprites schützen, aber Flag 2 (Hintergrund Objekte) ignorieren
    if (tile == 4 or tile == 5 or tile == 20 or tile == 21) and not fget(tile, BACKGROUND_OBJECTS) then
        return true
    end
    return false
end

function check_shot_collision_at(x, y)
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local tile = mget(tx, ty)

    -- Ignoriert Tiles mit Flag 2 (Hintergrund Objekte)
    if tile == 0 or fget(tile, BACKGROUND_OBJECTS) then
        return false
    end
    return true
end


function handle_grenade_collision(shot)
    local collision_x = shot.x + shot.direction * 2
    local collision_y = shot.y

    if check_shot_collision_at(collision_x, collision_y) then
        if not check_is_boarder(collision_x, collision_y, shot.direction) then
            make_cross_hole(collision_x, collision_y)
            create_explosion(collision_x, collision_y)
        end
        shot.active = false
    end
end

function handle_normal_shot_collision(shot)
    -- Kollision prüfen
    local collision_x = shot.x + shot.direction * 2
    local collision_y = shot.y

    if check_shot_collision_at(collision_x, collision_y) then
        if not check_is_boarder(collision_x, collision_y, shot.direction) then
            make_hole(collision_x, collision_y)
        end
        shot.active = false
    end
end

function remove_inactive_shots()
    for i = #shots, 1, -1 do
        if not shots[i].active then
            del(shots, shots[i])
        end
    end

end

function check_shot_collision(shot)
    local tx = flr((shot.x + 4) / 8)
    local ty = flr((shot.y + 4) / 8)

    return fget(mget(tx, ty), 0)
end
