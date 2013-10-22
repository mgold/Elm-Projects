-- Spinner by Max Goldstein

import Mouse
import Window
import Dict (Dict, empty, toList, insert, findWithDefault)
import Automaton (Automaton, state, run)
import Graphics.Input (button)

-- MODEL

-- indicates the function expects to be lifted with Window.dimensions
type WH = (Int,Int)
-- used only for x,y position within window
type XY = (Int,Int)
-- r,theta polar coordinates
type RT = (Float, Float)

data Update = Click Form | Reset | Tick

radius : WH -> Int
radius dims = uncurry min dims `div` 2

clock : Signal Time
clock = foldp (+) 0 (fps 50)

angle : Signal Float
angle = let k = 1.2 -- rotation speed constant
        in (\x -> inSeconds x*k) <~ clock

-- Part of the Polar Library
mousePolar : Signal RT
mousePolar = let
    half n = toFloat n / 2
    center (w,h) (x,y) = (half w - toFloat x, half h - toFloat y)
    centered = center <~ Window.dimensions ~ Mouse.position
  in (\(r,t) -> (r,pi-t)) . toPolar <~ centered

movePolar : (Float, Float) -> Form -> Form
movePolar (r, theta) = move <| fromPolar (r, theta)

-- UPDATE

onSpinner : Signal Bool
onSpinner = (\dims (r,t) -> r < (toFloat . radius) dims)
              <~ Window.dimensions ~ mousePolar

input : Signal RT
input = (\(r,t) a -> (r,t-a)) <~ mousePolar ~ angle
          |> keepWhen Mouse.isDown (9000,0)
          |> keepWhen onSpinner (9000,0)

-- Project: make these user-controllable
selColor = constant white
selRadius = constant 4.1

-- (resetButton, resetSignal) : (Element, Signal ())
(resetButton, resetSignal) = button "Reset"

update : Signal Update
update = let drawPaint : RT -> Color -> Float -> Form
             drawPaint rt c rad = circle rad |> filled c |> movePolar rt
             painted = drawPaint <~ input ~ selColor ~ selRadius
             click = (\form -> Click form) <~ painted
             resetCmd = sampleOn resetSignal (constant Reset)
             tick = sampleOn (fps 20) (constant Tick)
  in merges [click, resetCmd, tick]

drawing : Signal [Form]
drawing = let
    fade : Form -> Form          -- fade rate constant
    fade form = alpha (form.alpha - 0.005) form
    prune : [Form] -> [Form]                 -- min alpha constant
    prune forms = filter (\form -> form.alpha > 0.02) forms
    step : Update -> [Form] -> [Form]
    step upd ps = case upd of
      Reset -> []
      Click form -> form :: ps
      Tick -> map fade ps |> prune
  in foldp step [] update

-- DISPLAY

scene : WH -> Float -> [Form] -> Element
scene (w,h) ang ps = let
        r = radius (w,h)
        sgrey = (solid grey) --hack around language oddity
  in collage w h <| [ circle (toFloat r)
                      |> filled black
                   , circle (toFloat r-5)
                      |> outlined {sgrey | width <- 10, dashing <- [80,80] }
                      |> rotate ang
                   , circle 2
                      |> filled grey
                   ] ++  [group ps |> rotate ang]

main = layers <~ combine
                 [scene <~ Window.dimensions
                         ~ angle
                         ~ drawing
                 , constant resetButton
                 ]
