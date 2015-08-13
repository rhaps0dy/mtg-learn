module TaskUtils
  ( formsToDrawTask
  ) where

import Task
import Graphics.Collage exposing (Form)
import Native.TaskUtils
formsToDrawTask : String -> List Form -> Int -> Int -> a -> Task.Task String ()
formsToDrawTask = Native.TaskUtils.formsToDrawTask