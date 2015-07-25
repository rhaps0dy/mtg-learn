module Components.YLabels.Pitch (Model, init, Action, update, view) where

{- Component that shows the pitch label -}

import Graphics.Collage exposing (..)
import Color exposing (..)
import Array
import Text
import Signal
import Html
import Html.Attributes as Html
import Html.Events as Html
import HtmlEvents exposing (..)
import Components.Misc exposing (whStyle)
import Debug


type alias Model =
  { centerA3Offset : Float
  , semitoneHeight : Float
  , mouseDown : Maybe MouseButton
  , mousePosMD : (Int, Int)
  , semitoneHeightMD : Float
  , centerA3OffsetMD : Float
  }


init : Model
init =
  { centerA3Offset = 0
  , semitoneHeight = 10
  , mouseDown = Nothing
  , mousePosMD = (0, 0)
  , semitoneHeightMD = 0
  , centerA3OffsetMD = 0
  }


type Action
  = NoOp
  | MouseMove (Int, Int)
  | MouseDown (MouseButton, (Int, Int))
  | MouseUp (MouseButton, (Int, Int))

update : Action -> Model -> Model
update action model =
  case (Debug.log "action" action) of
    MouseDown (mb, pos) ->
      { model | mouseDown <- Just mb
              , mousePosMD <- pos
              , semitoneHeightMD <- model.semitoneHeight
              , centerA3OffsetMD <- model.centerA3Offset
              }
    MouseUp _ ->
      { model | mouseDown <- Nothing }
    MouseMove (_, y) ->
      if model.mouseDown == Nothing || model.mouseDown == Just Middle then
        model
      else
        { model | centerA3Offset = model.centerA3OffsetMD + y - snd model.mousePosMD }
    _ -> model


a3OffsetNames : Array.Array String
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


countDownList : Int -> Int -> List Int
countDownList highest lowest =
  if highest < lowest
    then []
    else highest :: countDownList (highest-1) lowest


a3OffsetColors : Array.Array Color
a3OffsetColors =
  Array.fromList [ white, black, white, white, black, white, black, white
                 , white, black, white, black]


a3OffsetToColors : Int -> (Color, Color)
a3OffsetToColors i =
  let
    (Just c) = Array.get (i%12) a3OffsetColors
  in
    (c, if c == white then black else white)


noteRectangle : Float -> Float -> Float -> Int -> Form
noteRectangle width height margin a3Offset =
  let
    (c1, c2) = a3OffsetToColors a3Offset
    rectangle = rect width height
                 |> filled c1
    text' = Text.fromString (a3OffsetToName a3Offset)
             |> Text.height (height - 2)
             |> Text.color c2
             |> text
             |> moveX 10
  in
    group [rectangle, text']
     |> moveY (margin + height * toFloat a3Offset)


view : Signal.Address Action -> Model -> Float -> Float -> Html.Html
view address {centerA3Offset, semitoneHeight} width height =
  let
    -- We want the pitches to be centered on their rectangles, not at the bottom
    offsetForGrid = centerA3Offset + 0.5
    nSemitonesHalfHeight = (height / 2) / semitoneHeight
    lowestNote = floor <| offsetForGrid - nSemitonesHalfHeight
    highestNote = floor <| offsetForGrid + nSemitonesHalfHeight
    margin =
      height / 2 - (toFloat highestNote + 1 - offsetForGrid) * semitoneHeight
    rectangles = List.map (noteRectangle width semitoneHeight margin)
                  [lowestNote..highestNote]
  in
    Html.div
     [ Html.style <| whStyle width height
     , onMouseMove address MouseMove
     , onMouseDown address MouseDown
     , onMouseUp address MouseUp
     , disableContextMenu
     ]
     [ Html.fromElement <| collage (round width) (round height) rectangles ]
