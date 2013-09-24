-- Polar library by Max Goldstein

-- Useful functions for polar coodinates. Some implementations can be considered
-- for standard library inclusion, and some certainly should not be.

import Window
import Mouse
import Matrix2D as M

-- position of the mouse in polar coordinates. Origin is center of window.
mousePolar : Signal (Float,Float)
mousePolar = let
    half n = toFloat n / 2
    center (w,h) (x,y) = (half w - toFloat x, half h - toFloat y)
    centered = center <~ Window.dimensions ~ Mouse.position
  in (\(r,t) -> (r,pi-t)) . toPolar <~ centered

mouseR : Signal Float
mouseR = fst <~ mousePolar

mouseTheta : Signal Float
mouseTheta = snd <~ mousePolar

--radius of the largest circle that can fit in the window
radius : Signal Int
radius = (\dims -> uncurry min dims `div` 2) <~ Window.dimensions

-- like move for Forms, but with polar coordinates
movePolar : (Float, Float) -> Form -> Form
movePolar (r, theta) = move <| fromPolar (r, theta)
-- A more low-level implementation:
-- movePolar (r,t) f = { f | x <- f.x + r * cos t, y <- f.y + r * sin t }

-- rotateAbout by John Mayer
-- rotates a Form by angle around an arbitrary centerpoint
rotateAbout : (Float,Float) -> Float -> Form -> Form
rotateAbout (x,y) angle form =
  let matrix = foldl1 M.multiply [M.matrix 1 0 0 1 -x -y, M.rotation angle, M.matrix 1 0 0 1 x y]
  in  groupTransform matrix [form]
