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

-- Display

drawSpoke : Spoke -> Form
drawSpoke ((r,t),c) = 
  group [polygon [(0,-20),(0,20),(truncate r,5),(truncate r,-5)] |> filled c
          , oval 20 40 |> filled c
          , circle 5 |> filled c |> moveX r
          ]
    |> rotate t

scene : (Int,Int) -> (Float, Float) -> Color -> [Spoke] -> Element
scene (w,h) (r,t) c spks =
  collage w h <| if r < cutoff then map drawSpoke (reverse spks)
                 else map drawSpoke (reverse (((r,t),c)::spks))

main = scene <~ Window.dimensions ~ mousePolar ~ curColor ~ spokes
