module Components.Plots.PianoRoll
  ( plot
  ) where

import ParseFiles
import List
import Graphics.Collage as C
import Components.Labels.Common as LC
import Color
import TaskUtils
import Task

type alias Note =
  { start : Float
  , duration : Float
  , pitch : Float
  }

processRoll' : Float -> ParseFiles.Sheet -> List Note
processRoll' currentBeat notes =
  case notes of
    [] -> []
    (x::xs) ->
      case x.pitch of
        Nothing -> processRoll' (currentBeat + x.duration) xs
        (Just p) -> { start = currentBeat
                    , duration = x.duration
                    , pitch = toFloat p
                    } :: processRoll' (currentBeat + x.duration) xs


-- This can be factored out of the drawing but there is much lower-hanging
-- optimization fruit
processRoll : ParseFiles.Sheet -> List Note
processRoll = processRoll' 0


plot : Color.Color -> String -> (Int, Int) -> ParseFiles.Sheet ->
       LC.Model -> Task.Task String ()
plot color id (width, height) sheet {centerX, unitWidthX, centerY, unitWidthY} =
  let
    renderNote {start, duration, pitch} =
      C.rect (duration*unitWidthX) unitWidthY
       |> C.filled color
       |> C.move ((centerX + start + duration/2) * unitWidthX
                 , toFloat height - (pitch + centerY) * unitWidthY)
    notes = List.map renderNote (processRoll sheet)
  in 
    TaskUtils.formsToDrawTask id notes width height
      (centerX, unitWidthX, centerY, unitWidthY, sheet)