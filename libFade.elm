module Fade where
import Window

data Ease = Linear | SineOut

ease : Ease -> Float -> Float
ease ef x = case ef of
    Linear -> x
    SineOut -> sin (x * turns 0.25)

{-| Interpolation `frac` distance between `a` and `b`, where `0 <= frac <= 1`.-}
interpolate : Ease -> Float -> Float -> Float -> Float
interpolate ef a b frac = a + ease ef frac * (b - a)

{-| Interpolation between colors. -}
interpolateColor : Color -> Color -> Float -> Color
interpolateColor (Color r1 g1 b1 a1) (Color r2 g2 b2 a2) frac = Color
    (truncate (interpolate Linear (toFloat r1) (toFloat r2) frac))
    (truncate (interpolate Linear (toFloat g1) (toFloat g2) frac))
    (truncate (interpolate Linear (toFloat b1) (toFloat b2) frac))
    (interpolate Linear a1 a2 frac)

{-| Count at a steady rate from 0 to 1 over the amount of time given each time
the input signal changes -}
fade : Time -> Signal a -> Signal Float
fade dt trig = let
    plusReset t acc = if t == 0 then 0 else acc + t
    active = dt `since` trig
    clock = foldp plusReset 0 (fpsWhen 50 active)
       in (\t -> inMilliseconds t / inMilliseconds dt) <~ clock

-- Todo: go both ways (require input to be Signal Bool?)
{-| Fade between Colors over a Time when the input signal changes. -}
fadeColor : Color -> Color -> Time -> Signal Bool -> Signal Color
fadeColor c1 c2 dt trig = let
    trues  = interpolateColor <~ constant c1 ~ constant c2 ~ fade dt (keepIf id True trig)
    falses = interpolateColor <~ constant c2 ~ constant c1 ~ fade dt (keepIf not False trig)
        in merge trues falses

-- Todo: fade between rects and circles

-- Testing code
--main = asText <~ fade (0.8*second) (fps 0.5)

bg (w,h) clr = collage w h [rect (toFloat w) (toFloat h) |> filled clr]
main = let trues = (\_->True) <~ fps 0.5
           falses = (\_->False) <~ delay second trues
           trig = merge trues falses
       in bg <~ Window.dimensions ~ fadeColor blue red second trig

