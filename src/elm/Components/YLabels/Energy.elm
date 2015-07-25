module Components.YLabels.Energy (Model, init, Action, update, view) where

{- Component that shows the energy label -}

import Graphics.Collage exposing (..)
import Color exposing (..)
import Html
import Html.Attributes as Html
import HtmlEvents exposing (..)
import Components.Misc exposing (whStyle)
import Signal

type alias Model =
  {
  }

init : Model
init =
  {
  }

type Action
  = NoOp

update : Action -> Model -> Model
update action model =
  case action of
    _ -> model

view : Signal.Address Action -> Model -> Float -> Float -> Html.Html
view address model width height =
  Html.div
   [ Html.style (("background-color", "blue")::whStyle width height)
   ] []