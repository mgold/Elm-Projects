module Align where

{-| Align Forms to horizontal or vertical lines.

# Horizontal
@docs alignTop, alignBottom, alignHoriz

# Vertical
@docs alignLeft, alignRight, alignVert
-}

{-| Align Forms with the uppermost Form. -}
alignTop : [Form] -> [Form]
alignTop frms = let top = maximum <| map .y frms
                in map (\frm -> {frm | y <- top}) frms

{-| Align Forms with the bottommost Form. -}
alignBottom : [Form] -> [Form]
alignBottom frms = let bot = minimum <| map .y frms
                in map (\frm -> {frm | y <- bot}) frms

{-| Align Forms with the leftmost Form. -}
alignLeft : [Form] -> [Form]
alignLeft frms = let left = minimum <| map .x frms
                in map (\frm -> {frm | x <- left}) frms

{-| Align Forms with the rightmost Form. -}
alignRight : [Form] -> [Form]
alignRight frms = let right = maximum <| map .x frms
                in map (\frm -> {frm | x <- right}) frms

{-| Align Forms horizontally, halfway between the uppermost and bottommost
 Forms. -}
alignHoriz : [Form] -> [Form]
alignHoriz frms = let top = maximum <| map .y frms
                      bot = minimum <| map .y frms
                      mid = (top + bot) / 2
                  in map (\frm -> {frm | y <- mid}) frms

{-| Align Forms vertically, halfway between the leftmost and rightmost Forms. -}
alignVert : [Form] -> [Form]
alignVert frms = let right = maximum <| map .x frms
                     left= minimum <| map .x frms
                     mid = (right + left) / 2
                 in map (\frm -> {frm | x <- mid}) frms

{-- } --Testing code

circles =
    [ circle 20 |> filled red |> move (230, 100)
    , circle 20 |> filled orange |> move (-200, -150)
    , circle 20 |> filled blue |> move (80, 180)
    , circle 20 |> filled green |> move (-80, -20)
    , circle 20 |> filled black
    ]

main = collage 600 600 <| [ group circles |> alpha 0.5 ] ++ alignHoriz circles
--}
