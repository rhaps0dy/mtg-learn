module GraphPianoRoll where

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Lazy exposing (..)
import Html exposing (Html)

import GraphPitch exposing (a3OffsetToHeight)

type alias Note =
    { pitch : Maybe Int
    , duration : Float
    }

bpm : Float
bpm = 130 * 2

processRoll : Float -> List Note -> List (Float, Float, Int)
processRoll currentBeat notes =
  case notes of
    [] -> []
    (x::xs) ->
      case x.pitch of
        Nothing -> processRoll (currentBeat + x.duration) xs
        (Just p) -> (currentBeat, x.duration, p) :: processRoll (currentBeat + x.duration) xs
    

(:=) : (String -> a) -> Float -> a
(:=) f x = f (toString x)

render : (Int, Int) -> Float -> Float -> Float -> Float -> List Note -> Int -> Html
render (w, h) startLinePosRel screenCenterA3Offset semitoneHeight sampleWidth roll nsamples =
  let
    oty = (\n -> n - (semitoneHeight / 2))
        << a3OffsetToHeight h screenCenterA3Offset semitoneHeight
    beatWidth = sampleWidth * (44100 / 1024) * (60 / bpm)
    toRectangle (beatn, beatlen, offset) =
      rect [ fill "#2d2d2d"
           , stroke "none"
           , x := ( startLinePosRel * toFloat w
                  - toFloat nsamples * sampleWidth
                  + beatWidth * beatn )
           , y := oty (toFloat (offset - 24))
           , width := (beatWidth * beatlen)
           , height := semitoneHeight
           ] [ ]
  in
    svg [ class "fullscreen" ] <| List.map toRectangle (processRoll 0 roll)