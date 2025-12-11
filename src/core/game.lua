--constants
GRAVITY = 0.3
MAX_FALL_SPEED = 3
JUMP_HEIGHT = 4
-- Sprite indices
PLAYER_SPRITE_LEFT = 0
PLAYER_SPRITE_RIGHT = 1
BORDER_SPRITE = 6
-- Screen dimensions
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128
-- Start-coordinates
x = 24
y = 40
current_sprite = PLAYER_SPRITE_RIGHT
can_jump = true
-- Velocity
velocity_y = 0
-- Camera
camera_x = 0
camera_y = 0
camera_threshold_x = 32  -- Wie nah der Spieler am Bildschirmrand sein muss, bevor die Kamera scrollt
camera_threshold_y = 24


function applyVerticalMovement()
    local y_direction = getVerticalDirection(velocity_y)
    local amount_of_pixels = flr(absoluteValue(velocity_y))

    for i = 1, amount_of_pixels do
        local left_edge = x
        local right_edge = x + 7 -- 7 because 8 sprite width (-1)

        if isObjectInAir(left_edge, y_direction) and isObjectInAir(right_edge, y_direction) then
            y = y + y_direction
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
        current_sprite = PLAYER_SPRITE_LEFT
    else left = 0 end

    if btn(1) then right = 1
        current_sprite = PLAYER_SPRITE_RIGHT
    else right = 0 end

    x_direction = right - left

    if x_direction ~= 0 then
        movePlayerHorizontally(x_direction)
    end
end

function movePlayerHorizontally(x_direction)
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
    return not collisionAtPosition(edge, y + 8 * y_direction)
end

function isPlayerOnGround()
    local left_edge = x
    local right_edge = x + 7

    return not isObjectInAir(left_edge, 1) or not isObjectInAir(right_edge, 1)
end

-- Camera-Functions
function updateCamera()
    -- Horizontales Scrolling
    if x - camera_x > SCREEN_WIDTH/2 + camera_threshold_x then
        camera_x = x - (SCREEN_WIDTH/2 + camera_threshold_x)
    elseif x - camera_x < SCREEN_WIDTH/2 - camera_threshold_x then
        camera_x = x - (SCREEN_WIDTH/2 - camera_threshold_x)
    end

    -- Vertikales Scrolling (optional, falls du es brauchst)
    if y - camera_y > SCREEN_HEIGHT/2 + camera_threshold_y then
        camera_y = y - (SCREEN_HEIGHT/2 + camera_threshold_y)
    elseif y - camera_y < SCREEN_HEIGHT/2 - camera_threshold_y then
        camera_y = y - (SCREEN_HEIGHT/2 - camera_threshold_y)
    end

    -- Kamera-Grenzen (damit die Kamera nicht außerhalb der Map scrollt)
    camera_x = mid(0, camera_x, SCREEN_WIDTH * 8 - SCREEN_WIDTH)  -- Annahme: Map ist 128x64 Tiles groß
    camera_y = mid(0, camera_y, SCREEN_HEIGHT * 8 - SCREEN_WIDTH)   -- Annahme: Map ist 128x64 Tiles groß
end



-- Pico-8 Standard Functions
function _update()
    calculateVerticalVelocity(MAX_FALL_SPEED)

    if btn(2) and isPlayerOnGround() and can_jump then
        velocity_y = -JUMP_HEIGHT
        can_jump = false
    end

    if isPlayerOnGround() then
        can_jump = true
    end

    applyVerticalMovement()
    applyHorizontalMovement()
    updateCamera()
end

function _draw()
    cls(1)
    camera(camera_x, camera_y)
    map()
    spr(BORDER_SPRITE,8,40)
    spr(BORDER_SPRITE, 8, 32)
    spr(BORDER_SPRITE, 8, 26)
    spr(current_sprite, x, y)
    camera(0,0)
    print("x="..x.." y="..y, 0, 0, 7)
end
