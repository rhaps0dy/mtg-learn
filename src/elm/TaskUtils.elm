module TaskUtils (combine) where

import Task

combine : List (Task.Task a ()) -> Task.Task a ()
combine taskList =
  case taskList of
    [] ->
      Task.succeed ()
    (x::xs) ->
      List.foldr (\t t' -> Task.andThen t (\_ -> t')) x xs