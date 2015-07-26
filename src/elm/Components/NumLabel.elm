module Components.NumLabel (Model, init, Action, update, view) where

{- This component shows a numeric scale in either the X or the Y axis
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
  { center = 0
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

update : ((Int, Int) -> Int) -> Action -> Model -> Model
update tfun action model =
  case action of
    MouseDown (mb, pos) ->
      { model | mouseDown <- Just mb
              , mousePosMD <- pos
              , centerMD <- model.center
              , unitWidthMD <- model.unitWidth
              }
    MouseUp ->
      { model | mouseDown <- Nothing }
    MouseMove pos ->
      if model.mouseDown == Nothing || model.mouseDown == Just Middle then
        model
      else
        if model.mouseDown == Just Left then
          { model | center <- model.centerMD +
                      toFloat (tfun pos - tfun model.mousePosMD)
                        / model.unitWidth }
        else
          { model | unitWidth <- model.unitWidthMD +
                      toFloat (tfun pos - tfun model.mousePosMD) / 10 }
    _ -> model

drawLine : Path -> Int -> Form
drawLine line num =
  let
    line' = traced { defaultLine | color <- white } line
    text' =
      Text.fromString (toString num)
       |> Text.height (min (14 - 2) 14)
       |> Text.color white
       |> text
  in
    group [line', text']
   
view : Path -> ((Float, Float) -> Float) -> (Float -> Form -> Form)
       -> List (String, String)
       -> Signal.Address Action -> Model -> (Int, Int) -> Html.Html
view line tfun move' style' address model (width', height') =
  let
    width = toFloat width'
    height = toFloat height'
    r = rect width height
         |> filled black
    nLinesHalfWidth = (tfun (width, height) / 2) / model.unitWidth
    firstLine = floor <| -model.center - nLinesHalfWidth
    lastLine = ceiling <| -model.center + nLinesHalfWidth
    lines = List.map
             (\x -> drawLine line x
                     |> move' ((model.center + toFloat x) * model.unitWidth))
             [firstLine..lastLine]
  in
    Html.div
     [ Html.style <| whStyle width' height' ++ style'
     , onMouseMove address MouseMove
     , onMouseDown address MouseDown
     , onMouseUp address (\_ -> MouseUp)
     , Html.onMouseOut address MouseUp
     ]
     [ Html.fromElement <| collage width' height' (r::lines) ]