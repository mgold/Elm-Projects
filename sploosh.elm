-- Sploosh Ball by Max Goldstein

import Window
import Mouse

-- Model
type Spoke = ((Float,Float), Color)

-- Update
curColor : Signal Color
curColor = (\h -> hsv (h/1800) 1 1) <~ foldp (+) 0 (fps 50)

-- Don't display spokes shorter than
cutoff = 20
-- Don't display when mouse is this close to an edge
edge = 10

-- Part of the Polar Library
mousePolar : Signal (Float,Float)
mousePolar = let
    half n = toFloat n / 2
    center (w,h) (x,y) = (half w - toFloat x, half h - toFloat y)
    centered = center <~ Window.dimensions ~ Mouse.position
  in (\(r,t) -> (r,pi-t)) . toPolar <~ centered

spokes : Signal [Spoke]
spokes = foldp (::) [] (sampleOn Mouse.clicks (lift2 (,) mousePolar curColor))
    |> dropWhen (lift (\(r,_) -> r < cutoff) mousePolar) []

-- initial rotating spoke
angle : Signal Float
angle = foldp (+) 0 <| lift ((*) 0.001) (fpsWhen 20 (isEmpty <~ spokes))

rotSpoke : (Int, Int) -> Float -> Color -> Spoke
rotSpoke (w,h) ang c = let
    r = min w h |> toFloat |> (*) 0.3 |> (*) (sin (0.8*ang) + 0.5)
        in ((r, ang), c)

-- Display

drawSpoke : Spoke -> Form
drawSpoke ((r,t),c) = 
  group [polygon [(0,-20),(0,20),(r,5),(r,-5)] |> filled c
          , oval 20 40 |> filled c
          , circle 5 |> filled c |> moveX r
          ]
    |> rotate t

scene : (Int,Int) -> (Int, Int) -> (Float, Float) -> Color -> [Spoke] -> Float -> Element
scene (w,h) (x,y) (r,t) c spks ang = collage w h <|
    if | x == 0 && y == 0 -> [rotSpoke (w,h) ang c |> drawSpoke]
       | r < cutoff ||
         x < edge || y < edge ||
         x + edge > w || y + edge > h -> map drawSpoke (reverse spks)
       | otherwise  -> map drawSpoke (reverse (((r,t),c)::spks))

main = scene <~ Window.dimensions ~ Mouse.position ~ mousePolar ~ curColor ~ spokes ~ angle
