-- Start-coordinates
x = 0
y = 40
-- Velocity
velocity_y = 0
--constants
PLAYER_SPRITE = 1
GRAVITY = 0.3
MAX_FALL_SPEED = 3
BORDER_LEFT_SPRITE = 6
BORDER_RIGHT_SPRITE = 8



function sign(a)
    return a < 0 and -1 or (a > 0 and 1 or 0)
end

function abs(a)
    return a < 0 and -a or a
end

function solid_at(px, py)
    local tx = flr(px / 8)
    local ty = flr(py / 8)

    return fget(mget(tx, ty), 0)
end

function calculateVelocity()
    velocity_y = velocity_y + GRAVITY
    if velocity_y > MAX_FALL_SPEED then
    velocity_y = MAX_FALL_SPEED
    end
end

function apply_gravity()
    local dir = sign(velocity_y)
    local pixels = flr(abs(velocity_y))

    for i=1, pixels do
        if not solid_at(x+4, y+8*dir) then
            y = y + dir
        else
            velocity_y = 0
            break
        end
    end
end

function apply_horizontal()
    local dx = (btn(1) and 1 or 0) - (btn(0) and 1 or 0)

    if dx ~= 0 then
        if not solid_at(x + dx*8, y+4) then
            x = x + dx
        end
    end
end

function _update()
    calculateVelocity()
    apply_gravity()
    apply_horizontal()
end

function _draw()
    cls(5)
    map()
    spr(BORDER_LEFT_SPRITE,0,40)
    spr(BORDER_RIGHT_SPRITE,125, 96)
    spr(PLAYER_SPRITE, x, y)
    print("x="..x.." y="..y, 0, 0, 7)
end
