module Components.Plots.PlotLine
  ( plotBuffer
  , moveLine
  ) where

import Native.PlotLine
import Task
import Components.Colors as C
import Components.Labels.Common as LC
import ParseFiles
import Signal

-- so the native file can use Constants
import Constants

plotBuffer : C.HtmlColor -> String -> (Int, Int) -> Float -> Int ->
             ParseFiles.Buffer -> LC.XModel -> LC.YModel -> Task.Task String ()
plotBuffer = Native.PlotLine.plotBuffer

moveLine : String -> Int -> Float -> Int -> Int -> LC.XModel -> Bool
             -> Signal.Address Float -> Task.Task String ()
moveLine = Native.PlotLine.moveLine
