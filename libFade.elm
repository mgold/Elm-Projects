module Fade where
import Window
import Either (Right)

data Ease = Linear | SineIn | SineOut | SineInOut

ease : Ease -> Float -> Float
ease ef x = case ef of
    Linear -> x
    SineIn -> sin ((x-1) * turns 0.25) + 1 -- start slow
    SineOut -> sin (x * turns 0.25) -- end slow
    SineInOut -> (sin ((2*x-1) * turns 0.25) + 1) / 2

{-| Interpolation `frac` distance between `a` and `b`, where `0 <= frac <= 1`.-}
-- In actuallity, numbers are Floats, still waiting on implicit coercion.
interpolate : Ease -> number -> number -> Float -> Float
interpolate ef a b frac = a + ease ef frac * (b - a)

{-| Interpolation on pairs of numbers. -}
interpolatePair : Ease -> Float -> (number,number) -> (number,number) -> (number, number)
interpolatePair ef frac (a,b) (a',b') = (interpolate ef a a' frac, interpolate ef b b' frac)

{-| Interpolation between colors. -}
interpolateColor : Color -> Color -> Float -> Color
interpolateColor (Color r1 g1 b1 a1) (Color r2 g2 b2 a2) frac = Color
    (truncate (interpolate Linear (toFloat r1) (toFloat r2) frac))
    (truncate (interpolate Linear (toFloat g1) (toFloat g2) frac))
    (truncate (interpolate Linear (toFloat b1) (toFloat b2) frac))
    (interpolate Linear a1 a2 frac)

{-| Interpolation between two shapes. -}
interpolateShape : Ease -> Form -> Form -> Float -> Form
interpolateShape ef a b frac = case (a.form,b.form) of
    (FShape (Right (Solid c1)) ps1, FShape (Right (Solid c2)) ps2) -> let
        c = interpolateColor c1 c2 frac
        ps = map (uncurry (interpolatePair ef frac)) (zip ps1 ps2)
        theta = interpolate ef a.theta b.theta frac
        scle = interpolate ef a.scale b.scale frac
        x = interpolate ef a.x b.x frac
        y = interpolate ef a.y b.y frac
        alph = interpolate ef a.alpha b.alpha frac
     in ps |> filled c |> rotate theta |> scale scle |> move (x,y) |> alpha alph
    _ -> (toForm . plainText) "Unsupported shape in interpolateShape"


{-| Count at a steady rate from 0 to 1 over the amount of time given each time
the input signal changes -}
fade : Time -> Signal a -> Signal Float
fade dt trig = let
    plusReset t acc = if t == 0 then 0 else acc + t
    active = dt `since` trig
    clock = foldp plusReset 0 (fpsWhen 50 active)
    finalOne = (\x -> if x then 0 else 1) <~ keepIf not True active
       in merge finalOne ((\t -> inMilliseconds t / inMilliseconds dt) <~ clock)

{-| Fade between Colors over a Time when the input signal changes. -}
fadeColor : Color -> Color -> Time -> Signal Bool -> Signal Color
fadeColor c1 c2 dt trig = let
    trues  = interpolateColor c1 c2 <~ fade dt (keepIf id True trig)
    falses = interpolateColor c2 c1 <~ fade dt (keepIf not False trig)
        in merge trues falses

{-| Fade between two shapes. The shapes must have the same number of vertices
(all circles and ovals have the same number). Currently, only filled shapes are
supported. No gradients, outlines, paths, groups, elements, etc. -}
fadeShape : Form -> Form -> Time -> Signal Bool -> Signal Form
fadeShape a b dt trig = let
    trues  = interpolateShape Linear a b <~ fade dt (keepIf id True trig)
    falses = interpolateShape Linear b a <~ fade dt (keepIf not False trig)
        in merge trues falses


-- Testing code
-- main = asText <~ fade (0.8*second) (fps 0.5)

{--
bg (w,h) clr = collage w h [rect (toFloat w) (toFloat h) |> filled clr]
main = let trues = (\_->True) <~ fps 0.5
           falses = (\_->False) <~ delay second trues
           trig = merge trues falses
       in bg <~ Window.dimensions ~ fadeColor blue red second trig
--}

{--}
main = let a = square 50 |> filled red |> move (-40, -20)
           b = rect 30 60 |> filled blue |> move (20, 10)
           b' = rect 30 60 |> outlined (solid blue) |> move (20, 10)
           trues = (\_->True) <~ fps 0.45
           falses = (\_->False) <~ delay second trues
           trig = merge trues falses
     in (\s -> collage 300 300 [s]) <~ fadeShape a b second trig
--}
