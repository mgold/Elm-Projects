-- follow by Max Goldstein

-- A candidate for a library function.

-- Takes a predicate, a follower value, and a signal. In the output signal, any
-- values that meet the predicate will be followed immediately by the follower.
-- The follower will be the first value of the signal. Use this to turn modes
-- into events by changing back to an actual mode after an event mode.

follow : (a -> Bool) -> a -> Signal a -> Signal a
follow pred follower sig = let
    leadersig = keepIf pred follower sig
    followsig = delay millisecond (sampleOn leadersig (constant follower))
  in merge followsig sig
