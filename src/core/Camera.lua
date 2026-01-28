camera_x = 0
camera_y = 0
camera_threshold_x = 1  -- Wie nah der Spieler am Bildschirmrand sein muss, bevor die Kamera scrollt
camera_threshold_y = 25

-- Camera-Functions
function update_camera()
    -- Horizontales Scrolling
    if player.x - camera_x > SCREEN_WIDTH/2 + camera_threshold_x then
        camera_x = player.x - (SCREEN_WIDTH/2 + camera_threshold_x)
    elseif player.x - camera_x < SCREEN_WIDTH/2 - camera_threshold_x then
        camera_x = player.x - (SCREEN_WIDTH/2 - camera_threshold_x)
    end

    -- Vertikales Scrolling
    if player.y - camera_y > SCREEN_HEIGHT/2 + camera_threshold_y then
        camera_y = player.y - (SCREEN_HEIGHT/2 + camera_threshold_y)
    elseif player.y - camera_y < SCREEN_HEIGHT/2 - camera_threshold_y then
        camera_y = player.y - (SCREEN_HEIGHT/2 - camera_threshold_y)
    end

    -- Kamera-Grenzen (damit die Kamera nicht außerhalb der Map scrollt)
    camera_x = mid(0, camera_x, SCREEN_WIDTH * 8 - SCREEN_WIDTH)
    camera_y = mid(0, camera_y, SCREEN_HEIGHT * 8 - SCREEN_WIDTH)
end