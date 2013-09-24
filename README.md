Elm Projects
============
Max Goldstein

A collection of cool things I made in [Elm](http://elm-lang.org/). Elm is a
language for Functional Reactive Programming (FRP) that compiles down to
JavaScript, and runs in the browser.

This repo includes both standalone projects and reuseable library code.

## Gyrations
A non-interactive screensaver, featuring rotating orbs of changing color.

## Grid
An infinite black and white grid. Well-commented and invites modification.
Controls:  
`t` - Toggle mode (default)  
`b` - Black mode  
`w` - White mode  
`c` - Clear (resets to Toggle mode)  

## Sploosh
A colorful sploosh ball that you create with your mouse.

## Spinner
Paint in a rotating coordinate system. I'm working on adding options for brush
size and color.

## LibPolar
A library of polar functions, submitted for community improvement and adoption.
The alternate implementation of `movePolar` is especially promising for
inclusion in the standard libraries.

## LibAlign
A library for aligning `Form`s along their centerpoints.

## LibFollow
A single function that fell out of the reset functionality for Grid. Creates a
Signal where events that match a predicate are followed by another event. This
allows the Clear event to propagate without leaving the user stuck in a
meaningless "Clear mode" by switching back to Toggle mode.
