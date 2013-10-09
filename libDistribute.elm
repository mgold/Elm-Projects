module Distribute where

{-| Distribute forms evenly within their bounding box, or on a circle.

Function names are chosen with the expectation that this module will imported
qualified, e.g. `Distribute.top`.

# Linear
@docs horiz, vert

# Radial
@docs radial, radialRot
-}

{-| Distribute forms horizontally. -}
horiz : [Form] -> [Form]
horiz frms = let n = length frms
             in if n < 2 then frms else let
                 left  = minimum <| map .x frms
                 right = maximum <| map .x frms
                 dx = (right - left) / toFloat (n-1)
                 zipped = zip frms [0..n-1]
             in map (\(frm, t) -> {frm|x <- left + dx * toFloat t}) zipped

{-| Distribute forms vertically. -}
vert : [Form] -> [Form]
vert frms = let n = length frms
            in if n < 2 then frms else let
                bot = minimum <| map .y frms
                top = maximum <| map .y frms
                dy = (top - bot) / toFloat (n-1)
                zipped = zip frms [0..n-1]
            in map (\(frm, t) -> {frm|y <- bot + dy * toFloat t}) zipped

{-| Distribute forms with even radial spacing around a centerpoint. -}
radial : (Float, Float) -> Float -> [Form] -> [Form]
radial (x,y) r frms = case frms of
    [] -> []
    _ -> let n = length frms
             dtheta = turns (1 / toFloat n)
             zipped = zip frms (map ((\s -> s*dtheta) . toFloat) [0..n-1])
         in map (\(frm, t) -> {frm|x <- x + r * cos t,
                                   y <- y + r * sin t}) zipped

{-| Distribute forms with even radial spacing around a centerpoint, and rotate
them. -}
radialRot : (Float, Float) -> Float -> [Form] -> [Form]
radialRot (x,y) r frms = case frms of
    [] -> []
    _ -> let n = length frms
             dtheta = turns (1 / toFloat n)
             zipped = zip frms (map ((\s -> s*dtheta) . toFloat) [0..n-1])
         in map (\(frm, t) -> {frm|x <- x + r * cos t,
                                   y <- y + r * sin t}
                              |> rotate t) zipped


-- Testing code / examples
{-- } -- Clockface numbers
hours = map (toForm . centered . toText . show) <| [3,2,1] ++ reverse [4..12]
main = collage 600 600 <| radial hours (0,0) 100
--}

{-- } -- Gear spinner

dots = let n = 12
           ds = map (\k -> (oval 8 3 |> filled black |> alpha (k/n)))
               (map toFloat [1..n])
           rot _ (x::xs) = xs ++ [x]
       in foldp rot ds (fps 10)

main = (\ds -> collage 60 60 <| radialRot (0,0) 15 ds) <~ dots
--}
