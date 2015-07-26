module Components.XLabel (Model, init, Action, update, view) where

{- This component shows the time scale in the x axis
   TODO: Refactor to reuse the duplicated code from all those other components
-}

import Html
import Html.Attributes as Html
import Html.Events as Html
import Graphics.Collage exposing (..)
import Color exposing (..)
import Array exposing (Array)
import Signal
import Text

import HtmlEvents exposing (..)
import Components.Misc exposing (whStyle)

type alias Model =
  { center : Float
  , unitWidth : Float
  , mouseDown : Maybe MouseButton
  , mousePosMD : (Int, Int)
  , centerMD : Float
  , unitWidthMD : Float
  }

init : Model
init =
  { center = -7
  , unitWidth = 20
  , mouseDown = Nothing
  , mousePosMD = (0, 0)
  , centerMD = 0
  , unitWidthMD = 20
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
              , centerMD <- model.center
              , unitWidthMD <- model.unitWidth
              }
    MouseUp ->
      { model | mouseDown <- Nothing }
    MouseMove (x, _) ->
      if model.mouseDown == Nothing || model.mouseDown == Just Middle then
        model
      else
        if model.mouseDown == Just Left then
          { model | center <- model.centerMD +
                      toFloat (x - fst model.mousePosMD) / model.unitWidth }
        else
          { model | unitWidth <- model.unitWidthMD +
                      toFloat (x - fst model.mousePosMD) / 10 }
    _ -> model

labelHeight : Int
labelHeight = 25

topMostPosition : Float
topMostPosition = toFloat labelHeight / 2

lineLength : Float
lineLength = 7

vline : Int -> Form
vline num =
  let
    line =
      segment (0, topMostPosition) (0, topMostPosition - lineLength)
       |> traced { defaultLine | color <- white }
    text' =
      Text.fromString (toString num)
       |> Text.height (min (14 - 2) 14)
       |> Text.color white
       |> text
  in
    group [line, text']
   

view : Signal.Address Action -> Model -> (Int, Int) -> Html.Html
view address model (width', height') =
  let
    width = toFloat width'
    height = toFloat height'
    r = rect width height
         |> filled black
    nLinesHalfWidth = (width / 2) / model.unitWidth
    firstLine = floor <| -model.center - nLinesHalfWidth
    lastLine = ceiling <| -model.center + nLinesHalfWidth
    lines = List.map
             (\x -> vline x
                     |> moveX ((model.center + toFloat x) * model.unitWidth))
             [firstLine..lastLine]
  in
    Html.div
     [ Html.style <| whStyle width height
     , Html.class "main-canvases"
     ]
     [ Html.div
        [ Html.style <| whStyle width' labelHeight ++
            [("margin-top", toString (height' - labelHeight) ++ "px")]
        , onMouseMove address MouseMove
        , onMouseDown address MouseDown
        , onMouseUp address (\_ -> MouseUp)
        , Html.onMouseOut address MouseUp
        ]
        [ Html.fromElement <| collage (round width) labelHeight (r::lines) ]
     ]