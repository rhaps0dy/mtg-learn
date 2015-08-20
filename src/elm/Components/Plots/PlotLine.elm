module Components.Plots.PlotLine
  ( plotBuffer
  , moveLine
  ) where

import Native.PlotLine
import Task
import Color
import Components.Labels.Common as LC
import ParseFiles
import Signal

-- so the native file can use Constants
import Constants

plotBuffer : Color.Color -> String -> (Int, Int) -> Float ->
             ParseFiles.Buffer -> LC.XModel -> LC.YModel -> Task.Task String ()
plotBuffer = Native.PlotLine.plotBuffer

moveLine : String -> Int -> Float -> Int -> LC.XModel -> Bool
             -> Signal.Address Float -> Task.Task String ()
moveLine = Native.PlotLine.moveLine
