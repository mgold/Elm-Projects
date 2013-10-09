module Align where
{-| Align forms to the horizontal or vertical lines of their bounding box.

Function names are chosen with the expectation that this module will imported
qualified, e.g. `Align.top`.

# Horizontal
@docs top, bottom, horiz

# Vertical
@docs left, right, vert
-}

{-| Align forms with the uppermost form. -}
top : [Form] -> [Form]
top frms = let t = maximum <| map .y frms
           in map (\frm -> {frm | y <- t}) frms

{-| Align forms with the bottommost form. -}
bottom : [Form] -> [Form]
bottom frms = let bot = minimum <| map .y frms
              in map (\frm -> {frm | y <- bot}) frms

{-| Align forms with the leftmost form. -}
left : [Form] -> [Form]
left frms = let lft = minimum <| map .x frms
            in map (\frm -> {frm | x <- lft}) frms

{-| Align forms with the rightmost form. -}
right : [Form] -> [Form]
right frms = let rgt = maximum <| map .x frms
            in map (\frm -> {frm | x <- rgt}) frms

{-| Align forms horizontally, halfway between the uppermost and bottommost
 forms. -}
horiz : [Form] -> [Form]
horiz frms = let t = maximum <| map .y frms
                 bot = minimum <| map .y frms
                 mid = (t + bot) / 2
             in map (\frm -> {frm | y <- mid}) frms

{-| Align forms vertically, halfway between the leftmost and rightmost Forms. -}
vert : [Form] -> [Form]
vert frms = let rgt = maximum <| map .x frms
                lft= minimum <| map .x frms
                mid = (rgt + lft) / 2
            in map (\frm -> {frm | x <- mid}) frms

{-- } --Testing code

circles =
    [ circle 20 |> filled red |> move (230, 100)
    , circle 20 |> filled orange |> move (-200, -150)
    , circle 20 |> filled blue |> move (80, 180)
    , circle 20 |> filled green |> move (-80, -20)
    , circle 20 |> filled black
    ]

main = collage 600 600 <| [ group circles |> alpha 0.5 ] ++ horiz circles
--}
