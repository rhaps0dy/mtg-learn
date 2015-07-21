module GraphPitch where

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Lazy exposing (..)
import Html exposing (Html)
import Debug

twelvethRootTwo : Float
twelvethRootTwo = 1.05946309435930

freqToA3Offset : Float -> Float
freqToA3Offset f = logBase twelvethRootTwo (f/440)

(:=) : (String -> a) -> Float -> a
(:=) f x = f (toString x)


a3OffsetToHeight : Int -> Float -> Float -> Float -> Float
a3OffsetToHeight h screenCenterA3Offset semitoneHeight o = (toFloat h) / 2 - (o - screenCenterA3Offset) * semitoneHeight

pitchPlot : (Int, Int) -> Float -> Float -> Float -> Float -> List Float -> Svg
pitchPlot (w, h) lineX screenCenterA3Offset semitoneHeight sampleWidth freqs =
  let
    freqToHeight = a3OffsetToHeight h screenCenterA3Offset semitoneHeight << freqToA3Offset
    indexToX i = lineX - (toFloat i) * sampleWidth
    buildLine i f1 f2 = line [ stroke "red"
                             , strokeWidth "2"
                             , x1 := indexToX i
                             , x2 := indexToX (i+1)
                             , y1 := freqToHeight f1
                             , y2 := freqToHeight f2
                             ] [ ]
    lines n freq1 freq2 =
      if lineX - (toFloat n * sampleWidth) < 0 then
          []
      else
        case (freq1, freq2) of
          (x::xs, y::ys) ->
            buildLine n x y :: lines (n+1) xs ys
          _ ->
            []
    freqs' = List.drop 1 freqs
    plot = lines 0 freqs freqs'
  in
    g [ ] plot


render : (Int, Int) -> Float -> Float -> Float -> Float -> List Float -> Html
render (w, h) startLinePosRel screenCenterA3Offset semitoneHeight sampleWidth freqs =
  let
    lineX = toFloat w * startLinePosRel
    lineXStr = toString (round lineX)
  in
    svg
      [ class "fullscreen"
      ]
      [ line [ fill "none"
            , stroke "blue"
            , strokeWidth "2"
            , x1 lineXStr
            , x2 lineXStr
            , y1 "0"
            , y2 (toString h) ] [ ]
      , pitchPlot (w, h) lineX screenCenterA3Offset semitoneHeight sampleWidth freqs
      ]


