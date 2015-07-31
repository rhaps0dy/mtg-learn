module PlotLine
  ( plotBuffer
  ) where

import Native.PlotLine
import Task
import Color
import ParseFiles

plotBuffer : Color.Color -> String -> ParseFiles.Buffer
           -> Float -> Float -> Float -> Float -> Int -> Int -> Task.Task x ()
plotBuffer = Native.PlotLine.plotBuffer