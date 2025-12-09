# Pico 8 functions explained:

## btn(n)
btn(n) - returns true if button n is pressed (0=left, 1 = right, 2 = up, 3 = down)
## fget(tile, flag)
fget(tile, flag) - returns true if the specified flag is set for the given
## mget(tx, ty)
returns the tile index at the specified tile coordinates
## spr(sprite_index, x, y)
spr(sprite_index, x, y) - draws the sprite at the specified coordinates
## flr(value)
flr(value) - Round a number down\
Example: flr(3.7) == 3 and flr(-3.7) == -4