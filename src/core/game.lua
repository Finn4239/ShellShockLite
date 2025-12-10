-- Start-coordinates
x = 8
y = 40
-- Velocity
velocity_y = 0
--constants
GRAVITY = 0.3
MAX_FALL_SPEED = 3
-- Sprite indices
PLAYER_SPRITE = 1
BORDER_SPRITE = 0

function math_sign(a)
    if a < 0 and -1 then
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

function is_solid_at_pixel(player_x, player_y)
    local tank_x = flr(player_x / 8)
    local tank_y = flr(player_y / 8)

    return fget(mget(tank_x, tank_y), 0)
end

function calculate_vertical_velocity()
    velocity_y = velocity_y + GRAVITY
    if velocity_y > MAX_FALL_SPEED then
    velocity_y = MAX_FALL_SPEED
    end
end

function apply_gravity()
    local y_direction = math_sign(velocity_y)
    local amount_of_pixels = flr(absolute_value(velocity_y))
    local sprite_width = 8

    for i = 1, amount_of_pixels do
        local left_edge = x
        local right_edge = x + sprite_width - 1
        local is_left_in_air = not is_solid_at_pixel(left_edge, y + 8 * y_direction)
        local is_right_in_air = not is_solid_at_pixel(right_edge, y + 8 * y_direction)

        if is_left_in_air and is_right_in_air then
            y = y + y_direction
        else
            velocity_y = 0
            break
        end
    end
end

function apply_horizontal()
    local x_direction = 0
    local left = 0
    local right = 0

    if btn(0) then left = 1 else left = 0 end
    if btn(1) then right = 1 else right = 0 end

    x_direction = right - left

    if x_direction ~= 0 then
        if x_direction > 0 then -- right
            if not is_solid_at_pixel(x + x_direction *8, y+4) then
                x = x + x_direction
            end
        else --left
            if not is_solid_at_pixel(x + x_direction, y+4) then
                x = x + x_direction
            end
        end
    end
end

function _update()
    calculate_vertical_velocity()
    apply_gravity()
    apply_horizontal()
end

function _draw()
    cls(5)
    map()
    spr(BORDER_SPRITE,0,40)
    spr(PLAYER_SPRITE, x, y)
    print("x="..x.." y="..y, 0, 0, 7)
end
