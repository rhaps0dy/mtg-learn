module Components.Plots.PlotLine
  ( plotBuffer
  , moveLine
  ) where

import Native.PlotLine
import Task
import Color
import Components.Labels.Common as LC
import ParseFiles

plotBuffer : Color.Color -> String -> (Int, Int) -> Float ->
             ParseFiles.Buffer -> LC.XModel -> LC.YModel -> Task.Task String ()
plotBuffer = Native.PlotLine.plotBuffer

moveLine : String -> Float -> Int -> LC.XModel -> Task.Task String ()
moveLine = Native.PlotLine.moveLine