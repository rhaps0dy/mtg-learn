module Components.Plots.PianoRoll
  ( plot
  ) where

import Components.NumLabel exposing (PlotFun)
import ParseFiles as PF
import List
import Graphics.Collage exposing (..)
import Color exposing (..)

type alias Note =
  { start : Float
  , duration : Float
  , pitch : Float
  }

processRoll' : Float -> PF.Sheet -> List Note
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


-- | Maybe in the future we can do binary search on this array to maybe speed
--   drawing up. Now it's a list.
-- Another way of speeding it up, likely to be much more fruitful, would be to
--   make plot a Signal of function, and precalculate as much as possible,
--   including the list of forms. This remains TODO for a future refactoring
processRoll : PF.Sheet -> List Note
processRoll = processRoll' 0


plot : PF.Sheet -> PlotFun
plot sheet centerX unitWidthX centerY unitWidthY _ _ =
  let
    renderNote {start, duration, pitch} =
      rect (duration*unitWidthX) unitWidthY
       |> filled red
       |> move ((centerX + start + duration/2) * unitWidthX, (pitch + centerY) * unitWidthY)
  in 
    List.map renderNote (processRoll sheet)