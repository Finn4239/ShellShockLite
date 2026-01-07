-- healthbar.lua

function draw_health_bar(hp, max_hp, x, y, w, h, col_bg, col_fg)
    -- Definition der Farben
    col_bg = col_bg or 1  -- Standard: weiß
    col_fg = col_fg or 8  -- Standard: rot

    -- Hintergrund des Lebensbalkens
    rectfill(x, y, x + w, y + h, col_bg)

    -- Berechnung des Füllstands
    local ratio = hp / max_hp
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end

    local fill_w = flr(w * ratio)
    rectfill(x, y, x + fill_w, y + h, col_fg)

    -- Rahmen zeichnen
    rect(x, y, x + w, y + h, 7)
end
