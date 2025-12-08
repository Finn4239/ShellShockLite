x = 0
y = 40

PLAYER_SPRITE = 1
GRAVITY = 0.3
MAX_FALL_SPEED = 3

velocity_y = 0

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
    if dx == 0 then return end

    -- zwei Testpunkte:
    local top_y = y + 1
    local bottom_y = y + 7

    if not solid_at(x + dx*8, top_y)
            and not solid_at(x + dx*8, bottom_y) then
        x = x + dx
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
    spr(PLAYER_SPRITE, x, y)
    print("x="..x.." y="..y, 0, 0, 7)
end
