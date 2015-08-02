module TaskUtils (combineDiscard) where

import Task

combineDiscard : List (Task.Task a ()) -> Task.Task a ()
combineDiscard taskList =
  case taskList of
    [] ->
      Task.succeed ()
    (x::xs) ->
      List.foldr (\t t' -> Task.andThen t (\_ -> t')) x xs