module Components.YLabels.Pitch
  ( Model
  , init
  , Action
  , update
  , view
  , viewNoNums
  ) where

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
  | MouseUp

update : Action -> Model -> Model
update action model =
  case action of
    MouseDown (mb, pos) ->
      { model | mouseDown <- Just mb
              , mousePosMD <- pos
              , semitoneHeightMD <- model.semitoneHeight
              , centerA3OffsetMD <- model.centerA3Offset
              }
    MouseUp ->
      { model | mouseDown <- Nothing }
    MouseMove (_, y) ->
      if model.mouseDown == Nothing || model.mouseDown == Just Middle then
        model
      else
        if model.mouseDown == Just Left then
          -- compiler got stuck here on an infinite loop when <- was =
          { model | centerA3Offset <- model.centerA3OffsetMD +
                      toFloat (y - snd model.mousePosMD) / model.semitoneHeight }
        else
          { model | semitoneHeight <- model.semitoneHeightMD +
                      toFloat (y - snd model.mousePosMD) / 10 }
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

type alias NoteRectangleFun =
  Float -> Float -> Float -> Int -> Form

noteRectangle' : Bool -> NoteRectangleFun
noteRectangle' showNames width height margin a3Offset =
  let
    (c1, c2) = a3OffsetToColors a3Offset
    rectangle = rect width height
                 |> filled c1
    text' = Text.fromString (a3OffsetToName a3Offset)
             |> Text.height (min (height - 2) 14)
             |> Text.color c2
             |> text
  in
    (if showNames then group [rectangle, text'] else rectangle)
     |> moveY (margin + height * toFloat a3Offset)


type alias ViewFun =
  Signal.Address Action -> Model -> Float -> Float -> Html.Html

view' : NoteRectangleFun -> ViewFun
view' noteRectangle address {centerA3Offset, semitoneHeight} width height =
  let
    -- We want the pitches to be centered on their rectangles, not at the bottom
    offsetForGrid = centerA3Offset + 0.5
    nSemitonesHalfHeight = (height / 2) / semitoneHeight
    lowestNote = floor <| offsetForGrid - nSemitonesHalfHeight
    highestNote = floor <| offsetForGrid + nSemitonesHalfHeight
    margin = -centerA3Offset * semitoneHeight
    rectangles = List.map (noteRectangle width semitoneHeight margin)
                  [lowestNote..highestNote]
  in
    Html.div
     [ Html.style <| whStyle width height
     , onMouseMove address MouseMove
     , onMouseDown address MouseDown
     , onMouseUp address (\_ -> MouseUp)
     , Html.onMouseOut address MouseUp
     ]
     [ Html.fromElement <| collage (round width) (round height) rectangles ]

view : ViewFun
view = view' (noteRectangle' True)

dummy : Signal.Mailbox Action
dummy = Signal.mailbox NoOp

viewNoNums : Model -> Float -> Float -> Html.Html
viewNoNums = view' (noteRectangle' False) dummy.address