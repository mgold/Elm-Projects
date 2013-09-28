module Fade where
import Window
import Mouse
import Either (Right)

data Ease = Linear | SineIn | SineOut | SineInOut

easeFun : Ease -> Float -> Float
easeFun ef x = case ef of
    Linear -> x
    SineIn -> sin ((x-1) * turns 0.25) + 1 -- start slow
    SineOut -> sin (x * turns 0.25) -- end slow
    SineInOut -> (sin ((2*x-1) * turns 0.25) + 1) / 2

{-| Ease `frac` distance between `a` and `b`, where `0 <= frac <= 1`.-}
-- In actuallity, numbers are Floats, still waiting on implicit coercion.
ease : Ease -> number -> number -> Float -> Float
ease ef a b frac = a + easeFun ef frac * (b - a)

{-| Easing on pairs of numbers. -}
easePair : Ease -> Float -> (number,number) -> (number,number) -> (number, number)
easePair ef frac (a,b) (a',b') = (ease ef a a' frac, ease ef b b' frac)

{-| Easing between colors. Easing occurs in the RGB color space. -}
easeColor : Ease -> Color -> Color -> Float -> Color
easeColor ef (Color r1 g1 b1 a1) (Color r2 g2 b2 a2) frac = Color
    (truncate (ease ef (toFloat r1) (toFloat r2) frac))
    (truncate (ease ef (toFloat g1) (toFloat g2) frac))
    (truncate (ease ef (toFloat b1) (toFloat b2) frac))
    (ease ef a1 a2 frac)

{-| Easing between two shapes. The shapes must have the same number of vertices
(all circles and ovals have the same number). Currently, only filled shapes are
supported. No gradients, outlines, paths, groups, elements, etc. -}
easeShape : Ease -> Form -> Form -> Float -> Form
easeShape ef a b frac = case (a.form,b.form) of
    (FShape (Right (Solid c1)) ps1, FShape (Right (Solid c2)) ps2) -> let
        c = easeColor ef c1 c2 frac
        ps = map (uncurry (easePair ef frac)) (zip ps1 ps2)
        theta = ease ef a.theta b.theta frac
        scle = ease ef a.scale b.scale frac
        x = ease ef a.x b.x frac
        y = ease ef a.y b.y frac
        alph = ease ef a.alpha b.alpha frac
     in ps |> filled c |> rotate theta |> scale scle |> move (x,y) |> alpha alph
    _ -> (toForm . plainText) "Unsupported shape in easeShape"

{-| Count at a steady rate from 0 to 1 over the amount of time given each time
the input signal changes -}
fade : Time -> Signal a -> Signal Float
fade dt trig = let
    plusReset t acc = if t == 0 then 0 else t + acc
    active = dt `since` trig
    clock = foldp plusReset 0 (fpsWhen 30 active)
    time t = inMilliseconds t / inMilliseconds dt
    finalOne = (\x -> if x then 0 else 1) <~ keepIf not True active
       in merge finalOne (lift time clock |> dropIf ((<) 1) 0)

{-| Each time the input signal changes, count either from either 0 to 1 or 1 to
0 over the amount of time given. Counting starts at 0 and then switches each
time. -}
fadeCycle : Time -> Signal a -> Signal Float
fadeCycle dt trig = let
    fracs = fade dt trig
    prev = foldp (\x (y,_) -> (x,y)) (0,0) fracs |> lift snd
    invert = foldp (\b s -> if b then not s else s) False (lift2 (<) fracs prev)
    f = (\i frc -> if i then 1-frc else frc) <~ invert
        in merge (constant 0) (sampleOn f (f ~ fracs))

{-| Fade between Colors over a Time when the input signal changes. -}
fadeColor : Ease -> Color -> Color -> Time -> Signal Bool -> Signal Color
fadeColor ef c1 c2 dt trig = easeColor ef c1 c2 <~ fadeCycle dt trig

{-| Fade between two shapes. The two shapes must support easing (see
`easeShape`). -}
fadeShape : Ease -> Form -> Form -> Time -> Signal a -> Signal Form
fadeShape ef a b dt trig = easeShape ef a b <~ fadeCycle dt trig

-- Testing code
-- main = asText <~ fade (0.8*second) (fps 0.5)

{--
bg (w,h) clr = collage w h [rect (toFloat w) (toFloat h) |> filled clr]
main = let trues = (\_->True) <~ fps 0.5
           falses = (\_->False) <~ delay second trues
           trig = merge trues falses
       in bg <~ Window.dimensions ~ fadeColor blue red second trig
--}

main = let a = square 50 |> filled red |> move (-300, -20)
           b = rect 30 60 |> filled blue |> move (300, 10)
           b' = rect 30 60 |> outlined (solid blue) |> move (20, 10)
           dt = 2*second
           trig = Mouse.clicks
       in (\s -> collage 800 300 [ traced (solid black) [(-325, 5),
                                                         (-325, -45),
                                                         (-275, -45)]
                                 , traced (solid black) [(285, 40),
                                                         (315, 40),
                                                         (315, -20)]
                                , s])
       <~ fadeShape SineInOut a b dt trig

