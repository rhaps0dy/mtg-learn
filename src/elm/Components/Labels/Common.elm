module Components.Labels.Common
  ( Model
  , Action(..)
  , init
  , update
  , ViewFun
  ) where

import HtmlEvents exposing (MouseButton(..), MouseButtonSet)
import Task

type alias Model =
  { centerX : Float
  , unitWidthX : Float
  , centerXMD : Float
  , unitWidthXMD : Float
  , centerY : Float
  , unitWidthY : Float
  , centerYMD : Float
  , unitWidthYMD : Float
  , mousePosMD : (Int, Int)
  , active : Bool
  , mouseDown : Maybe MouseButton
  }

type Action
  = NoOp
  | MouseMove (Int, Int)
  | MouseDown (MouseButton, (Int, Int))
  | MouseUp
  | MouseEnter (MouseButtonSet, (Int, Int))
  | MouseLeave

init : Model
init =
  { centerX = 0
  , unitWidthX = 20
  , centerXMD = 0
  , unitWidthXMD = 20
  , centerY = 0
  , unitWidthY = 20
  , centerYMD = 0
  , unitWidthYMD = 20
  , mousePosMD = (0, 0)
  , active = False
  , mouseDown = Nothing
  }

update : Action -> Model -> Model
update action model =
  case action of
    MouseDown (mb, pos) ->
      { model | mouseDown <- Just mb
              , mousePosMD <- pos
              , centerXMD <- model.centerX
              , unitWidthXMD <- model.unitWidthX
              , centerYMD <- model.centerY
              , unitWidthYMD <- model.unitWidthY
              , active <- True
              }
    MouseUp ->
      { model | mouseDown <- Nothing }
    MouseEnter (mbs, pos) ->
      if HtmlEvents.anyPressed mbs then
        { model | mousePosMD <- pos
                , centerXMD <- model.centerX
                , unitWidthXMD <- model.unitWidthX
                , centerYMD <- model.centerY
                , unitWidthYMD <- model.unitWidthY
                , active <- True
                }
      else
        model
    MouseLeave ->
      { model | active <- False }
    MouseMove pos ->
      if not model.active ||
         model.mouseDown == Nothing ||
         model.mouseDown == Just Middle
      then
        model
      else
        if model.mouseDown == Just Left then
          { model
            | centerX <- model.centerXMD +
                toFloat (fst pos - fst model.mousePosMD)
                  / model.unitWidthX
            , centerY <- model.centerYMD -
                toFloat (snd pos - snd model.mousePosMD)
                  / model.unitWidthY
            }
        else
          { model
            | unitWidthX <- model.unitWidthXMD +
                toFloat (fst pos - fst model.mousePosMD) / 10
            , unitWidthY <- model.unitWidthYMD -
                toFloat (snd pos - snd model.mousePosMD) / 10
            }
    _ -> model

type alias ViewFun = String -> (Int, Int) -> Model -> Task.Task String ()