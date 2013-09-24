-- Bitmap Draw by Max Goldstein

-- Change the cursor mode with the keyboard:
-- t Toggle (default)
-- b Black
-- w White
-- c Clear (automatically resets to Toggle afterwards)

import Mouse
import Keyboard
import Char
import Window
import Dict (Dict, empty, toList, insert, remove, findWithDefault)

-- MODEL

-- Pixels are locations, Bits are the values stored there
type Pixel = (Int, Int)
data Bit = White | Black

toggle : Bit -> Bit
toggle bit = case bit of
             Black -> White
             White -> Black

-- An update requires both the mouse location and the editing mode
data Mode = Toggle | Write Bit | Clear
type Update = (Pixel, Mode)

-- We use a rather unconventional representation of a grid: a dict.
-- Therefore we do not care about the dimensions of the grid.
type Grid = Dict Pixel Bit

-- Instead, we hard-code the side length of a pixel. We make it a signal
-- so that it's easier to modify to accept user input, e.g. from a slider.
-- In this version, the side length is fixed. The user can get more grid space
-- simply by enlarging the browser window.
sidelen : Signal Int
sidelen = constant 32

-- But to show that it's dynamic, try something really crazy!
-- sidelen = truncate . (\x -> 16*(x+1.5)) . sin . inSeconds <~ foldp (+) 0 (fps 30)

-- These functions convert between screen pixels and our drawing's pixels.
pixelize : (Int,Int) -> Int -> Pixel
pixelize   (x,y) s = (div x s, div y s)

depixelize : Pixel -> Int -> (Float,Float)
depixelize (i,j) s = (toFloat (s*i), toFloat (s* -j))

-- UPDATE

-- Filter and transform the mouse position to a signal of pixels.
pixel : Signal Pixel
pixel = pixelize <~ Mouse.position ~ sidelen
         |> dropRepeats
         |> keepWhen Mouse.isDown (0,0)

-- Simple helper function
isPressed : Char -> Signal Bool
isPressed letter = Keyboard.isDown (Char.toCode letter)

-- Not-so-simple helper function
-- Takes a signal and two possible values. In the resulting signal, the first
-- will always be immediately followed by the second.
follow : a -> a -> Signal a -> Signal a
follow leader follower sig = let
    leadersig = keepIf ((==) leader) leader sig
    followsig = delay millisecond (sampleOn leadersig (constant follower))
  in merge followsig sig

-- Keep track of the editing mode from keypresses
mode : Signal Mode
mode = let
    keystrokes : Signal (Maybe Mode)
    keystrokes = let
        helper : Bool->Bool->Bool->Bool -> Maybe Mode
        helper t b w c =
           if | t -> Just Toggle
              | b -> Just (Write Black)
              | w -> Just (Write White)
              | c -> Just Clear
              | otherwise -> Nothing
      in helper <~ isPressed 'T' ~ isPressed 'B' ~ isPressed 'W' ~ isPressed 'C'
  in keepIf isJust (Just Toggle) keystrokes
     |> lift (\(Just a) -> a)
     |> follow Clear Toggle

-- Combine pixel and mode into update, but only on mousemove or clear
update : Signal Update
update = let
    toUnit _ = ()
    enable = merge (toUnit <~ pixel) (toUnit <~ keepIf ((==) Clear) Toggle mode)
  in (,) <~ pixel ~ sampleOn enable mode

-- This is the cool part: a signal of grid dictionaries! Using the mode it
-- determines how to modify the old grid - or discard it entirely.
grid : Signal Grid
grid = let stepFun : Update -> Grid -> Grid
           stepFun (k,m) d = case m of
               Toggle -> insert k (toggle (findWithDefault White k d)) d
               Write pix -> insert k pix d
               Clear -> empty
      in foldp stepFun empty update

-- DISPLAY
-- Draws a single pixel of a given side length
displayPixel : Int -> (Pixel, Bit) -> Form
displayPixel s ((i,j), b) =
  let offset = depixelize (i,j) s
      fillcolor = if b == Black then black else white
  in square (toFloat s) |> filled fillcolor |> move offset

-- main, concealing scene
main : Signal Element
main = let scene : (Int,Int) -> Int -> Grid  -> Element
           scene (w,h) s d =
              let partial = displayPixel s
                  half n = toFloat n / 2
              in collage w h [ group (map partial (toList d))
                                 |> move (half (s-w), half (h-s)) ]
       in scene <~ Window.dimensions ~ sidelen ~ grid

