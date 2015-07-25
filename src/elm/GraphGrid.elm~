module GraphGrid (render) where

import Array
import Array exposing (Array)
import Graphics.Element as Element
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Debug

a3OffsetNames : Array String
a3OffsetNames = Array.fromList
    ["A", "Bb", "B", "C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab"]

a3OffsetToName : Int -> String
a3OffsetToName n =
  let
    (Just name) = Array.get (n%12) a3OffsetNames
    c4Offset = n - 3
    pitchIndex = (if c4Offset >= 0 then c4Offset else c4Offset - 11) // 12 + 4
  in
    toString pitchIndex ++ " " ++ name

noteRectangle : Float -> Int -> Html
noteRectangle h noteInd =
    div [ class <| "GraphGrid--rect GraphGrid--rect--" ++
              (if noteInd % 2 == 0 then "blue" else "white")
        , style [ ("height", toString h ++ "px") ] ]
        [ text <| a3OffsetToName noteInd ]

countDownList : Int -> Int -> List Int
countDownList highest lowest =
  if highest < lowest
    then []
    else highest :: countDownList (highest-1) lowest

render : Int -> Float -> Float -> Html
render windowHeight screenCenterA3Offset semitoneHeight =
  let
    -- We want the pitches to be centered on their rectangles, not at the bottom
    offsetForGrid = screenCenterA3Offset + 0.5
    nSemitonesHalfHeight = (toFloat windowHeight / 2) / semitoneHeight
    lowestNote = floor <| offsetForGrid - nSemitonesHalfHeight
    highestNote = floor <| offsetForGrid + nSemitonesHalfHeight
    margin = toFloat windowHeight / 2 - (toFloat highestNote + 1 - offsetForGrid) * semitoneHeight
    rectangles = List.map (noteRectangle semitoneHeight) (countDownList highestNote lowestNote)
  in
    div [ class "GraphGrid--container"
        , style [ ("top", toString margin ++ "px")
                ]
        ]
        rectangles