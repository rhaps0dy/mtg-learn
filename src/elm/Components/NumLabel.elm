module Components.NumLabel
  ( Model
  , init
  , Action
  , update
  , viewOneDim
  , view
  , ViewType
  ) where

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

type alias ViewType =
  Signal.Address Action -> Model -> (Int, Int) -> Html.Html

lines : Float -> Float -> Float -> (Float -> Form -> Form) -> Path
      -> (Path -> Int -> Form) -> List Form
lines length unitWidth center move' line drawFun =
  let
    nLinesHalfWidth = (length / 2) / unitWidth
    firstLine = floor <| -center - nLinesHalfWidth
    lastLine = ceiling <| -center + nLinesHalfWidth
    drawMove x = 
      drawFun line x
       |> move' ((center + toFloat x) * unitWidth)
  in
    List.map drawMove [firstLine..lastLine]
   
viewOneDim : Path -> ((Float, Float) -> Float) -> (Float -> Form -> Form)
             -> ViewType
viewOneDim line tfun move' address model (width', height') =
  let
    width = toFloat width'
    height = toFloat height'
    r = rect width height
         |> filled black
    lines' = lines (tfun (width, height)) model.unitWidth
               model.center move' line drawLine
  in
    Html.div
     [ Html.style <| whStyle width' height'
     , onMouseMove address MouseMove
     , onMouseDown address MouseDown
     , onMouseUp address (\_ -> MouseUp)
     , Html.onMouseOut address MouseUp
     ]
     [ Html.fromElement <| collage width' height' (r::lines') ]

view : Float -> Float -> Float -> Float -> Int -> Int -> Html.Html
view centerX widthX centerY widthY width' height' =
  let
    width = toFloat width'
    height = toFloat height'
    r = rect width height
         |> filled black
    lineX = segment (0, -width/2) (0, width/2)
    lineY = segment (-width/2, 0) (width/2, 0)
    drawFun p _ = traced { defaultLine | color <- white } p
    linesX = lines width widthX centerX moveX lineX drawFun
    linesY = lines height widthY centerY moveY lineY drawFun
  in
    Html.div
     [ Html.style <| whStyle width' height'
     ]
     [ Html.fromElement <| collage width' height' (r::(linesX ++ linesY)) ]