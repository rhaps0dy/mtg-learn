module Components.Plots.PlotLine
  ( plotBuffer
  ) where

import Native.PlotLine
import Task
import Color
import Components.Labels.Common as LC
import ParseFiles

plotBuffer : Color.Color -> String -> (Int, Int) -> ParseFiles.Buffer ->
             LC.Model -> Task.Task String ()
plotBuffer = Native.PlotLine.plotBuffer