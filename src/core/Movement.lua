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

function jump()
    if btnp(2) and is_player_on_ground() then
        velocity_y = -JUMP_HEIGHT
        sfx(02)
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

function calculate_vertical_velocity()
    velocity_y += GRAVITY
    if velocity_y > MAX_FALL_SPEED then
    velocity_y = MAX_FALL_SPEED
    end
end
