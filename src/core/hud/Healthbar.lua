function draw_health_bar(hp, max_hp, x, y, w, h)
    -- def. der farben
    col_bg = 6 -- (weiß)
    col_fg = 8 -- (rot)

    -- rechteck
    rectfill(x, y, x+w, y+h, col_bg)

    -- einteilen des lebensbalkens in blれへcke
    -- wenn < 0 -> spieler hat kein leben mehr, ratio nicht weiter berechnen sonst negativ
    -- wenn > 1 -> spieler hat noch volles leben, ratio nicht weiter berechnen da sonst mehr als healthbar erlaubt
    local ratio = hp / max_hp
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end

    local fill_w = flr(w * ratio)
    rectfill(x, y, x+fill_w, y+h, col_fg)

    rect(x, y, x+w, y+h, 7)
end


