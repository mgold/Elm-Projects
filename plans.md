Elm Plans
=========

A public place to write down my wholly personal thoughts on where Elm needs to
go ... eventually. This is not meant to be exhaustive.

Standard library
----------------

### Simple

- Generate lists of *max(n, 0)* random floats whenever a signal of Ints changes
  to *n*.
    - Proposal and implementation submitted to mailing list.

- Elementary math operations
    - `mean : [number] -> Float`  
      `mean xs = sum xs / length xs`

    - `dist : number -> number -> Float`  
      `dist a b = sqrt (a*a + b*b)`

    - Halving values is a suprisingly frequent operation when dealing with
      geometry, and until we get implicit Int->Float coercion, this is handy:  
      `half : Int -> Float`  
      `half x = toFloat x / 2`

- A function to save the previous value of a signal. Requires a default.

    - `previous : Signal a -> a -> Signal a`  
      `previous sig df = foldp (\x (y,_) -> (x,y)) (df, df) sig |> lift snd`

- Sorting lists. Needs to be a primitive. Can then define a convenience
  function:
    - `sortBy : (a -> comparable) -> [a] -> [a] -- type signature makes lifting
      easier`  
      `sortBy cmp xs = sort (map cmp xs)`

- Change the type signature of `sprite` so that it may be partially applied to
  the name of the sprite sheet, which could even be a signal to change level
  stylings.  
  - `sprite : Int -> Int -> (Int,Int) -> String -> Form -- current`  
    `sprite : String -> Int -> Int -> (Int,Int) -> Form -- proposed`  

- More `Color -> Color` operations, including greyscale (either a single
  parameter function to create a grey, or the greyscale version of a given
  color, both are useful), and color triads.

### Complicated

- Sound playback. How this can be handled in a pure way is an open topic for
  discussion. More generally, embedded multimedia.

- Type classes. While Haskell's implementation is good, it's also encumbered by
  all the category theory. While I have nothing against monads in Haskell, they
  don't belong in Elm. Elm could benefit from actual (making up
  newcomer-friendly names) `equatable`, `comparable`, `number` sequence. This
  would allow an implicit coersion between Int and Float. They could also help
  to eliminate some duplication of functions in `Dict` and `Set` from `List`,
  enter `foldable`, `lengthable`, and `mapable` (which Haskell calls Functor for
  some reason, he said with a hint of sarcasm). Finally, custom type classes
  could help simplify custom libraries

### Not theoretically impossible (probably)

- A function `lower : Signal a -> a` which returns the *default value* of its
  argument. As every signal has a default value, which is known when execution
  begins, this may be less unsafe than Haskell IO operations with a similar
  type. Use case is finding the screen dimensions more easily, under the
  assumption they don't change. Generalizes to any run-time constant.

Custom libraries
----------------

Evan is working on a package manager to distribute user libraries.

- Align and Distribute on Forms.
    - Align is mostly done. Still need to do distribute.

- A composable system for easing and fading shapes; doing collision detection,
  and similar graphic operations.

- A visualization color library, likely based on
  [ColorBrewer](http://colorbrewer2.org/).

- An extensible visualizations library. Rather than twidling knobs on an opaque
  framework, this would invite users to tweak the code to their liking, but also
  give them a starting place. Likely based on all of the above.

My Dream Elm IDE
----------------

- Code and program, side by side.

- Zero-keystroke save, compile, run: constant type checking, and when possible:

- Hotswapping. See effect of changes without restarting code, losing state, etc.

- Holes: IDE sugests value based on type inference.

- Documentation integration.

- Ability to see Signal graph update in realtime

- Ability to probe the value of any term in a function (e.g. let-bound values)

- Ability to hand-modify the current value of a signal, producing a new event on
  it

- Ability to lock a signal to not produce any outputs

- Ability to set breakpoints (unconditional or conditional) by signal change
  (not line execution)

- Bret Victor-style numeric scrubbers. (Bret Victor-style *everything*.)

- Performance profiling?

- `vim` keybindings.
