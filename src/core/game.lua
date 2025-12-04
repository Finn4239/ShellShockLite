-- START-Coordinates
x = 10
y = 40
-- constants
PLAYER_SPRITE = 1
BOTTOM_SPRITE = 4
BORDER_LEFT_SPRITE = 6
BORDER_RIGHT_SPRITE = 8

function _draw()
    cls(5)
    map()
    spr(PLAYER_SPRITE, x, y)
    spr(BORDER_LEFT_SPRITE,0,40)
    spr(BORDER_RIGHT_SPRITE,125, 96)
    print("x="..x.." y="..y, 0, 0, 7) --debug output
end

function _update()
    -- Save player coordinates
    local lx = x
    local ly = y

    if btn(0) then x = x - 1 end -- move left
    if btn(1) then x = x + 1 end -- move right
    if btn(2) then y = y - 1 end --move down
    if btn(3) then y = y + 1 end -- move up

    if isObstacle() then
        x = lx
        y = ly
    end

end

function isObstacle()
    local tx = flr((x+7) / 8)
    local ty = flr((y+7) / 8)

    return fget(mget(tx, ty), 0)
end

function gravity()

end


