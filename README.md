Elm Projects
============
Max Goldstein

A collection of cool things I made in [Elm](http://elm-lang.org/). Elm is a
language for Functional Reactive Programming (FRP) that compiles down to
JavaScript, and runs in the browser.

This repo includes both standalone demonstrations / applets and reuseable
library code.

Also included is a subjective and non-exhaustive list of improvements I'd like
to see in Elm, `plans.md`. Some ideas have ready-to-go implementations; some
are pipe dreams.

## Standalone Programs
### Gyrations
A non-interactive screensaver, featuring rotating orbs of changing color.

### Grid
An infinite black and white grid. Well-commented and invites modification.
Controls:  
`t` - Toggle mode (default)  
`b` - Black mode  
`w` - White mode  
`c` - Clear (resets to Toggle mode)  

### Sploosh
A colorful sploosh ball that you create with your mouse.

### Spinner
Paint in a rotating coordinate system. I'm working on adding options for brush
size and color.

## Libraries

### Polar
A library of polar functions, submitted for community improvement and adoption.
The alternate implementation of `movePolar` is especially promising for
inclusion in the standard libraries.

### Align
A library for aligning `Form`s along their centerpoints. I'll do distribute one day...

### Follow
A single function that fell out of the reset functionality for Grid. Creates a
Signal where events that match a predicate are followed by another event. This
allows the Clear event to propagate without leaving the user stuck in a
meaningless "Clear mode" by switching back to Toggle mode.

### Fade
A library for morphing colors and shapes into other colors and shapes.
