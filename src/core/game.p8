pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

X = 64  Y = 64
FUNCTION _UPDATE()
  IF (BTN(0)) THEN X=X-1 END
  IF (BTN(1)) THEN X=X+1 END
  IF (BTN(2)) THEN Y=Y-1 END
  IF (BTN(3)) THEN Y=Y+1 END
END

FUNCTION _DRAW()
  CLS(5)
  CIRCFILL(X,Y,7,14)
END