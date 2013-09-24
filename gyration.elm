-- Gyrations by Max Goldstein

import Window

main = scene <~ foldp (+) 0 (fps 40) ~ Window.dimensions

scene t (w,h) =
  let minr = 14
      maxr = 40
      time = inSeconds t
      angle = time*0.8
      colorAngle = -angle/8
      opposite = angle + turns (1/3)
      angle2 = angle + turns (1/3)
      angle3 = angle + turns (2/3)
      angle' = angle + turns (1/6)
      angle2' = angle2 + turns (1/6)
      angle3' = angle3 + turns (1/6)
      edge = min (toFloat w/2) (toFloat h/2)
      r  = radiusScale minr maxr angle
      r' = radiusScale minr maxr opposite
      d  = displacementScale edge maxr angle
      d' = displacementScale edge maxr opposite
  in collage w h
  [rect (toFloat w) (toFloat h)
     |> filled black

  , circle r
    |> gradient (particleGradient (angle+colorAngle) r)
    |> movePolar (d, angle)
  , circle r
    |> gradient (particleGradient (angle2+colorAngle) r)
    |> movePolar (d, angle2)
  , circle r
    |> gradient (particleGradient (angle3+colorAngle) r)
    |> movePolar (d, angle3)

  , circle r'
    |> gradient (particleGradient (angle'+colorAngle) r')
    |> movePolar (d', angle')
  , circle r'
    |> gradient (particleGradient (angle2'+colorAngle) r')
    |> movePolar (d', angle2')
  , circle r'
    |> gradient (particleGradient (angle3'+colorAngle) r')
    |> movePolar (d', angle3')
  ]


-- Helper functions

radiusScale minr maxr angle = fracSinusoid angle * (maxr-minr) + minr

displacementScale edge maxr angle = let mindisp = 20
  in fracSinusoid angle * (edge - 2*maxr - mindisp + 30)  + mindisp

particleGradient angle r = radial (0,0) 0 (0,0) r
          [(0  , hsv angle 1 1),
           (0.6, hsv angle 0.6 0.5),
           (1  , black)]

fracSinusoid : Float -> Float
fracSinusoid angle = let k = 1.7 -- period distortion constant
                     in (cos (k*angle) + 1) / 2

-- Should be part of the language - part of the Polar Library

movePolar : (Float, Float) -> Form -> Form
movePolar (r, theta) = move <| fromPolar (r, theta)
