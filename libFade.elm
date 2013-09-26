module Fade where
import Window

{-| Linear interpolation `frac` distance between `a` and `b`, where `0 <= frac
<= 1` -}
interpolateLin : Float -> Float -> Float -> Float
interpolateLin a b frac = a + frac * (b - a)

{-| Sinusoidal interpolation `frac` distance between `a` and `b`, where `0 <=
frac <= 1` -}
interpolateSin : Float -> Float -> Float -> Float
interpolateSin a b frac = interpolateLin a b <| sin (frac * turns 0.25)

{-| Interpolation between colors. -}
interpolateColor : Color -> Color -> Float -> Color
interpolateColor (Color r1 g1 b1 a1) (Color r2 g2 b2 a2) frac = Color
    (truncate (interpolateLin (toFloat r1) (toFloat r2) frac))
    (truncate (interpolateLin (toFloat g1) (toFloat g2) frac))
    (truncate (interpolateLin (toFloat b1) (toFloat b2) frac))
    (interpolateLin a1 a2 frac)

-- generalized over time
follow : Time -> (a -> Bool) -> a -> Signal a -> Signal a
follow dt pred follower sig = let
    leadersig = keepIf pred follower sig
    followsig = delay dt (sampleOn leadersig (constant follower))
  in merge followsig sig

{-| Count at a steady rate from 0 to 1 over the amount of time given each time
the input signal changes -}
fade : Time -> Signal a -> Signal Float
fade dt trig = let
    plusReset t acc = if t == 0 then 0 else acc + t
    active = follow dt id False <| lift (\_ -> True) trig
    clock = foldp plusReset 0 (fpsWhen 50 active)
               in (\t -> inMilliseconds t / inMilliseconds dt) <~ clock

-- Todo: go both ways (require input to be Signal Bool?)
{-| Fade between Colors over a Time when the input signal changes. -}
fadeColor : Color -> Color -> Time -> Signal a -> Signal Color
fadeColor c1 c2 dt trig = interpolateColor <~ constant c1 ~ constant c2 ~ fade dt trig

-- Todo: fade between rects and circles

-- Testing code
bg (w,h) clr = collage w h [rect (toFloat w) (toFloat h) |> filled clr]
main = bg <~ Window.dimensions ~ fadeColor blue red second (fps 0.5)



{-- Co-recursive version that causes runtime error
fade : Time -> Signal a -> Signal Float
fade dt trig = let
    plusReset t acc = if t == 0 then 0 else acc + t
    clock = foldp plusReset 0 (fpsWhen 30 active)
    start = sampleOn trig <| constant True
    end = ((>=) dt) <~ clock |> dropIf id False
    active = merge start end
               in (\t -> inMilliseconds t / inMilliseconds dt) <~ clock
--}

