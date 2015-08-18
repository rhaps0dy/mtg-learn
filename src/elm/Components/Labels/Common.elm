module Components.Labels.Common
  ( XModel
  , YModel
  , Action(..)
  , xInit
  , yInit
  , xUpdate
  , yUpdate
  , ViewFun
  ) where

import HtmlEvents exposing (MouseButton(..), MouseButtonSet)
import Task

type alias XModel =
-- Elm does not let you derive models. The first three lines are
-- common:
  { mousePosMD : (Int, Int)
  , active : Bool
  , mouseDown : Maybe MouseButton
-- Base end
  , centerX : Float
  , unitWidthX : Float
  , centerXMD : Float
  , unitWidthXMD : Float
  }

type alias YModel =
  { mousePosMD : (Int, Int)
  , active : Bool
  , mouseDown : Maybe MouseButton
-- Base end
  , centerY : Float
  , unitWidthY : Float
  , centerYMD : Float
  , unitWidthYMD : Float
  }

type Action
  = NoOp
  | MouseMove (Int, Int)
  | MouseDown (MouseButton, (Int, Int))
  | MouseUp
  | MouseEnter (MouseButtonSet, (Int, Int))
  | MouseLeave

xInit : XModel
xInit =
  { mousePosMD = (0, 0)
  , active = False
  , mouseDown = Nothing
-- base end
  , centerX = 0
  , unitWidthX = 20
  , centerXMD = 0
  , unitWidthXMD = 20
  }

yInit : YModel
yInit =
  { mousePosMD = (0, 0)
  , active = False
  , mouseDown = Nothing
-- base end
  , centerY = 0
  , unitWidthY = 20
  , centerYMD = 0
  , unitWidthYMD = 20
  }

-- You barely eliminate lines by refactoring into a base update and
-- two X and Y updates. So I'm copying the function and modifying
-- tiny bits of it. Please forgive me.

-- Elm really sucks. I miss macros.

xUpdate : Action -> XModel -> XModel
xUpdate action model =
  case action of
    MouseDown (mb, pos) ->
      { model | mouseDown <- Just mb
              , mousePosMD <- pos
              , centerXMD <- model.centerX
              , unitWidthXMD <- model.unitWidthX
              , active <- True
              }
    MouseUp ->
      { model | mouseDown <- Nothing }
    MouseEnter (mbs, pos) ->
      if HtmlEvents.anyPressed mbs then
        { model | mousePosMD <- pos
                , centerXMD <- model.centerX
                , unitWidthXMD <- model.unitWidthX
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
            }
        else
          { model
            | unitWidthX <- model.unitWidthXMD +
                toFloat (fst pos - fst model.mousePosMD) / 10
            }
    _ -> model

-- almost verbatim copy of xUpdate

yUpdate : Action -> YModel -> YModel
yUpdate action model =
  case action of
    MouseDown (mb, pos) ->
      { model | mouseDown <- Just mb
              , mousePosMD <- pos
              , centerYMD <- model.centerY
              , unitWidthYMD <- model.unitWidthY
              , active <- True
              }
    MouseUp ->
      { model | mouseDown <- Nothing }
    MouseEnter (mbs, pos) ->
      if HtmlEvents.anyPressed mbs then
        { model | mousePosMD <- pos
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
            | centerY <- model.centerYMD -
                toFloat (snd pos - snd model.mousePosMD)
                  / model.unitWidthY
            }
        else
          { model
            | unitWidthY <- model.unitWidthYMD -
                toFloat (snd pos - snd model.mousePosMD) / 10
            }
    _ -> model

type alias ViewFun = String -> (Int, Int) -> XModel -> YModel -> Task.Task String ()