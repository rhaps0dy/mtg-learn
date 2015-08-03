module TaskUtils
  ( sequence
  , formsToDrawTask
  ) where

import Task
import Graphics.Collage exposing (Form)
import Native.TaskUtils

{- sequence : List (Task.Task a ()) -> Task.Task a ()
sequence taskList =
  case taskList of
    [] ->
      Task.succeed ()
    (x::xs) ->
      List.foldr (\t t' -> Task.andThen t (\_ -> t')) x xs -}

sequence : List (Task.Task a ()) -> Task.Task a ()
sequence = Native.TaskUtils.combineTasks

formsToDrawTask : String -> List Form -> a -> Task.Task String ()
formsToDrawTask = Native.TaskUtils.formsToDrawTask