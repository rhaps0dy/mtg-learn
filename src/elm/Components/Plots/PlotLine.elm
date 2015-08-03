module PlotLine
  ( plotBuffer
  , formsToDrawTask
  ) where

import Native.PlotLine
import Task
import Color
import ParseFiles

plotBuffer : Color.Color -> String -> ParseFiles.Buffer -> Float -> Float
           -> Float -> Float -> Int -> Int -> Task.Task String ()
plotBuffer = Native.PlotLine.plotBuffer