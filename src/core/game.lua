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

function getVerticalDirection(a)
    if a < 0 and -1 then
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

function applyVerticalMovement()
    local y_direction = getVerticalDirection(velocity_y)
    local amount_of_pixels = flr(absoluteValue(velocity_y))
    local sprite_width = 8

    for i = 1, amount_of_pixels do
        local left_edge = x
        local right_edge = x + sprite_width - 1

        if isObjectInAir(left_edge, y_direction) and isObjectInAir(right_edge, y_direction) then
            y = y + y_direction
        else
            velocity_y = 0
            break
        end
    end
end

function isObjectInAir(edge, y_direction)
    return not collisionAtPosition(edge, y + 8 * y_direction)
end

function applyHorizontalMovement()
    local x_direction = 0
    local left = 0
    local right = 0

    if btn(0) then left = 1 else left = 0 end
    if btn(1) then right = 1 else right = 0 end

    x_direction = right - left

    if x_direction ~= 0 then
        if x_direction > 0 then -- right
            if not collisionAtPosition(x + x_direction *8, y+4) then
                x = x + x_direction
            end
        else --left
            if not collisionAtPosition(x + x_direction, y+4) then
                x = x + x_direction
            end
        end
    end
end

function _update()
    calculateVerticalVelocity()
    applyVerticalMovement()
    applyHorizontalMovement()
end

function _draw()
    cls(5)
    map()
    spr(BORDER_SPRITE,0,40)
    spr(PLAYER_SPRITE, x, y)
    print("x="..x.." y="..y, 0, 0, 7)
end
